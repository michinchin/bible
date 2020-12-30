import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/tec_navigator.dart';
import '../ugc/ugc_view.dart';

class TabBottomBarItem {
  final TecTab tab;
  final IconData icon;
  final String label;
  final Widget widget;

  const TabBottomBarItem({this.tab, this.icon, this.label, this.widget});
}

class TabBottomBar extends StatefulWidget {
  final List<TabBottomBarItem> tabs;

  const TabBottomBar({Key key, @required this.tabs}) : super(key: key);

  @override
  _TabBottomBarState createState() => _TabBottomBarState();
}

class _TabBottomBarState extends State<TabBottomBar> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Map<TecTab, GlobalKey> tabKeys;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    tabKeys = {};

    for (var i = 0; i < widget.tabs.length; i++) {
      tabKeys[widget.tabs[i].tab] = GlobalKey();
    }
  }

  Future<bool> _onBackPressed() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return false;
    }

    final tab = context.tabManager.state.tab;
    if (tabKeys.containsKey(tab)) {
      if (tabKeys[tab].currentWidget is NavigatorWithHeroController) {
        final navigator = tabKeys[tab].currentWidget as NavigatorWithHeroController;
        if (navigator.canPop(tabKeys[tab].currentState)) {
          navigator.pop(tabKeys[tab].currentState);
          return false;
        } else if (tab != TecTab.today) {
          context.tabManager.changeTab(TecTab.today);
          return false;
        }
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabManagerBloc, TabManagerState>(buildWhen: (p, n) {
      // if the tab didn't change (i.e. just showing drawer...)
      return p.tab != n.tab || p.hideBottomBar != n.hideBottomBar;
    }, builder: (context, tabState) {
      final largeScreen = !isSmallScreen(context);
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          extendBody: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton:
              (tabState.hideBottomBar || largeScreen || tabState.tab == TecTab.reader)
                  ? null
                  : ((tabState.tab == TecTab.switcher)
                      ? _CloseFAB(controller: _controller)
                      : _TabFAB()),
          drawer: (tabState.tab != TecTab.reader) ? null : const UGCView(),
          bottomNavigationBar: (tabState.hideBottomBar ||
                  (!largeScreen && tabState.tab == TecTab.reader))
              ? null
              : BlocBuilder<SheetManagerBloc, SheetManagerState>(builder: (context, sheetState) {
                  return Visibility(
                    visible: (sheetState.type != SheetType.selection),
                    child: TecTabBar(tabs: widget.tabs),
                  );
                }),
          body: SafeArea(
            left: false,
            right: false,
            top: false,
            bottom: false,
            child: Container(
              color: Theme.of(context).backgroundColor,
              child: Stack(
                children: [
                  // reader is always on the bottom
                  for (var i = 0; i < widget.tabs.length; i++)
                    if (widget.tabs[i].tab == TecTab.reader)
                      Visibility(
                        maintainState: true,
                        visible: true,
                        child: NavigatorWithHeroController(
                          key: tabKeys[widget.tabs[i].tab],
                          onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
                            settings: settings,
                            builder: (context) {
                              return widget.tabs[i].widget;
                            },
                          ),
                        ),
                      ),
                  for (var i = 0; i < widget.tabs.length; i++)
                    if (widget.tabs[i].tab != TecTab.reader)
                      Visibility(
                        maintainState: widget.tabs[i].tab != TecTab.switcher,
                        visible: widget.tabs[i].tab == tabState.tab,
                        child: NavigatorWithHeroController(
                          key: tabKeys[widget.tabs[i].tab],
                          onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
                            settings: settings,
                            builder: (context) {
                              return widget.tabs[i].widget;
                            },
                          ),
                        ),
                      ),
                  if (tabState.tab == TecTab.switcher)
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _ExpandedView(controller: _controller),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ExpandedView extends StatefulWidget {
  final AnimationController controller;

  const _ExpandedView({Key key, this.controller}) : super(key: key);

  @override
  __ExpandedViewState createState() => __ExpandedViewState();
}

class __ExpandedViewState extends State<_ExpandedView> {
  void _onSwitchViews(ViewState view) {
    // ignore: close_sinks
    final vmBloc = context.viewManager;

    if (vmBloc == null) {
      return;
    }

    if (vmBloc.state.maximizedViewUid > 0) {
      vmBloc.maximize(view.uid);
    } else {
      vmBloc?.show(view.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final _icons = <_OffscreenView>[];

    // get the offscreen views...
    for (final view in context.viewManager?.state?.views) {
      if (!context.viewManager.isViewVisible(view.uid)) {
        final title = ViewManager.shared.menuTitleWith(context: context, state: view);
        _icons.add(_OffscreenView(
          title: title,
          onPressed: () {
            context.tabManager.changeTab(TecTab.reader);
            _onSwitchViews(view);
          },
        ));
      }
    }

    return ListView(
        shrinkWrap: true,
        // mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.end,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(
          _icons.length,
          (index) => Container(
            padding: const EdgeInsets.only(right: 10),
            margin: const EdgeInsets.only(top: 10),
            alignment: Alignment.centerRight,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: widget.controller,
                curve: Interval(0, 1.0 - index / _icons.length / 2.0, curve: Curves.easeOut),
              ),
              child: InkWell(
                onTap: () {
                  _icons[index].onPressed();
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      boxShadow(
                          color: isDarkMode ? Colors.black54 : Colors.black38,
                          offset: const Offset(0, 3),
                          blurRadius: 5)
                    ],
                  ),
                  child: Text(_icons[index].title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: contentFontSizeWith(context))),
                ),
              ),
            ),
          ),
        ).toList());
  }
}

class _OffscreenView {
  final VoidCallback onPressed;
  final String title;

  const _OffscreenView({@required this.onPressed, @required this.title});
}

class _CloseFAB extends StatefulWidget {
  final AnimationController controller;

  const _CloseFAB({Key key, @required this.controller}) : super(key: key);

  @override
  __CloseFABState createState() => __CloseFABState();
}

class __CloseFABState extends State<_CloseFAB> {
  @override
  void initState() {
    super.initState();
    widget.controller.reset();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Const.tecartaBlue,
      heroTag: null,
      child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) => Transform(
                transform: Matrix4.rotationZ(widget.controller.value * 0.5 * math.pi),
                alignment: FractionalOffset.center,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              )),
      onPressed: () {
        context.tabManager.changeTab(TecTab.reader);
      },
    );
  }
}

class _TabFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      heroTag: null,
      onPressed: () => context.tabManager.changeTab(TecTab.reader),
      backgroundColor: Colors.white,
      child: const Icon(TecIcons.tecartabiblelogo, color: Const.tecartaBlue, size: 28),
    );
  }
}

class TecTabBar extends StatelessWidget {
  final List<TabBottomBarItem> tabs;
  final TabManagerBloc tabManager;

  const TecTabBar({@required this.tabs, this.tabManager});

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final tm = (tabManager == null) ? context.tabManager : tabManager;
    const maxWidth = 500;
    const fabSpace = 50;
    var leftPadding = 15.0;
    var rightPadding = 15.0 + fabSpace;

    if (MediaQuery.of(context).size.width > maxWidth) {
      rightPadding = leftPadding = (MediaQuery.of(context).size.width - maxWidth) / 2;
    }

    return BottomAppBar(
      color: Theme.of(context).appBarTheme.color,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Padding(
        padding: EdgeInsets.only(
            left: leftPadding, right: rightPadding, top: 15, bottom: context.bottomBarPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final tabItem in tabs)
              if (tabItem.icon != null)
                SheetIconButton(
                  icon: tabItem.icon,
                  text: tabItem.label,
                  color: (tm.state.tab == tabItem.tab) ? Const.tecartaBlue : null,
                  onPressed: () {
                    tm?.changeTab(tabItem.tab);
                  },
                ),
          ],
        ),
      ),
    );
  }
}

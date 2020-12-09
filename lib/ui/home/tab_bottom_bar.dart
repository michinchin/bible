import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/tab_manager_cubit.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/tec_navigator.dart';
import '../common/tec_page_route.dart';
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

class _TabBottomBarState extends State<TabBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<TabManagerCubit, TecTab>(buildWhen: (p, n) {
          // if the tab didn't change
          return p != n;
        }, builder: (context, tabState) {
          final largeScreen = !isSmallScreen(context);
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            extendBody: true,
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            floatingActionButton: (largeScreen || tabState == TecTab.reader) ? null : _TabFAB(),
            drawer: const UGCView(),
            bottomNavigationBar:
                (!largeScreen && tabState == TecTab.reader) ? null : TecTabBar(tabs: widget.tabs),
            body: SafeArea(
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
                            key: ValueKey(i),
                            onGenerateRoute: (settings) => TecPageRoute<dynamic>(
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
                          maintainState: true,
                          visible: widget.tabs[i].tab == tabState,
                          child: NavigatorWithHeroController(
                            key: ValueKey(i),
                            onGenerateRoute: (settings) => TecPageRoute<dynamic>(
                              settings: settings,
                              builder: (context) {
                                return widget.tabs[i].widget;
                              },
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TabFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      onPressed: () => context.tabManager.changeTab(TecTab.reader),
      backgroundColor: Colors.white,
      child: const Icon(TecIcons.tecartabiblelogo, color: Const.tecartaBlue, size: 28),
    );
  }
}

class TecTabBar extends StatelessWidget {
  final VoidCallback pressedCallback;
  final List<TabBottomBarItem> tabs;
  final TabManagerCubit tabManager;

  const TecTabBar({@required this.tabs, this.pressedCallback, this.tabManager});

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
                  color: (tm.state == tabItem.tab) ? Const.tecartaBlue : null,
                  onPressed: () {
                    if (pressedCallback != null) {
                      pressedCallback();
                    }

                    tm?.changeTab(tabItem.tab);
                  },
                ),
          ],
        ),
      ),
    );
  }
}

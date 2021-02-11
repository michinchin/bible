import 'dart:math' as math;

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/tec_modal_popup.dart';
import '../common/tec_navigator.dart';
import '../library/volume_image.dart';
import '../menu/settings.dart';
import '../nav/nav.dart';
import '../ugc/ugc_view.dart';
import '../volume/volume_view_data_bloc.dart';

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
  GlobalKey ugcViewKey;

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

    ugcViewKey = GlobalKey();
  }

  Future<bool> _onBackPressed() async {
    if (Navigator.of(context).canPop()) {
      // see if the drawer can go back a folder...
      if (ugcViewKey.currentWidget != null) {
        final ugcView = ugcViewKey.currentWidget;
        if (ugcView is UGCView && ugcView.willPop(ugcViewKey.currentState)) {
          return false;
        }
      }

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
    var bottomPadding = context.fullBottomBarPadding;
    var addPaddingForCards = false;
    tec.dmPrint(context.fullBottomBarPadding);
    if (bottomPadding <= 10) {
      bottomPadding += 25;
    } else {
      addPaddingForCards = true;
    }
    return BlocBuilder<TabManagerBloc, TabManagerState>(buildWhen: (p, n) {
      // if the tab didn't change (i.e. just showing drawer...)
      return p.tab != n.tab || p.hideBottomBar != n.hideBottomBar;
    }, builder: (context, tabState) {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          extendBody: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton:
              BlocBuilder<SheetManagerBloc, SheetManagerState>(builder: (context, sheetState) {
            return Visibility(
                visible:
                    (sheetState.type != SheetType.selection && sheetState.type != SheetType.hidden),
                child: (tabState.hideBottomBar)
                    ? const SizedBox.shrink()
                    : ((tabState.tab == TecTab.switcher)
                        ? Padding(
                            padding: EdgeInsets.only(bottom: bottomPadding),
                            child: _CloseFAB(controller: _controller, parentContext: context))
                        : _TabFAB()));
          }),
          drawer: (tabState.tab != TecTab.reader) ? null : UGCView(key: ugcViewKey),
          drawerScrimColor: barrierColorWithContext(context),
          bottomNavigationBar: (tabState.hideBottomBar)
              ? null
              : BlocBuilder<SheetManagerBloc, SheetManagerState>(builder: (context, sheetState) {
                  return Visibility(
                    visible: (sheetState.type != SheetType.selection &&
                        sheetState.type != SheetType.hidden &&
                        tabState.tab != TecTab.switcher),
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
                              final child = widget.tabs[i].widget;
                              if (widget.tabs[i].tab == TecTab.switcher) {
                                return GestureDetector(
                                    onTap: () {
                                      context.tabManager.changeTab(TecTab.reader);
                                    },
                                    child: child);
                              }
                              return child;
                            },
                          ),
                        ),
                      ),
                  if (tabState.tab == TecTab.switcher)
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.only(
                          bottom: addPaddingForCards ? bottomPadding * 2 : bottomPadding),
                      child: _ExpandedView(controller: _controller, parentContext: context),
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
  final BuildContext parentContext;

  const _ExpandedView({Key key, this.controller, this.parentContext}) : super(key: key);

  @override
  __ExpandedViewState createState() => __ExpandedViewState();
}

class __ExpandedViewState extends State<_ExpandedView> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    )..forward();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceInOut,
    ));
    super.initState();
  }

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
    final _covers = <_OffscreenView>[];

    // get the offscreen views...
    for (final view in context.viewManager?.state?.views) {
      if (!context.viewManager.isViewVisible(view.uid)) {
        var title = ViewManager.shared.menuTitleWith(context: context, state: view);
        final vbloc = context.viewManager.dataBlocWithView(view.uid);
        int volumeId;
        if (vbloc != null) {
          final volumeView = tec.as<VolumeViewDataBloc>(vbloc).state.asVolumeViewData;
          volumeId = volumeView.volumeId;
          title = !volumeView.useSharedRef
              ? '${volumeView.bookNameAndChapter(useShortBookName: true)}\n'
              : ''
                  '${VolumesRepository.shared.volumeWithId(volumeId).abbreviation}';
        }
        _covers.add(_OffscreenView(
            title: title,
            onPressed: () {
              context.tabManager.changeTab(TecTab.reader);
              _onSwitchViews(view);
            },
            uid: view.uid,
            icon: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  boxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.black26,
                      offset: const Offset(0, 3),
                      blurRadius: 5)
                ],
              ),
              child: volumeId != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: VolumeImage(
                        volume: VolumesRepository.shared.volumeWithId(volumeId),
                        fit: BoxFit.fill,
                      ),
                    )
                  : Container(),
            )));
      }
    }

    return SafeArea(
      child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(right: 80),
            child: GridView.extent(
                shrinkWrap: true,
                maxCrossAxisExtent: 100,
                mainAxisSpacing: 10,
                // crossAxisSpacing: 10,
                children: List<Widget>.generate(
                    _covers.length,
                    (index) => SlideTransition(
                        position: _offsetAnimation,
                        child: InkWell(
                          onTap: () => _covers[index].onPressed(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_covers[index].uid != null)
                                Flexible(
                                  flex: 4,
                                  child: Dismissible(
                                    key: ValueKey(_covers[index].uid),
                                    direction: DismissDirection.vertical,
                                    onDismissed: (_) {
                                      setState(() {
                                        context.viewManager.remove(_covers[index].uid);
                                      });
                                    },
                                    background: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      alignment: Alignment.centerRight,
                                      // color: Colors.red,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: LongPressDraggable(
                                        data: _covers[index].uid,
                                        onDragStarted: () =>
                                            context.tabManager.changeTab(TecTab.reader),
                                        feedback: _covers[index].icon,
                                        child: _covers[index].icon),
                                  ),
                                )
                              else
                                _covers[index].icon,
                              const SizedBox(height: 5),
                              Flexible(
                                child: TecText(_covers[index].title,
                                    autoSize: true,
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                                        fontSize: contentFontSizeWith(context),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          const Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 5,
                                            color: Colors.black,
                                          ),
                                        ])),
                              ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ))).toList()),
          )),
    );
  }
}

class _OffscreenView {
  final VoidCallback onPressed;
  final String title;
  final Widget icon;
  final int uid;

  const _OffscreenView(
      {@required this.onPressed, @required this.title, @required this.icon, this.uid});
}

class _CloseFAB extends StatefulWidget {
  final AnimationController controller;
  final BuildContext parentContext;

  const _CloseFAB({Key key, @required this.controller, @required this.parentContext})
      : super(key: key);

  @override
  __CloseFABState createState() => __CloseFABState();
}

class __CloseFABState extends State<_CloseFAB> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  Animation<double> _animateIcon;
  AnimationController _animationController;
  bool _isOpened = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
          ..addListener(() {
            setState(() {});
          });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    )..forward();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceInOut,
    ));
    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    widget.controller.reset();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      context.tabManager.changeTab(TecTab.reader);
      _animationController.reverse();
    }
    _isOpened = !_isOpened;
  }

  _OffscreenView getOffscreenIconView(
      {@required String title, @required IconData icon, Function(BuildContext context) onPressed}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _OffscreenView(
        title: title,
        onPressed: () {
          context.tabManager.changeTab(TecTab.reader);
          if (onPressed != null) {
            onPressed(context);
          }
        },
        icon: FloatingActionButton(
            onPressed: () {
              context.tabManager.changeTab(TecTab.reader);
              if (onPressed != null) {
                onPressed(context);
              }
            },
            // mini: true,
            child: Icon(icon, color: Const.tecartaBlue),
            backgroundColor: Theme.of(context).cardColor));
  }

  @override
  Widget build(BuildContext context) {
    final _icons = <_OffscreenView>[
      getOffscreenIconView(
          title: 'Search',
          icon: Icons.search,
          onPressed: (context) {
            showBibleSearch(context, null);
          }),
      getOffscreenIconView(
          title: 'Journal',
          icon: FeatherIcons.bookOpen,
          onPressed: (context) {
            final scaffold = Scaffold.of(context);

            // drawer will be reattached after tab switches back to reader - need to wait for that
            // grab the scaffold while our context is valid, but wait for the drawer
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              scaffold.openDrawer();
            });
          }),
      getOffscreenIconView(
          title: 'History',
          icon: Icons.history,
          onPressed: (context) {
            showBibleSearch(context, null, showHistory: true);
            // TecToast.show(context, 'need to show history here');
          }),
      // getOffscreenIconView(
      //     title: 'Account',
      //     icon: FeatherIcons.user,
      //     onPressed: (context) {
      //       tua.showSignInDlg(
      //           context: context,
      //           account: AppSettings.shared.userAccount,
      //           useRootNavigator: true,
      //           appName: Const.appNameForUA);
      //     }),
      // getOffscreenIconView(
      //     title: 'Help', icon: FeatherIcons.helpCircle, onPressed: showZendeskHelp),
      getOffscreenIconView(title: 'Settings', icon: FeatherIcons.settings, onPressed: showSettings),
      getOffscreenIconView(
          title: 'Add View',
          icon: Icons.add,
          onPressed: (context) {
            ViewManager.shared.onAddView(widget.parentContext, Const.viewTypeVolume);
          }),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < _icons.length; i++)
          SlideTransition(
            position: _offsetAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: _icons[i].icon),
                const SizedBox(height: 5),
                Flexible(
                  child: Container(
                    width: 50,
                    child: TecText(_icons[i].title,
                        maxLines: 1,
                        autoSize: true,
                        textScaleFactor: 0.9,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: contentFontSizeWith(context),
                            // fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              const Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 5,
                                color: Colors.black,
                              ),
                            ])),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        FloatingActionButton(
          child: AnimatedIcon(
            icon: AnimatedIcons.close_menu,
            progress: _animateIcon,
          ),
          onPressed: () {
            _animate();
            context.tabManager.changeTab(TecTab.reader);
          },
        ),
      ],
    );
  }
}

class _TabFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      heroTag: null,
      onPressed: () => context.tabManager.changeTab(
          context.tabManager.state.tab != TecTab.reader ? TecTab.reader : TecTab.switcher),
      backgroundColor:
          context.tabManager.state.tab != TecTab.reader ? Colors.white : Const.tecartaBlue,
      child: Icon(
          context.tabManager.state.tab != TecTab.reader
              ? TecIcons.tecartabiblelogo
              : TecIcons.tecartabiblelogo,
          color: context.tabManager.state.tab != TecTab.reader ? Const.tecartaBlue : Colors.white,
          size: 28),
    );
  }
}

class FabIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  const FabIcon({this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Flexible(
        //   child: Text(text,
        //       textAlign: TextAlign.end,
        //       style: Theme.of(context).textTheme.bodyText1.copyWith(
        //           fontSize: contentFontSizeWith(context),
        //           fontWeight: FontWeight.bold,
        //           color: Colors.white,
        //           shadows: [
        //             const Shadow(
        //               offset: Offset(1.0, 1.0),
        //               blurRadius: 5,
        //               color: Colors.black,
        //             ),
        //           ])),
        // ),
        // const SizedBox(width: 10),
        Container(
            width: 50,
            height: 60,
            // padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              boxShadow: [
                boxShadow(
                    color: isDarkMode ? Colors.black54 : Colors.black38,
                    offset: const Offset(0, 3),
                    blurRadius: 5)
              ],
            ),
            child: Icon(icon, color: Const.tecartaBlue)),
        const SizedBox(width: 20),
      ],
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: BottomAppBar(
        color: Theme.of(context).appBarTheme.color,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Padding(
          padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
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
      ),
    );
  }
}

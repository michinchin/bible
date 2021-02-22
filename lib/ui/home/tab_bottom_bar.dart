import 'dart:math' as math;

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/recent_volumes_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/common.dart';
import '../common/tec_modal_popup.dart';
import '../common/tec_modal_popup_menu.dart';
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

class _TabBottomBarState extends State<TabBottomBar> with TickerProviderStateMixin {
  AnimationController _closeFABController, _slideTabController;
  Animation<Offset> _slideTabAnimation;
  Map<TecTab, GlobalKey> tabKeys;
  GlobalKey ugcViewKey;
  int _viewUid;
  bool _showSelectViewOverlay;

  @override
  void initState() {
    super.initState();
    _showSelectViewOverlay = false;
    _closeFABController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    tabKeys = {};

    for (var i = 0; i < widget.tabs.length; i++) {
      tabKeys[widget.tabs[i].tab] = GlobalKey();
    }

    ugcViewKey = GlobalKey();

    _slideTabController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideTabAnimation = Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 2.1))
        .animate(CurvedAnimation(
      parent: _slideTabController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _closeFABController.dispose();
    _slideTabController.dispose();
    super.dispose();
  }

  void _onViewTap(int uid) {
    context.tabManager.changeTab(TecTab.reader);
    context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse);
    setState(() {
      _viewUid = uid;
      _showSelectViewOverlay = true;
    });
  }

  void onSelectView(int uid) {
    context.tbloc<SheetManagerBloc>().add(SheetEvent.main);
    if (uid != null && _viewUid != uid) {
      context.viewManager.swapPositions(
          context.viewManager.indexOfView(_viewUid), context.viewManager.indexOfView(uid),
          unhide: true);
    }
    setState(() {
      _showSelectViewOverlay = false;
    });
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
    if (bottomPadding <= 10) {
      bottomPadding += 25;
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
                visible: (sheetState.type != SheetType.selection),
                child: ((tabState.tab == TecTab.switcher)
                    ? Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: _CloseFAB(
                          controller: _closeFABController,
                          parentContext: context,
                          onViewTap: _onViewTap,
                        ))
                    : _showSelectViewOverlay
                        ? const SizedBox.shrink()
                        : SlideTransition(position: _slideTabAnimation, child: _TabFAB())));
          }),
          drawer: (tabState.tab != TecTab.reader) ? null : UGCView(key: ugcViewKey),
          drawerScrimColor: barrierColorWithContext(context),
          bottomNavigationBar: _showSelectViewOverlay
              ? null
              : BlocBuilder<SheetManagerBloc, SheetManagerState>(builder: (context, sheetState) {
                  if (sheetState.type == SheetType.hidden) {
                    // slide the tab off the screen...
                    _slideTabController.forward();
                  } else {
                    // slide the tab to normal view...
                    _slideTabController.reverse();
                  }

                  return Visibility(
                    visible:
                        (sheetState.type != SheetType.selection && tabState.tab != TecTab.switcher),
                    child: SlideTransition(
                        position: _slideTabAnimation, child: TecTabBar(tabs: widget.tabs)),
                  );
                }),
          body: Container(
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
                            return Stack(children: [
                              widget.tabs[i].widget,
                              if (_showSelectViewOverlay) _SelectViewOverlay(_viewUid, onSelectView)
                            ]);
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
              ],
            ),
          ),
        ),
      );
    });
  }
}

const bookCoverWidth = 60.0;
const bookCoverHeight = 80.0;

class _VolumeCard extends StatelessWidget {
  final int volumeId;
  final Color borderColor;

  const _VolumeCard(this.volumeId, {this.borderColor});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final volume = VolumesRepository.shared.volumeWithId(volumeId);
    final border = (borderColor != null)
        ? BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(5),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              boxShadow(
                  color: (isDarkMode ? Colors.black54 : Colors.black26),
                  offset: const Offset(0, 3),
                  blurRadius: 5)
            ],
          );

    return Container(
        width: bookCoverWidth,
        height: bookCoverHeight,
        decoration: border,
        child: volume != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: VolumeImage(
                  volume: volume,
                  fit: BoxFit.fill,
                ))
            : Container());
  }
}

class _ExpandedView extends StatefulWidget {
  final AnimationController controller;
  final BuildContext parentContext;
  final Function(int) onViewTap;

  const _ExpandedView({Key key, this.controller, this.parentContext, this.onViewTap})
      : super(key: key);

  @override
  __ExpandedViewState createState() => __ExpandedViewState();
}

class __ExpandedViewState extends State<_ExpandedView> {
  void _onSwitchViews(int viewUid) {
    // ignore: close_sinks
    final vmBloc = context.viewManager;

    if (vmBloc == null) {
      return;
    }

    if (viewUid & Const.recentFlag == Const.recentFlag) {
      // need to add this view...
      ViewManager.shared.onAddView(widget.parentContext, Const.viewTypeVolume,
          options: <String, dynamic>{'volumeId': viewUid ^ Const.recentFlag});
    } else if (vmBloc.state.maximizedViewUid > 0) {
      vmBloc.maximize(viewUid);
    } else {
      vmBloc.show(viewUid);
    }

    context.tabManager.changeTab(TecTab.reader);
  }

  void _onCoverTap(int viewUid) {
    if (context.viewManager.countOfVisibleViews <= 1) {
      _onSwitchViews(viewUid);
    } else {
      widget.onViewTap(viewUid);
    }
  }

  List<TableRow> buildMenuItems(BuildContext context, int uid) {
    final items = <TableRow>[];
    final vmBloc = context.viewManager;
    final isVisible = vmBloc.isViewVisible(uid);
    final isMaximized = vmBloc.state.maximizedViewUid == uid;

    if (!isVisible || !isMaximized) {
      items.add(tecModalPopupMenuItem(
        context,
        SFSymbols.arrow_up_left_arrow_down_right,
        'Full screen',
        isVisible && !isMaximized && vmBloc.countOfOpenViews == 1
            ? null
            : () async {
                var uidToShow = uid;
                if (uid & Const.recentFlag == Const.recentFlag) {
                  // need to add this view...
                  uidToShow = vmBloc.state.nextUid;
                  await ViewManager.shared.onAddView(widget.parentContext, Const.viewTypeVolume,
                      options: <String, dynamic>{'volumeId': uid ^ Const.recentFlag});
                }
                vmBloc.maximize(uidToShow);
                await Navigator.of(context).maybePop();
                widget.parentContext.tabManager.add(TecTabEvent.reader);
              },
      ));
    }

    if (vmBloc.state.maximizedViewUid > 0 && !isMaximized) {
      items.add(tecModalPopupMenuItem(
        context,
        splitScreenIcon(context),
        'Split screen',
        () {
          vmBloc.restore();
          Navigator.of(context).maybePop();
          widget.parentContext.tabManager.add(TecTabEvent.reader);
        },
      ));
    }

    items.add(tecModalPopupMenuItem(
        context,
        Icons.close,
        isVisible ? 'Close' : 'Remove',
        (isVisible && vmBloc.countOfOpenViews == 1)
            ? null
            : () {
                // remove the view - if it's in the view manager
                vmBloc.remove(uid);

                // drop the menu
                Navigator.of(context).maybePop();

                if (isVisible) {
                  // view is closed - if there are no more views - add one...
                  if (vmBloc.countOfOpenViews == 1) {}

                  // return to the reader
                  widget.parentContext.tabManager.add(TecTabEvent.reader);
                } else {
                  // remove from recent used volumes
                  int volumeId;
                  if (uid & Const.recentFlag == Const.recentFlag) {
                    // recent cover
                    volumeId = uid ^ Const.recentFlag;
                  } else {
                    final viewDataBloc = vmBloc.dataBlocWithView(uid);
                    if (viewDataBloc is VolumeViewDataBloc) {
                      volumeId = viewDataBloc.state.asVolumeViewData.volumeId;
                    }
                  }

                  if (volumeId != null && volumeId > 0) {
                    context.tbloc<RecentVolumesBloc>().removeVolume(volumeId);
                    setState(() {
                      // force rebuild of cover list...
                    });
                  }
                }
              }));

    return items;
  }

  Future<void> _onCoverLongPress(int uid) async {
    final key = GlobalObjectKey(uid);
    final renderBox = key.currentContext.findRenderObject() as RenderBox;
    // final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    // final x = (position.dx - (MediaQuery.of(context).size.width / 2) + size.width / 2) /
    // (MediaQuery.of(context).size.width / 2);
    // final y = (position.dy - (MediaQuery.of(context).size.height / 2) + size.height / 2) /
    // (MediaQuery.of(context).size.height / 2);

    await showTecModalPopupMenu(
        context: context,
        // alignment: Alignment(x, y),
        offset: Offset(position.dx, position.dy),
        minWidth: bookCoverWidth,
        menuItemsBuilder: (c) => buildMenuItems(c, uid));
  }

  @override
  Widget build(BuildContext context) {
    const _maxCovers = 9;
    final _covers = <_OffscreenView>[];
    final _visibleCovers = <_OffscreenView>[];
    final _existingVolumes = <int>[];

    // get the offscreen views...
    for (final view in context.viewManager?.state?.views) {
      var title = ViewManager.shared.menuTitleWith(context: context, state: view);
      final viewDataBloc = context.viewManager.dataBlocWithView(view.uid);
      int volumeId;
      if (viewDataBloc != null) {
        final volumeView = tec.as<VolumeViewDataBloc>(viewDataBloc).state.asVolumeViewData;
        volumeId = volumeView.volumeId;
        title =
            '${!volumeView.useSharedRef ? '${volumeView.bookNameAndChapter(useShortBookName: true)}\n' : ''}${'${VolumesRepository.shared.volumeWithId(volumeId).abbreviation}'}';
      }
      final visible = context.viewManager.isViewVisible(view.uid);
      final child = _VolumeCard(volumeId, borderColor: visible ? Colors.yellow : null);
      final cover = _OffscreenView(
          title: title,
          onPressed: () {
            // context.tabManager.changeTab(TecTab.reader);
            // _onSwitchViews(view);
          },
          uid: view.uid,
          icon: child /* !visible ? child : _StackIcon(child, FeatherIcons.eye) */);
      _existingVolumes.add(volumeId);
      if (visible) {
        _visibleCovers.add(cover);
      } else {
        _covers.add(cover);
      }
    }

    // get the recent covers
    for (final recent in context.tbloc<RecentVolumesBloc>().state.volumes) {
      if (_existingVolumes.contains(recent.id)) {
        continue;
      }

      final cover = _OffscreenView(
        title: VolumesRepository.shared.volumeWithId(recent.id).abbreviation,
        onPressed: () {
          // context.tabManager.changeTab(TecTab.reader);
          // _onSwitchViews(view);
        },
        uid: Const.recentFlag + recent.id,
        icon: _VolumeCard(recent.id),
      );

      _covers.add(cover);

      if (_visibleCovers.length + _covers.length >= _maxCovers) {
        break;
      }
    }

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => context.tabManager.changeTab(TecTab.reader),
          child: SingleChildScrollView(
            reverse: true,
            child: Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Wrap(
                  alignment: WrapAlignment.end,
                  verticalDirection: VerticalDirection.up,
                  spacing: 30,
                  runSpacing: 10,
                  children: List<Widget>.generate(_visibleCovers.length + _covers.length, (index) {
                    var i = index;
                    _OffscreenView cover;
                    if (i >= _visibleCovers.length) {
                      i = index - _visibleCovers.length;
                      cover = _covers[i];
                    } else {
                      cover = _visibleCovers[i];
                    }
                    return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: widget.controller,
                          curve: Interval(
                              0, 1.0 - i / (_covers.length + _visibleCovers.length) / 2.0,
                              curve: Curves.easeOut),
                        ),
                        child: InkWell(
                          key: GlobalObjectKey(cover.uid),
                          onTap: () => _onCoverTap(cover.uid),
                          onLongPress: () => _onCoverLongPress(cover.uid),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (cover.uid != null)
                                Flexible(
                                  flex: 4,
                                  child: Draggable(
                                      data: cover.uid,
                                      onDragStarted: () {
                                        context.tabManager.changeTab(TecTab.reader);
                                        context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse);
                                      },
                                      onDragCompleted: () => widget.parentContext
                                          .tbloc<SheetManagerBloc>()
                                          .add(SheetEvent.main),
                                      feedback: cover.icon,
                                      child: cover.icon),
                                )
                              else
                                cover.icon,
                              const SizedBox(height: 5),
                              SizedBox(
                                width: bookCoverWidth,
                                child: TecText(cover.title,
                                    // autoSize: true,
                                    maxLines: 1,
                                    textScaleFactor: 0.7,
                                    textAlign: TextAlign.center,
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
                        ));
                  }).toList()),
            ),
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
  final Function(int uid) onViewTap;

  const _CloseFAB(
      {Key key, @required this.controller, @required this.parentContext, @required this.onViewTap})
      : super(key: key);

  @override
  __CloseFABState createState() => __CloseFABState();
}

class __CloseFABState extends State<_CloseFAB> with SingleTickerProviderStateMixin {
  Animation<double> _translateButton;
  AnimationController _animationController;
  bool _isOpened = true;
  final _fabHeight = 56.0;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
          ..addListener(() {
            setState(() {});
          })
          ..forward();

    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0, curve: Curves.easeOut),
    ));
    widget.controller.reset();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animate() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      context.tabManager.changeTab(TecTab.reader);
    }
    setState(() {
      _isOpened = !_isOpened;
    });
  }

  _OffscreenView getOffscreenIconView(
      {@required String title, @required IconData icon, Function(BuildContext context) onPressed}) {
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
          title: 'Add View',
          icon: Icons.add,
          onPressed: (context) {
            ViewManager.shared.onAddView(widget.parentContext, Const.viewTypeVolume);
          }),
      getOffscreenIconView(title: 'Settings', icon: FeatherIcons.settings, onPressed: showSettings),
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
      getOffscreenIconView(
          title: 'Search',
          icon: Icons.search,
          onPressed: (context) {
            showBibleSearch(context, null);
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
    ];

    Widget child;
    List<Widget> children({bool useRow = false}) => [
          Expanded(
            child: SingleChildScrollView(
                scrollDirection: useRow ? Axis.horizontal : Axis.vertical,
                reverse: true,
                child: useRow
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(width: 40),
                        for (var i = 0; i < _icons.length; i++) ...[
                          Transform(
                              transform: Matrix4.translationValues(
                                _translateButton.value * i,
                                0,
                                0,
                              ),
                              child: _icons[i].icon),
                          const SizedBox(width: 5),
                          Transform(
                            transform: Matrix4.translationValues(
                              _translateButton.value * i,
                              0,
                              0,
                            ),
                            child: TecText(
                              _icons[i].title,
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
                                  ]),
                            ),
                          ),
                          const SizedBox(width: 10)
                        ]
                      ])
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          for (var i = 0; i < _icons.length; i++) ...[
                            Transform(
                                transform: Matrix4.translationValues(
                                  0,
                                  _translateButton.value * i,
                                  0,
                                ),
                                child: _icons[i].icon),
                            const SizedBox(height: 5),
                            Transform(
                              transform: Matrix4.translationValues(
                                0,
                                _translateButton.value * i,
                                0,
                              ),
                              child: TecText(
                                _icons[i].title,
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
                                    ]),
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ],
                      )),
          ),
          FloatingActionButton(
              backgroundColor: Const.tecartaBlue,
              onPressed: _animate,
              child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, child) => Transform(
                        transform: Matrix4.rotationZ(widget.controller.value * 0.5 * math.pi),
                        alignment: FractionalOffset.center,
                        child: const Icon(Icons.close),
                      )))
        ];

    if (isSmallScreen(context) && MediaQuery.of(context).orientation == Orientation.landscape) {
      child = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _ExpandedView(
                  onViewTap: widget.onViewTap,
                  controller: widget.controller,
                  parentContext: widget.parentContext),
            ),
            const SizedBox(height: 20),
            Row(children: children(useRow: true))
          ]);
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _ExpandedView(
                onViewTap: widget.onViewTap,
                controller: widget.controller,
                parentContext: widget.parentContext),
          ),
          Column(children: children()),
        ],
      );
    }

    return AnimatedContainer(duration: const Duration(milliseconds: 250), child: child);
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

class _SelectViewOverlay extends StatelessWidget {
  final int viewUid;
  final Function(int) onSelect;

  const _SelectViewOverlay(this.viewUid, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final vmBloc = context.viewManager;
    int volumeId;

    if (viewUid & Const.recentFlag == Const.recentFlag) {
      volumeId = viewUid ^ Const.recentFlag;
    } else {
      volumeId =
          (vmBloc.dataBlocWithView(viewUid) as VolumeViewDataBloc).state.asVolumeViewData.volumeId;
    }

    final volume = VolumesRepository.shared.volumeWithId(volumeId);
    final visibleViews = vmBloc.state.views.where((v) => vmBloc.isViewVisible(v.uid)).toList();
    var viewLayout = vmBloc.layoutOfView(visibleViews.last.uid).rect;

    if (vmBloc.isViewVisible(viewUid)) {
      viewLayout = vmBloc.layoutOfView(viewUid).rect;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      TecToast.show(context, 'Drag to place the ${volume.name}');
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onSelect(null),
      child: SafeArea(
        child: Stack(children: [
          Positioned.fromRect(
            rect: viewLayout,
            child: Align(
                alignment: Alignment.center,
                child: Draggable(
                    data: viewUid,
                    onDragStarted: () {
                      context.tabManager.changeTab(TecTab.reader);
                      context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse);
                    },
                    childWhenDragging: const SizedBox.shrink(),
                    onDragCompleted: () {
                      onSelect(null);
                      context.tbloc<SheetManagerBloc>().add(SheetEvent.main);
                    },
                    feedback: _StackIcon(_VolumeCard(volume.id), FeatherIcons.move),
                    child: _StackIcon(_VolumeCard(volume.id), FeatherIcons.move))),
          ),
        ]),
      ),
    );
  }
}

class _StackIcon extends StatelessWidget {
  final Widget child;
  final IconData icon;

  const _StackIcon(this.child, this.icon);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight.add(const Alignment(-2.5, -0.5)),
      children: [
        child,
        CircleAvatar(
          radius: 15,
          backgroundColor: Const.tecartaBlue,
          child: Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

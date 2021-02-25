import 'dart:math' as math;

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/prefs_bloc.dart';
import '../../blocs/recent_volumes_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/pref_item.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/common.dart';
import '../common/tec_modal_popup.dart';
import '../common/tec_modal_popup_menu.dart';
import '../common/tec_navigator.dart';
import '../library/library.dart';
import '../library/volume_image.dart';
import '../menu/reorder_views.dart';
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
    context.tbloc<DragOverlayCubit>().show(uid);
    setState(() {
      _viewUid = uid;
      _showSelectViewOverlay = true;
    });
  }

  void onSelectView(int uid) {
    context.tbloc<SheetManagerBloc>().add(SheetEvent.main);
    if (uid != null && _viewUid != uid) {
      context.viewManager.swapPositions(
          context.viewManager.indexOfView(_viewUid), context.viewManager.indexOfView(uid));
    } else if (uid == null) {
      context.tbloc<DragOverlayCubit>().clear();
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
                          closeFABController: _closeFABController,
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
                  if (sheetState.type == SheetType.selection ||
                      tabState.tab == TecTab.switcher ||
                      sheetState.type == SheetType.hidden) {
                    // slide the tab off the screen...
                    _slideTabController.forward();
                  } else {
                    // slide the tab to normal view...
                    _slideTabController.reverse();
                  }

                  return Opacity(
                    opacity:
                        (sheetState.type == SheetType.selection || tabState.tab == TecTab.switcher)
                            ? 0
                            : 1.0,
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
    final volume = VolumesRepository.shared.volumeWithId(volumeId);
    final border = (borderColor == null)
        ? null
        : BoxDecoration(
            boxShadow: [
              boxShadow(
                  color: borderColor, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2)
            ],
            borderRadius: BorderRadius.circular(5),
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
  final BuildContext parentContext;
  final Function(int) onViewTap;

  const _ExpandedView({Key key, this.parentContext, this.onViewTap}) : super(key: key);

  @override
  __ExpandedViewState createState() => __ExpandedViewState();
}

class __ExpandedViewState extends State<_ExpandedView> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  var _showShadow = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward(from: 0);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showShadow = true;
          });
        }
      });
  }

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
    if (context.viewManager.state.maximizedViewUid <= 0 &&
        (context.viewManager.isFull || context.viewManager.isViewVisible(viewUid))) {
      widget.onViewTap(viewUid);
    } else {
      _onSwitchViews(viewUid);
    }
  }

  List<TableRow> buildMenuItems(BuildContext context, int uid) {
    final items = <TableRow>[];
    final vmBloc = context.viewManager;
    final isVisible = vmBloc.isViewVisible(uid);
    final isMaximized = vmBloc.state.maximizedViewUid == uid;

    if (!isVisible && vmBloc.state.maximizedViewUid <= 0) {
      items.add(tecModalPopupMenuItem(
        context,
        vmBloc.isFull ? Icons.swap_calls : SFSymbols.plus,
        vmBloc.isFull ? 'Replace View' : 'Add view',
        () {
          Navigator.of(context).maybePop();
          _onCoverTap(uid);
        },
      ));
    }

    if (isVisible && vmBloc.state.maximizedViewUid <= 0) {
      items.add(tecModalPopupMenuItem(
        context,
        Icons.swap_calls,
        'Move view',
        vmBloc.countOfOpenViews > 1
            ? () {
                Navigator.of(context).maybePop();
                _onCoverTap(uid);
              }
            : null,
      ));
    }

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
        () async {
          await Navigator.of(context).maybePop();
          widget.parentContext.tabManager.add(TecTabEvent.reader);

          // remove full screen
          vmBloc.restore();

          // make sure this content is viewable...
          if (uid & Const.recentFlag == Const.recentFlag) {
            final uidToShow = vmBloc.state.nextUid;
            await ViewManager.shared.onAddView(widget.parentContext, Const.viewTypeVolume,
                options: <String, dynamic>{'volumeId': uid ^ Const.recentFlag});
            vmBloc.show(uidToShow);
          } else {
            vmBloc.show(uid);
          }
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
                Navigator.of(context).maybePop();
                vmBloc.remove(uid);

                if (isVisible) {
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
    final _maxCovers = isSmallScreen(context) ? 9 : 14;
    final _covers = <_OffscreenView>[];
    final _visibleCovers = <_OffscreenView>[];
    final _existingVolumes = <int>[];
    String _locationTitle;

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
        _locationTitle ??= volumeView.bookNameAndChapter(useShortBookName: true);
      }
      final visible = context.viewManager.isViewVisible(view.uid);
      final child = _VolumeCard(
        volumeId,
        borderColor: visible ? Const.tecartaBlue : null,
      );
      final cover = _OffscreenView(
        title: title,
        onPressed: () {
          // context.tabManager.changeTab(TecTab.reader);
          // _onSwitchViews(view);
        },
        uid: view.uid,
        icon: child,
      );
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
        title: (!PrefsBloc.getBool(PrefItemId.syncChapter) && _locationTitle.isNotEmpty)
            ? _locationTitle
            : VolumesRepository.shared.volumeWithId(recent.id).abbreviation,
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
                      scale: _animation,
                      child: InkWell(
                        highlightColor: Colors.transparent,
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
                                      context.tbloc<DragOverlayCubit>().show(cover.uid);
                                      context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse);
                                      context.tabManager.changeTab(TecTab.reader);
                                    },
                                    // onDragCompleted never called because widget already gets disposed
                                    feedback: cover.icon,
                                    child: cover.icon),
                              )
                            else
                              cover.icon,
                            const SizedBox(height: 5),
                            SizedBox(
                              width: bookCoverWidth,
                              child: TecText(
                                cover.title,
                                maxLines: 1,
                                textScaleFactor: 0.7,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontSize: contentFontSizeWith(context),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: _showShadow
                                          ? [
                                              const Shadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 5,
                                                color: Colors.black,
                                              ),
                                            ]
                                          : [],
                                    ),

                              ),
                            ),
                          ],
                        ),
                      ),
                    );
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
  final AnimationController closeFABController;
  final BuildContext parentContext;
  final Function(int uid) onViewTap;

  const _CloseFAB(
      {Key key,
      @required this.closeFABController,
      @required this.parentContext,
      @required this.onViewTap})
      : super(key: key);

  @override
  __CloseFABState createState() => __CloseFABState();
}

class __CloseFABState extends State<_CloseFAB> with SingleTickerProviderStateMixin {
  bool _isOpened = true;

  @override
  void initState() {
    widget.closeFABController.reset();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.closeFABController.forward();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _animate() {
    if (_isOpened) {
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
      if (!context.viewManager.isFull || context.viewManager.state.maximizedViewUid > 0)
        getOffscreenIconView(
            title: 'Add View',
            icon: Icons.add,
            onPressed: (context) {
              ViewManager.shared.onAddView(widget.parentContext, Const.viewTypeVolume);
            }),
      if (context.viewManager.isFull && context.viewManager.state.maximizedViewUid <= 0)
        getOffscreenIconView(
            title: 'Replace View',
            icon: Icons.swap_calls,
            onPressed: (context) async {
              final volumeId =
                  await selectVolumeInLibrary(context, title: 'Select', initialTabPrefix: null);
              widget.onViewTap(Const.recentFlag | volumeId);
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
                          _icons[i].icon,
                          const SizedBox(width: 5),
                          TecText(
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
                            _icons[i].icon,
                            const SizedBox(height: 5),
                            TecText(
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
                            const SizedBox(height: 5),
                          ],
                        ],
                      )),
          ),
          FloatingActionButton(
              backgroundColor: Const.tecartaBlue,
              onPressed: _animate,
              child: AnimatedBuilder(
                  animation: widget.closeFABController,
                  builder: (context, child) => Transform(
                        transform:
                            Matrix4.rotationZ(widget.closeFABController.value * 0.5 * math.pi),
                        alignment: FractionalOffset.center,
                        child: const Icon(Icons.close),
                      )))
        ];

    final _expandedView =
        _ExpandedView(onViewTap: widget.onViewTap, parentContext: widget.parentContext);

    if (isSmallScreen(context) && MediaQuery.of(context).orientation == Orientation.landscape) {
      child = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _expandedView,
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
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: _expandedView,
            ),
          ),
          Column(children: children()),
        ],
      );
    }

    return AnimatedContainer(duration: const Duration(milliseconds: 250), child: child);
  }
}

class _TabFAB extends StatefulWidget {
  @override
  __TabFABState createState() => __TabFABState();
}

class __TabFABState extends State<_TabFAB> {
  void _onTap() {
    if (context.tabManager.state.tab != TecTab.reader) {
      initFeatureDiscovery(
          context: context, pref: Const.prefFabRead, steps: {Const.fabReadFeatureId});
      context.tabManager.changeTab(TecTab.reader);
    } else {
      context.tabManager.changeTab(TecTab.switcher);
    }
  }

  @override
  Widget build(BuildContext context) {
    var backgroundColor = Const.tecartaBlue;
    var textColor = Colors.white;
    var targetColor = Theme.of(context).cardColor;
    var title = 'Welcome!';
    var description = 'Tap here to view the Bible';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (context.tabManager.state.tab == TecTab.reader) {
      backgroundColor = Theme.of(context).cardColor;
      textColor = isDarkMode ? Colors.white : Colors.black;
      targetColor = Const.tecartaBlue;
      title = 'Let\'s get started!';
      description =
          'Tap here to view your journal, history, and more. Add new views or switch between recent ones.';
    }
    return DescribedFeatureOverlay(
      featureId: context.tabManager.state.tab == TecTab.reader
          ? Const.fabReadFeatureId
          : Const.fabTabFeatureId,
      tapTarget: Icon(
        TecIcons.tecartabiblelogo,
        color: context.tabManager.state.tab != TecTab.reader ? Const.tecartaBlue : Colors.white,
      ),
      onComplete: () async {
        // _onTap();
        return true;
      },
      backgroundColor: backgroundColor,
      textColor: textColor,
      targetColor: targetColor,
      title: Text(title),
      description: Text(description),
      child: FloatingActionButton(
        elevation: 2,
        heroTag: null,
        onPressed: _onTap,
        backgroundColor:
            context.tabManager.state.tab != TecTab.reader ? Colors.white : Const.tecartaBlue,
        child: Icon(
            context.tabManager.state.tab != TecTab.reader
                ? TecIcons.tecartabiblelogo
                : TecIcons.tecartabiblelogo,
            color: context.tabManager.state.tab != TecTab.reader ? Const.tecartaBlue : Colors.white,
            size: 28),
      ),
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
    Rect viewLayout;
    if (vmBloc.isViewVisible(viewUid)) {
      viewLayout = vmBloc.layoutOfView(viewUid).rect;
    }

    final child = InkWell(
        onTap: () => onSelect(null), child: _StackIcon(_VolumeCard(volume.id), FeatherIcons.move));
    final aligned = Align(
        alignment: Alignment.center,
        child: Draggable(
          data: viewUid,
          onDragStarted: () {
            context.tabManager.changeTab(TecTab.reader);
            context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse);
          },
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (_) {
            context.tbloc<DragOverlayCubit>().clear();
            onSelect(null);
            context.tbloc<SheetManagerBloc>().add(SheetEvent.main);
          },
          feedback: child,
          child: child,
        ));
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onSelect(null),
      child: SafeArea(
        child: Stack(alignment: Alignment.center, children: [
          if (viewLayout != null)
            Positioned.fromRect(
              rect: viewLayout,
              child: aligned,
            )
          else
            aligned,
          Positioned(
              bottom: 10,
              child: Chip(
                backgroundColor: Const.tecartaBlue,
                label: Text('Drag to place the ${volume.name}',
                    style: const TextStyle(color: Colors.white)),
              ))
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

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/tab_manager_cubit.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import 'tab_bottom_bar.dart';

class ReaderFAB extends StatefulWidget {
  final Icon mainIcon;
  final double elevation;
  final Color backgroundColor;
  final List<TabBottomBarItem> tabs;

  const ReaderFAB({
    @required this.tabs,
    this.mainIcon,
    this.elevation,
    this.backgroundColor = Colors.blue,
  });

  @override
  _ReaderFABState createState() => _ReaderFABState();
}

class _ReaderFABState extends State<ReaderFAB> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  OverlayEntry _overlayEntry;
  List<FABIcon> _icons;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  Future<void> _insertOverlayEntry() async {
    if (MediaQuery.of(context).accessibleNavigation) {
      //screen reader on
      await showDialog<void>(
          context: context,
          builder: (c) => SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.bottomRight,
                  child: _expandedView(),
                ),
              ));
    } else {
      _overlayEntry = OverlayEntry(
          maintainState: true,
          builder: (c) {
            return Scaffold(
              primary: false,
              extendBody: false,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.25),
              floatingActionButton: closeFab(),
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              bottomNavigationBar: TecTabBar(
                tabs: widget.tabs,
                tabManager: context.tabManager,
                pressedCallback: _switchedTabs,
              ),
              body: Semantics(
                container: true,
                enabled: true,
                child: Stack(alignment: Alignment.bottomRight, children: [
                  GestureDetector(
                    onTap: _removeOverlayEntry,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Container(padding: const EdgeInsets.only(bottom: 40), child: _expandedView()),
                ]),
              ),
            );
          });

      Overlay.of(context).insert(_overlayEntry);
    }
  }

  Widget _expandedView() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                parent: _controller,
                curve: Interval(0, 1.0 - index / _icons.length / 2.0, curve: Curves.easeOut),
              ),
              child: InkWell(
                onTap: () {
                  _removeOverlayEntry();
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

  Widget closeFab() => FloatingActionButton(
        backgroundColor: _controller.isDismissed ? widget.backgroundColor : Const.tecartaBlue,
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform(
                  transform: Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: _controller.isDismissed
                      ? widget.mainIcon
                      : const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                )),
        onPressed: () {
          if (_controller.isDismissed) {
            _controller.forward();
          } else {
            _removeOverlayEntry();
          }
        },
      );

  void _switchedTabs() {
    _removeOverlayEntry(resetReaderTab: false);
  }

  void _removeOverlayEntry({bool resetReaderTab = true}) {
    _controller.reverse();
    _overlayEntry?.remove();

    if (MediaQuery.of(context).accessibleNavigation) {
      Navigator.of(context).pop();
    }

    setState(() {
      _overlayEntry = null;
    });

    if (resetReaderTab) {
      // we're currently in overlay tab - it was dismissed but not switched to another tab
      // reset it back to reader
      context.tabManager.changeTab(TecTab.reader);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenReaderOn = MediaQuery.of(context).accessibleNavigation;
    return Container(
        alignment: screenReaderOn ? Alignment.bottomRight : null,
        padding: screenReaderOn ? const EdgeInsets.only(bottom: 30) : null,
        child: FloatingActionButton(
            elevation: widget.elevation,
            backgroundColor: widget.backgroundColor,
            heroTag: null,
            child: widget.mainIcon,
            onPressed: () {
              _icons = offScreenViews(context);
              _insertOverlayEntry();
              _controller.forward();
            }));
  }

  void _onSwitchViews(BuildContext context, ViewState view) {
    // ignore: close_sinks
    final vmBloc = context.viewManager;

    if (vmBloc == null) {
      return;
    }

    if (vmBloc.state.maximizedViewUid > 0) {
      vmBloc.add(ViewManagerEvent.maximize(view.uid));
    } else {
      // find the last visible window and replace that one... probably need a pop up grid...
      // TODO(abby): add a dialog to display a grid to allow placement
      ViewState lastVisible;
      for (final view in vmBloc.state?.views) {
        if (vmBloc.isViewVisible(view.uid)) {
          lastVisible = view;
        } else {
          break;
        }
      }

      final visiblePosition = vmBloc.indexOfView(lastVisible.uid);
      final hiddenPosition = vmBloc.indexOfView(view.uid);

      vmBloc.add(ViewManagerEvent.move(fromPosition: hiddenPosition, toPosition: visiblePosition));
      // ignore: cascade_invocations
      vmBloc.add(
          ViewManagerEvent.move(fromPosition: visiblePosition + 1, toPosition: hiddenPosition));
    }
  }

  List<FABIcon> offScreenViews(BuildContext context) {
    final items = <FABIcon>[];
    for (final view in context.viewManager?.state?.views) {
      if (!context.viewManager.isViewVisible(view.uid)) {
        final title = ViewManager.shared.menuTitleWith(context: context, state: view);
        items.add(FABIcon(
            title: title,
            onPressed: () {
              _removeOverlayEntry();
              _onSwitchViews(context, view);
            },
            iconData: Icons.ac_unit));
      }
    }
    return items;
  }
}

class FABIcon {
  final VoidCallback onPressed;
  final IconData iconData;
  final String title;
  final List<Color> colors;

  const FABIcon(
      {@required this.onPressed, @required this.iconData, @required this.title, this.colors});
}

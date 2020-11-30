import 'dart:math' as math;
import 'dart:ui';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../sheet/snap_sheet.dart';

class ExpandableFAB extends StatefulWidget {
  final List<FABIcon> icons;
  final IconData mainIcon;
  final Color backgroundColor;

  const ExpandableFAB({
    @required this.icons,
    this.mainIcon = FeatherIcons.settings,
    this.backgroundColor = Colors.blue,
  });

  @override
  _ExpandableFABState createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  OverlayEntry _overlayEntry;

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
          builder: (context) {
            return Scaffold(
              primary: false,
              extendBody: false,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.25),
              floatingActionButton: closeFab(),
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              bottomNavigationBar: TecTabBar(
                pressedCallback: _removeOverlayEntry,
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
                  Container(
                      height: double.infinity,
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _expandedView()),
                ]),
              ),
            );
          });

      Overlay.of(context).insert(_overlayEntry);
    }
  }

  Widget _expandedView() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(widget.icons.length, (index) {
        final Widget child = Container(
          height: 35 * scaleFactorWith(context),
          padding: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0, 1.0 - index / widget.icons.length / 2.0, curve: Curves.easeOut),
            ),
            child: InkWell(
              onTap: () {
                _removeOverlayEntry();
                widget.icons[index].onPressed();
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
                child: Text(widget.icons[index].title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontSize: contentFontSizeWith(context))),
              ),
            ),
          ),
        );
        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: child,
        );
      }).toList(),
    );
  }

  Widget closeFab() => FloatingActionButton(
        // mini: true,
        backgroundColor: widget.backgroundColor,
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform(
                  transform: Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: Icon(
                    _controller.isDismissed ? widget.mainIcon : Icons.close,
                    size: 15,
                    color: Theme.of(context).cardColor,
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

  void _removeOverlayEntry() {
    _controller.reverse();
    _overlayEntry?.remove();

    if (MediaQuery.of(context).accessibleNavigation) {
      Navigator.of(context).pop();
    }

    setState(() {
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenReaderOn = MediaQuery.of(context).accessibleNavigation;
    return Container(
        alignment: screenReaderOn ? Alignment.bottomRight : null,
        padding: screenReaderOn ? const EdgeInsets.only(bottom: 30) : null,
        child: FloatingActionButton(
            mini: true,
            elevation: 4,
            backgroundColor: widget.backgroundColor,
            heroTag: null,
            // child: Icon(widget.mainIcon, color: Colors.white, size: 20),
            child: Icon(widget.mainIcon, color: Colors.white, size: 22),
            onPressed: () {
              _insertOverlayEntry();
              _controller.forward();
            }));
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

class TecFab extends StatelessWidget {
  final ViewState state;

  const TecFab(this.state);

  @override
  Widget build(BuildContext context) {
    // void _onSwitchViews(ViewManagerBloc vmBloc, int viewUid, ViewState view) {
    //   if (vmBloc.state.maximizedViewUid == viewUid) {
    //     vmBloc?.add(ViewManagerEvent.maximize(view.uid));
    //   } else {
    //     final thisViewPos = vmBloc.indexOfView(viewUid);
    //     final hiddenViewPos = vmBloc.indexOfView(view.uid);
    //     vmBloc?.add(ViewManagerEvent.move(
    //         fromPosition: vmBloc.indexOfView(view.uid), toPosition: vmBloc.indexOfView(viewUid)));
    //     vmBloc
    //         ?.add(ViewManagerEvent.move(fromPosition: thisViewPos + 1, toPosition: hiddenViewPos));
    //   }
    // }

    List<FABIcon> offScreenViews(BuildContext menuContext, int viewUid) {
      // ignore: close_sinks
      final vmBloc = menuContext.viewManager;
      final vm = ViewManager.shared;
      final items = <FABIcon>[];
      for (final view in vmBloc?.state?.views) {
        if (!vmBloc.isViewVisible(view.uid)) {
          final title = vm.menuTitleWith(context: menuContext, state: view);
          items.add(FABIcon(
              title: title,
              onPressed: () {
                // for now, don't add functionality
                // _onSwitchViews(vmBloc, viewUid, view);
                // Navigator.of(menuContext).maybePop();
              },
              iconData: Icons.ac_unit));
          // items.add(tecModalPopupMenuItem(menuContext, vm.iconWithType(view.type), '$title', () {

          // }));
        }
      }
      return items;
    }

    return ExpandableFAB(
      icons: offScreenViews(
        context,
        context.viewManager.indexOfView(state.uid),
      ),
      backgroundColor: Const.tecartaBlue,
      mainIcon: TecIcons.tecartabiblelogo,
    );
  }
}

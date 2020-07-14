import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import 'main_sheet.dart';
import 'selection_sheet.dart';

// must have SheetManagerBloc provided
class SnapSheet extends StatefulWidget {
  final Widget body;

  const SnapSheet({
    @required this.body,
  }) : assert(body != null);

  @override
  _SnapSheetState createState() => _SnapSheetState();
}

// TODO(abby): save sheet size to prefs so open on default sizing
class _SnapSheetState extends State<SnapSheet> {
  SheetController _sheetController;
  @override
  void initState() {
    _sheetController = SheetController();
    super.initState();
  }

  List<double> _calculateHeightSnappings(Orientation orientation) {
    // figure out dimensions depending on view size
    final bottomPadding = MediaQuery.of(context).padding.bottom / 2 + 10;
    final topBarHeight = 50.0 + bottomPadding;
    final secondBarHeight = 170.0 + bottomPadding;
    final ratio = (topBarHeight / MediaQuery.of(context).size.height);
    final ratio2 = (secondBarHeight / MediaQuery.of(context).size.height);

    // debugPrint(ratio.toString());
    return [ratio, ratio + ratio2, 1.0];
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      final snappings = _calculateHeightSnappings(orientation);

      SheetSize _getSheetSize(double d) {
        final snap = snappings.indexWhere((s) => s == d);
        if (snap != -1) {
          return SheetSize.values[snap];
        }
        return null;
      }

      return BlocConsumer<SheetManagerBloc, SheetManagerState>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, state) {
            if (state.type == SheetType.collapsed) {
              _sheetController.hide();
            } else {
              _sheetController.snapToExtent(snappings[state.size.index]);
            }
          },
          builder: (context, state) {
            final widthOfScreen = MediaQuery.of(context).size.width;
            final wideView = widthOfScreen > 500;
            EdgeInsets margin;
            if (wideView) {
              margin = EdgeInsets.only(left: widthOfScreen / 5, right: widthOfScreen / 5);
            }

            return SafeArea(
              bottom: false,
              child: SlidingSheet(
                margin: margin,
                controller: _sheetController,
                elevation: 8,
                closeOnBackdropTap: state.type == SheetType.windows,
                cornerRadius: 15,
                duration: const Duration(milliseconds: 250),
                addTopViewPaddingOnFullscreen: true,
                snapSpec: SnapSpec(
                  initialSnap: snappings[state.size.index],
                  snappings: snappings,
                  onSnap: (s, snapPosition) {
                    final sheetSize = _getSheetSize(snapPosition);
                    if (sheetSize != null) {
                      context.bloc<SheetManagerBloc>().changeSize(sheetSize);
                    }
                  },
                  positioning: SnapPositioning.relativeToAvailableSpace,
                ),
                color: Theme.of(context).cardColor,
                builder: (c, s) {
                  Widget child;
                  switch (state.type) {
                    case SheetType.main:
                      child = MainSheet(key: ValueKey(state.size.index), sheetSize: state.size);
                      break;
                    case SheetType.selection:
                      child =
                          SelectionSheet(key: ValueKey(state.size.index), sheetSize: state.size);
                      break;
                    // case SheetType.windows:
                    //   child = WindowManagerSheet(
                    //       key: ValueKey(state.size.index), sheetSize: state.size);
                    //   break;
                    default:
                      child = Container();
                  }
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      child: AnimatedSwitcher(
                          switchInCurve: Curves.easeIn,
                          duration: const Duration(milliseconds: 250),
                          child: child));
                },
                body: widget.body,
                headerBuilder: (context, s) {
                  return InkWell(
                    onTap: () => context.bloc<SheetManagerBloc>().changeSize(
                        state.size == SheetSize.mini ? SheetSize.medium : SheetSize.mini),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 5,
                            width: 30,
                            decoration: ShapeDecoration(
                                color: Theme.of(context).textColor.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          });
    });
  }
}

///
/// Shared Widgets across different sheets
///
class SheetButton extends StatelessWidget {
  final String text;
  final IconData icon;
  const SheetButton({@required this.text, @required this.icon})
      : assert(text != null),
        assert(icon != null);
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 50,
      child: OutlineButton.icon(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          label: TecText(
            text,
            autoSize: true,
            style: TextStyle(
              color: Theme.of(context).textColor.withOpacity(0.8),
            ),
          ),
          icon: Icon(
            icon,
            size: 18,
            color: Theme.of(context).textColor.withOpacity(0.8),
          ),
          onPressed: () {}),
    );
  }
}

class GreyCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String title;
  const GreyCircleButton({@required this.icon, @required this.onPressed, this.title});
  @override
  Widget build(BuildContext context) {
    Widget circleIcon([double radius]) => Container(
        child: InkWell(
            onTap: onPressed ?? () {},
            child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.transparent,
                child: icon != null
                    ? Icon(
                        icon,
                        color: Colors.grey,
                        size: 20,
                      )
                    : null)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 5,
          ),
        ));
    return (title != null)
        ? Column(children: [
            Expanded(flex: 2, child: circleIcon(20)),
            Expanded(
                child: TecText(
              title,
              autoSize: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textColor.withOpacity(0.5),
              ),
            )),
          ])
        : circleIcon(15);
  }
}

class SheetIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  const SheetIconButton({this.onPressed, this.text, this.icon});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).textColor.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(height: 3),
          TecText(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

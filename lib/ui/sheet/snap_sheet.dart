import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/app_settings.dart';
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

class _SnapSheetState extends State<SnapSheet> {
  ValueNotifier<double> onDragValue;
  double mediumSheetHeight;
  double miniSheetHeight;
  List<double> snappings;

  List<double> _calculateHeightSnappings(SheetType sheetType) {
    // figure out dimensions depending on view size
    // dividing by 2 - they will overlay but looks nicer
    var androidExtraPadding = AppSettings.shared.navigationBarPadding / 2;

    if (MediaQuery.of(context).size.width > 500) {
      // buttons are spread out - reduce the height by another 50%
      androidExtraPadding = androidExtraPadding / 2;
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom / 2 + 10 + androidExtraPadding;

    if (sheetType == SheetType.main) {
      miniSheetHeight = 50.0 + bottomPadding;
      mediumSheetHeight = 155.0 + bottomPadding;
    } else {
      miniSheetHeight = 50.0 + bottomPadding;
      mediumSheetHeight = 240.0 + bottomPadding;
    }

    final height = MediaQuery.of(context).size.height;
    final ratio = (miniSheetHeight / height);
    final ratio2 = (mediumSheetHeight / height);

    // tec.dmPrint(ratio.toString());
    // removed full screen snap for now...
    return [ratio, ratio2];
  }

  @override
  Widget build(BuildContext context) {
    List<double> _dragOpacityValue(double value) {
      // as value goes from one snapping point to the next - adjust opacity
      // first and last 10% - opacity is 0 or 1.  middle 80% linear from 0 to 1

      final opacities = <double>[];

      final topValue = snappings[1];
      final bottomValue = snappings[0];
      final tenPercent = (topValue - bottomValue) * 0.1;
      final bottomCutOff = bottomValue + tenPercent;
      final topCutOff = topValue - tenPercent;

      // we're computing opacity of mini, medium would be 1 - mini...
      // this would need to be tweaked if we add a full screen mode
      double opacity;

      if (value <= bottomCutOff) {
        opacity = 1.0;
      } else if (value >= topCutOff) {
        opacity = 0.0;
      } else {
        opacity = 1 - (value - bottomCutOff) / (topCutOff - bottomCutOff);
      }

      opacity = math.min(1.0, math.max(opacity, 0.0));

      opacities.add(opacity); // mini sheet
      // ignore: cascade_invocations
      opacities.add(1.0 - opacity); // medium sheet

      return opacities;
    }

    // current sheet size
    SheetSize _getSheetSize(double d) {
      final snap = snappings.indexWhere((s) => s == d);
      if (snap != -1) {
        return SheetSize.values[snap];
      }
      return null;
    }

    final widthOfScreen = MediaQuery.of(context).size.width;
    final wideView = widthOfScreen > 500;
    EdgeInsets margin;
    if (wideView) {
      margin = EdgeInsets.only(left: widthOfScreen / 5, right: widthOfScreen / 5);
    }
    final s = context.bloc<SheetManagerBloc>().state;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          BlocBuilder<SheetManagerBloc, SheetManagerState>(
              condition: (previous, current) => previous.type != current.type,
              builder: (c, state) {
                Widget miniSheet, mediumSheet;

                switch (state.type) {
                  case SheetType.selection:
                    miniSheet = const SelectionSheet(sheetSize: SheetSize.mini);
                    mediumSheet = const SelectionSheet(sheetSize: SheetSize.medium);
                    break;
                  default:
                    miniSheet = const MainSheet(sheetSize: SheetSize.mini);
                    mediumSheet = const MainSheet(sheetSize: SheetSize.medium);
                }

                snappings = _calculateHeightSnappings(state.type);

                return SlidingSheet(
                  margin: margin,
                  elevation: 3,
                  closeOnBackdropTap: s.type == SheetType.windows,
                  cornerRadius: 15,
                  duration: const Duration(milliseconds: 250),
                  addTopViewPaddingOnFullscreen: true,
                  listener: (s) {
                    onDragValue.value = s.extent;
                  },
                  snapSpec: SnapSpec(
                    initialSnap: snappings[s.size.index],
                    snappings: snappings,
                    onSnap: (s, snapPosition) {
                      final sheetSize = _getSheetSize(snapPosition);
                      if (sheetSize != null) {
                        final prevSize = context.bloc<SheetManagerBloc>().state.size.index;
                        if (sheetSize.index != prevSize) {
                          context.bloc<SheetManagerBloc>().changeSize(sheetSize);
                        }
                      }
                    },
                    positioning: SnapPositioning.relativeToAvailableSpace,
                  ),
                  color: Theme.of(context).canvasColor,
                  builder: (c, s) {
                    return BlocBuilder<SheetManagerBloc, SheetManagerState>(
                        condition: (previous, current) {
                          // we never want to "rebuild" the sub-tree on state changes, that is
                          // handled above as we rebuild for each type switch to allow for
                          // different snap settings for the different sheet types

                          // might need to adjust snap though...
                          if (onDragValue.value != snappings[current.size.index]) {
                            SheetController.of(c).snapToExtent(snappings[current.size.index]);
                          }

                          return false;
                        },
                        builder: (c, s) {
                      return ValueListenableBuilder<double>(
                          valueListenable: onDragValue ??= ValueNotifier<double>(snappings.first),
                          builder: (_, value, __) {
                            final opacities = _dragOpacityValue(value);
                            return Container(
                              height: mediumSheetHeight,
                              child: Stack(
                                children: [
                                  if (opacities[0] > 0)
                                    Opacity(
                                      opacity: opacities[0],
                                      child: miniSheet,
                                    ),
                                  if (opacities[1] > 0)
                                    Opacity(
                                      opacity: opacities[1],
                                      child: mediumSheet,
                                    ),
                                ],
                              ),
                            );
                          });
                    });
                  },
                  body: widget.body,
                  headerBuilder: (c, s) {
                    return InkWell(
                      onTap: () {
                        final nextSize = c.bloc<SheetManagerBloc>().state.size == SheetSize.mini
                            ? SheetSize.medium
                            : SheetSize.mini;

                        c.bloc<SheetManagerBloc>().changeSize(nextSize);
                      },
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
                                  color: Theme.of(c).textColor.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
          if (AppSettings.shared.androidFullScreen)
            Container(
              alignment: Alignment.bottomCenter,
              child: AbsorbPointer(
                child: Container(height: 14, color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }
}

///
/// Shared Widgets across different sheets
///
class SheetButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const SheetButton({@required this.text, @required this.icon, @required this.onPressed})
      : assert(text != null),
        assert(icon != null),
        assert(onPressed != null);

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
            textScaleFactor: 0.8,
            style: TextStyle(
              color: Theme.of(context).textColor.withOpacity(0.8),
            ),
          ),
          icon: Icon(
            icon,
            size: 18,
            color: Theme.of(context).textColor.withOpacity(0.8),
          ),
          onPressed: onPressed,
        ));
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
            onTap: onPressed,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
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
              autoSize: true,
              textScaleFactor: 0.7,
              style: TextStyle(
                color: Theme.of(context).textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

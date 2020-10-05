import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import 'main_sheet.dart';
import 'selection_sheet.dart';
import 'selection_sheet_model.dart';

// must have SheetManagerBloc provided
class SnapSheet extends StatefulWidget {
  final Widget body;

  const SnapSheet({
    @required this.body,
  }) : assert(body != null);

  @override
  _SnapSheetState createState() => _SnapSheetState();
}

const _headerHeight = 21.0;

class _SnapSheetState extends State<SnapSheet> {
  ValueNotifier<double> onDragValue;
  double bottomPadding;
  List<double> snapOffsets;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<double> _dragOpacityValue(double value) {
      // as value goes from one snapping point to the next - adjust opacity
      // first and last 10% - opacity is 0 or 1.  middle 80% linear from 0 to 1

      final opacities = <double>[];

      final topValue = snapOffsets[1];
      final bottomValue = snapOffsets[0];
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
      // sheet sizes and snaps aren't always exactly the same - effected by device pixel density
      for (var i = 0; i < snapOffsets.length; i++) {
        if (d.round() == snapOffsets[i].round()) {
          return SheetSize.values[i];
        }
      }

      return null;
    }

    final size = MediaQuery.of(context).size;
    double maxWidth;

    // for phones max width is portrait width
    if (math.max(size.width, size.height) < 1000) {
      maxWidth = math.min(size.width, 450);
    }
    // for bigger devices max width is 460
    else {
      maxWidth = 460;
    }

    final s = context.bloc<SheetManagerBloc>().state;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          BlocConsumer<SheetManagerBloc, SheetManagerState>(
              listener: (c, state) {
                // on swipe down from selection sheet, deselect
                SelectionSheetModel.deselect(c);
              },
              listenWhen: (p, c) =>
                  p.type == SheetType.selection &&
                  c.type == SheetType.selection &&
                  c.size == SheetSize.mini,
              buildWhen: (previous, current) {
                if (previous.type != current.type) {
                  snapOffsets = [_headerHeight, size.height];
                }

                return (previous.type != current.type);
              },
              builder: (c, state) {
                final sheets = <Widget>[];
                final keys = <GlobalKey>[GlobalKey(), GlobalKey()];

                switch (state.type) {
                  case SheetType.selection:
                    sheets.add(SelectionSheet(key: keys[0], sheetSize: SheetSize.mini));
                    sheets.add(SelectionSheet(key: keys[1], sheetSize: SheetSize.medium));
                    break;
                  default:
                    sheets.add(MainSheet(key: keys[0], sheetSize: SheetSize.mini));
                    sheets.add(MainSheet(key: keys[1], sheetSize: SheetSize.medium));
                    break;
                }

                snapOffsets ??= [_headerHeight, size.height];

                return SlidingSheet(
                  maxWidth: maxWidth,
                  elevation: 3,
                  closeOnBackdropTap: s.type == SheetType.windows,
                  cornerRadius: 15,
                  duration: const Duration(milliseconds: 250),
                  addTopViewPaddingOnFullscreen: true,
                  listener: (s) {
                    onDragValue.value = s.extent;
                    // debugPrint('${onDragValue.value}');
                    // need to figure out how to catch a mode change when a full drag happened...
                  },
                  closeOnBackButtonPressed: true,
                  snapSpec: SnapSpec(
                    initialSnap: snapOffsets[s.size.index],
                    snappings: snapOffsets,
                    onSnap: (s, snapPosition) {
                      final sheetSize = _getSheetSize(snapPosition);
                      if (sheetSize != null) {
                        final prevSize = context.bloc<SheetManagerBloc>().state.size.index;
                        if (sheetSize.index != prevSize) {
                          context.bloc<SheetManagerBloc>().changeSize(sheetSize);
                        }
                      }
                    },
                    positioning: SnapPositioning.pixelOffset,
                  ),
                  color: Theme.of(context).canvasColor,
                  builder: (c, s) {
                    return BlocBuilder<SheetManagerBloc, SheetManagerState>(
                        buildWhen: (previous, current) {
                      // we never want to "rebuild" the sub-tree on state changes, that is
                      // handled above as we rebuild for each type switch to allow for
                      // different snap settings for the different sheet types

                      // might need to adjust snap though...
                      if (onDragValue.value.round() != snapOffsets[current.size.index].round()) {
                        SheetController.of(c).snapToExtent(snapOffsets[current.size.index]);
                      }

                      return false;
                    }, builder: (c, s) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        var changed = false;
                        final offsets = <double>[];

                        for (final i in [0, 1]) {
                          if (keys[i].currentContext != null) {
                            final height = (keys[i].currentContext.findRenderObject() as RenderBox)
                                    .size
                                    .height +
                                _headerHeight +
                                TecScaffoldWrapper.navigationBarPadding;
                            offsets.add(height);
                            if (height != snapOffsets[i]) {
                              changed = true;
                            }
                          }
                        }

                        if (changed) {
                          setState(() {
                            snapOffsets = offsets;
                          });

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SheetController.of(c).rebuild();
                            final extent = snapOffsets[
                                (c.bloc<SheetManagerBloc>().state.size == SheetSize.mini) ? 0 : 1];
                            SheetController.of(c).snapToExtent(extent);
                          });
                        }
                      });

                      return ValueListenableBuilder<double>(
                          valueListenable: onDragValue ??= ValueNotifier<double>(snapOffsets.first),
                          builder: (_, value, __) {
                            final opacities = _dragOpacityValue(value);

                            return Container(
                              height: snapOffsets[1] - _headerHeight,
                              constraints: BoxConstraints.loose(size),
                              child: Stack(
                                children: [
                                  IgnorePointer(
                                    ignoring: opacities[0] == 0,
                                    child: Opacity(
                                      opacity: opacities[0],
                                      child: sheets[0],
                                    ),
                                  ),
                                  IgnorePointer(
                                    ignoring: opacities[1] == 0,
                                    child: Opacity(
                                      opacity: opacities[1],
                                      child: sheets[1],
                                    ),
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
                        // NOTICE: adjust the _headerHeight variable at the top of this
                        // class if you adjust this padding
                        padding: const EdgeInsets.all(8),
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

class SelectionSheetButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String title;

  const SelectionSheetButton({@required this.icon, @required this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    Widget iconButton() => Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            icon,
            color: Colors.grey,
            size: 20,
          ),
        );
    return (title != null)
        ? InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              iconButton(),
              const SizedBox(height: 2),
              TecText(
                title,
                autoSize: true,
                textAlign: TextAlign.center,
                textScaleFactor: 0.9,
                maxLines: 1,
                style: Theme.of(context).textTheme.caption.copyWith(
                      color: Theme.of(context).textColor.withOpacity(0.5),
                    ),
              ),
            ]))
        : InkWell(onTap: onPressed, customBorder: const CircleBorder(), child: iconButton());
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
          mainAxisSize: MainAxisSize.min,
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

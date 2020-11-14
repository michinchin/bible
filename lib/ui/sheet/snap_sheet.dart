import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
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

const _headerHeight = 10.0;

class _SnapSheetState extends State<SnapSheet> {
  List<double> snapOffsets;
  List<Widget> sheets;
  List<GlobalKey> keys;

  @override
  void initState() {
    super.initState();
    keys = <GlobalKey>[GlobalKey(), GlobalKey()];
    sheets = <Widget>[MainSheet(key: keys[0]), SelectionSheet(key: keys[1])];
  }

  @override
  Widget build(BuildContext context) {
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

    snapOffsets ??= [_headerHeight, size.height];

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
      }
    });

    return SafeArea(
        bottom: false,
        child: SlidingSheet(
          maxWidth: maxWidth,
          elevation: 3,
          cornerRadius: 15,
          duration: const Duration(milliseconds: 250),
          addTopViewPaddingOnFullscreen: true,
          headerBuilder: (c, s) {
            return Container(height: 10);
          },
          closeOnBackButtonPressed: true,
          snapSpec: SnapSpec(
            initialSnap: snapOffsets[0],
            snappings: snapOffsets,
            positioning: SnapPositioning.pixelOffset,
          ),
          color: Theme.of(context).canvasColor,
          builder: (c, s) {
            return Container(
              height: snapOffsets[1] - _headerHeight,
              constraints: BoxConstraints.loose(size),
              child: BlocConsumer<SheetManagerBloc, SheetManagerState>(
                listener: (c, state) {
                  // on swipe down from selection sheet, deselect
                  // SelectionSheetModel.deselect(c);
                  SheetController.of(c)
                      .snapToExtent(snapOffsets[(state.type == SheetType.main) ? 0 : 1]);
                  debugPrint('hi mom');
                },
                builder: (c, state) {
                  return Stack(
                    children: [
                      IgnorePointer(
                        ignoring: state.type == SheetType.selection,
                        child: Opacity(
                          opacity: state.type == SheetType.main ? 1.0 : 0,
                          child: sheets[0],
                        ),
                      ),
                      IgnorePointer(
                        ignoring: state.type == SheetType.main,
                        child: Opacity(
                          opacity: state.type == SheetType.selection ? 1.0 : 0.0,
                          child: sheets[1],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
          body: widget.body,
        ));
  }

/*
  Widget bob() {
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

                sheets.add(MainSheet(key: keys[0]));
                // ignore: cascade_invocations
                sheets.add(SelectionSheet(key: keys[1]));

                snapOffsets ??= [_headerHeight, size.height];

                return SlidingSheet(
                  maxWidth: maxWidth,
                  elevation: 3,
                  cornerRadius: 15,
                  duration: const Duration(milliseconds: 250),
                  addTopViewPaddingOnFullscreen: true,
                  headerBuilder: (c, s) {
                    return Container(height: 10);
                  },
                  closeOnBackButtonPressed: true,
                  snapSpec: SnapSpec(
                    initialSnap: snapOffsets[state.size.index],
                    snappings: snapOffsets,
                    onSnap: (s, snapPosition) {
                      final sheetSize = _getSheetSize(snapPosition);
                      if (sheetSize != null) {
                        final prevSize = state.size.index;
                        if (sheetSize.index != prevSize) {
                          context.read<SheetManagerBloc>().changeSize(sheetSize);
                        }
                      }
                    },
                    positioning: SnapPositioning.pixelOffset,
                  ),
                  color: Theme.of(context).canvasColor,
                  builder: (c, s) {
                    return BlocBuilder<SheetManagerBloc, SheetManagerState>(
                        buildWhen: (prev, current) {
                      // we never want to "rebuild" the sub-tree on state changes, that is
                      // handled above as we rebuild for each type switch to allow for
                      // different snap settings for the different sheet types

                      // might need to adjust snap though...
                      if (prev.type != current.type) {
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
                            final extent = snapOffsets[(state.size == SheetSize.mini) ? 0 : 1];
                            SheetController.of(c).snapToExtent(extent);
                          });
                        }
                      });

                      return Container(
                        height: snapOffsets[1] - _headerHeight,
                        constraints: BoxConstraints.loose(size),
                        child: Stack(
                          children: [
                            IgnorePointer(
                              ignoring: state.type == SheetType.selection,
                              child: Opacity(
                                opacity: state.type == SheetType.main ? 1.0 : 0,
                                child: sheets[0],
                              ),
                            ),
                            IgnorePointer(
                              ignoring: state.type == SheetType.main,
                              child: Opacity(
                                opacity: state.type == SheetType.selection ? 1.0 : 0.0,
                                child: sheets[1],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                  body: widget.body,
                );
              }),
        ],
      ),
    );
  }
   */
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
          padding: EdgeInsets.zero,
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
    Widget iconButton() =>
        // Padding(
        // padding: const EdgeInsets.all(5),
        // child:
        Icon(
          icon,
          color: Colors.grey,
          size: 20,
          // ),
        );
    return (title != null)
        ? InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              iconButton(),
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
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

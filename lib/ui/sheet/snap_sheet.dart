import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/pref_items_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/pref_item.dart';
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

  ValueNotifier<double> onDragValue;

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

      double _dragOpacityValue(double value, SheetSize size) {
        // value should always approach 0
        // when reaches snapping point should be 1
        bool approxEqual(double a, double b) => (a * 100).round() == (b * 100).round();

        if (approxEqual(value, snappings[size.index])) {
          return 1.0;
        }

        if (value < snappings[size.index]) {
          //decreasing in height
          final opacity = 1 -
              (snappings[size.index] - value) / (snappings[size.index] - snappings[size.index - 1]);
          return opacity <= 0 ? 0 : opacity;
        } else {
          // increasing in height
          final opacity = 1 -
              (value - snappings[size.index]) / (snappings[size.index + 1] - snappings[size.index]);
          return opacity <= 0 ? 0 : opacity;
        }
      }

      // current sheet size
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
                elevation: 3,
                closeOnBackdropTap: state.type == SheetType.windows,
                cornerRadius: 15,
                duration: const Duration(milliseconds: 250),
                addTopViewPaddingOnFullscreen: true,
                listener: (s) {
                  onDragValue.value = s.extent;
                },
                snapSpec: SnapSpec(
                  initialSnap: snappings[state.size.index],
                  snappings: snappings,
                  onSnap: (s, snapPosition) {
                    final sheetSize = _getSheetSize(snapPosition);
                    // only snap to one size up (i.e. can't fling to full from mini)
                    if (sheetSize != null) {
                      final prevSize = state.size.index;
                      if (sheetSize.index != prevSize) {
                        // will snap accordingly on one sized down and on drag down
                        if (sheetSize.index - 1 == prevSize || sheetSize.index < prevSize) {
                          context.bloc<SheetManagerBloc>().changeSize(sheetSize);
                          // if trying to go from mini to full, then only allow medium
                        } else if (sheetSize.index <= SheetSize.full.index &&
                            prevSize < SheetSize.full.index) {
                          context
                              .bloc<SheetManagerBloc>()
                              .changeSize(SheetSize.values[prevSize + 1]);
                        }
                      }
                    }
                  },
                  positioning: SnapPositioning.relativeToAvailableSpace,
                ),
                color: Theme.of(context).cardColor,
                builder: (c, s) {
                  Widget child;
                  switch (state.type) {
                    case SheetType.main:
                      child = MainSheet(sheetSize: state.size);
                      break;
                    case SheetType.selection:
                      child = BlocProvider<PrefItemsBloc>(
                          create: (context) =>
                              PrefItemsBloc(prefItemsType: PrefItemType.customColors),
                          child: SelectionSheet(sheetSize: state.size, onDragValue: onDragValue));
                      break;
                    // case SheetType.windows:
                    //   child = WindowManagerSheet(
                    //       key: ValueKey(state.size.index), sheetSize: state.size);
                    //   break;
                    default:
                      return Container();
                  }
                  return ValueListenableBuilder<double>(
                      valueListenable: onDragValue ??= ValueNotifier<double>(snappings.first),
                      child: Container(height: MediaQuery.of(context).size.height, child: child),
                      builder: (_, value, c) =>
                          Opacity(opacity: _dragOpacityValue(value, state.size), child: c));
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

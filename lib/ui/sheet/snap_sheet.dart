import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import 'main_sheet.dart';
import 'selection_sheet.dart';
import 'window_manager_sheet.dart';

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

  List<double> _calculateHeightSnappings() {
    // figure out dimensions depending on view size
    const topBarHeight = 35.0;
    const secondBarHeight = 80.0;
    final ratio = (topBarHeight / MediaQuery.of(context).size.height) + 0.1;
    final ratio2 = (secondBarHeight / MediaQuery.of(context).size.height) + 0.1;

    // debugPrint(ratio.toString());
    return [0, ratio, ratio + ratio2, 1.0];
  }

  @override
  Widget build(BuildContext context) {
    final snappings = _calculateHeightSnappings();

    SheetSize _getSheetSize(double d) => SheetSize.values[snappings.indexWhere((s) => s == d)];

    return BlocConsumer<SheetManagerBloc, SheetManagerState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state.size == SheetSize.collapsed) {
            context.bloc<SelectionBloc>().clearVerses();
          }
          _sheetController.snapToExtent(snappings[state.size.index]);
        },
        builder: (context, state) {
          return SlidingSheet(
              controller: _sheetController,
              elevation: 8,
              cornerRadius: 15,
              duration: const Duration(milliseconds: 250),
              addTopViewPaddingOnFullscreen: true,
              snapSpec: SnapSpec(
                initialSnap: snappings[state.size.index],
                snappings: snappings,
                onSnap: (s, snapPosition) =>
                    context.bloc<SheetManagerBloc>().changeSize(_getSheetSize(snapPosition)),
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
                    child = SelectionSheet(sheetSize: state.size);
                    break;
                  case SheetType.windows:
                    child = WindowManagerSheet(sheetSize: state.size);
                    break;
                }
                return Container(height: MediaQuery.of(context).size.height, child: child);
              },
              body: widget.body,
              headerBuilder: (context, state) {
                return Container(
                  width: 30,
                  height: 5,
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: ShapeDecoration(
                      color: Theme.of(context).textColor.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          label: Text(text),
          icon: Icon(
            icon,
            size: 18,
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
            customBorder: const CircleBorder(),
            onTap: onPressed ?? () {},
            child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.transparent,
                child: icon != null
                    ? Icon(
                        icon,
                        color: Colors.grey,
                      )
                    : null)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 5,
          ),
        ));
    return Column(
      children: [
        if (title != null) ...[
          Expanded(flex: 3, child: circleIcon(30)),
          Expanded(
              flex: 2,
              child: TecText(
                title,
                autoSize: true,
              )),
        ] else
          circleIcon(),
      ],
    );
  }
}

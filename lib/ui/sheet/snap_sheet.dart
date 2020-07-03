import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_widgets/tec_widgets.dart';

enum SheetSize { mini, medium, full }

class SnapSheet extends StatefulWidget {
  final Widget body;
  final Widget Function(BuildContext context, SheetSize sheetSize) builder;
  final SheetSize initialSize;

  const SnapSheet({
    @required this.builder,
    @required this.body,
    this.initialSize = SheetSize.mini,
  })  : assert(builder != null),
        assert(body != null);

  @override
  _SnapSheetState createState() => _SnapSheetState();
}

// TODO(abby): save sheet size to prefs so open on default sizing
class _SnapSheetState extends State<SnapSheet> {
  ValueNotifier<SheetSize> _snapChange;
  SheetController _sheetController;
  @override
  void initState() {
    _snapChange = ValueNotifier(SheetSize.mini);
    _sheetController = SheetController();
    super.initState();
  }

  List<double> _calculateHeightSnappings() {
    // figure out dimensions depending on view size
    const topBarHeight = 30.0;
    const secondBarHeight = 80.0;
    final ratio = (topBarHeight / MediaQuery.of(context).size.height) + 0.1;
    final ratio2 = (secondBarHeight / MediaQuery.of(context).size.height) + 0.1;

    debugPrint(ratio.toString());
    return [ratio, ratio + ratio2, 1.0];
  }

  @override
  Widget build(BuildContext context) {
    final snappings = _calculateHeightSnappings();

    SheetSize _getSheetType(double d) => SheetSize.values[snappings.indexWhere((s) => s == d)];

    return SlidingSheet(
        controller: _sheetController,
        elevation: 8,
        cornerRadius: 15,
        isBackdropInteractable: false,
        duration: const Duration(milliseconds: 250),
        addTopViewPaddingOnFullscreen: true,
        snapSpec: SnapSpec(
          initialSnap: snappings[widget.initialSize.index],
          snappings: snappings,
          onSnap: (s, snapPosition) => _snapChange.value = _getSheetType(snapPosition),
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        color: Theme.of(context).cardColor,
        builder: (c, state) {
          return ValueListenableBuilder<SheetSize>(
              valueListenable: _snapChange,
              builder: (c, sheetType, _) {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: widget.builder(c, sheetType));
              });
        },
        body: widget.body,
        headerBuilder: (context, state) {
          return Container(
            width: 30,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: ShapeDecoration(
                color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          );
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

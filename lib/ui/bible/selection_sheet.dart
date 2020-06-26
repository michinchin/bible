import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/selection/selection_bloc.dart';
import '../../models/labels.dart';

class SelectionSheet extends StatefulWidget {
  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> {
  final colors = [
    Colors.pink,
    Colors.deepOrange,
    Colors.amber,
    Colors.green,
    Colors.cyan,
    Colors.indigo
  ];

  final primaries = Colors.primaries +
      Colors.primaries +
      Colors.primaries +
      Colors.primaries +
      Colors.primaries +
      Colors.primaries;

  final icons = [
    FeatherIcons.underline,
    FeatherIcons.edit,
    FeatherIcons.share,
    FeatherIcons.copy,
    FeatherIcons.bookmark,
    Icons.lightbulb_outline,
    Icons.compare_arrows,
    FeatherIcons.compass
  ];

  final buttons = <String, IconData>{
    'Copy': FeatherIcons.copy,
    'Note': FeatherIcons.edit,
    'Share': FeatherIcons.share,
    // 'Learn': Icons.lightbulb_outline,
    // 'Compare': FeatherIcons.compass
  };

  bool _isFullSized;
  bool _showAllColors;

  @override
  void initState() {
    _isFullSized = tec.Prefs.shared.getBool(Labels.prefSelectionSheetFullSize, defaultValue: false);
    _showAllColors = false;
    super.initState();
  }

  void onExpanded() {
    setState(() {
      _isFullSized = !_isFullSized;
      tec.Prefs.shared.setBool(Labels.prefSelectionSheetFullSize, _isFullSized);
      // if (!_isFullSized && _showAllColors) {
      //   _showAllColors = !_showAllColors;
      // }
    });
  }

  void onShowAllColors() {
    setState(() {
      _showAllColors = !_showAllColors;
      if (_showAllColors && !_isFullSized || !_showAllColors && _isFullSized) {
        _isFullSized = !_isFullSized;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _colors = List<Color>.from(colors);
    // var _icons = List<IconData>.from(icons);
    if (!_isFullSized) {
      _colors = _colors.take(3).toList();
      // _icons = _icons.take(3).toList();
    }

    const vDiv = VerticalDivider(
      color: Colors.transparent,
      width: 10,
    );

    final sheetChildren = [
      // _ClearHighlightButton(context: context),
      _GreyCircleButton(
        icon: Icons.format_color_reset,
        onPressed: () => context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
              type: HighlightType.clear,
            )),
      ),
      for (final color in _colors) ...[
        _ColorPickerButton(
          context: context,
          color: color,
        ),
      ],
      // _GreyCircleButton(
      //   icon: Icons.color_lens,
      //   onPressed: onShowAllColors,
      // ),
      // vDiv,
      for (final each in icons) ...[
        _GreyCircleButton(icon: each, onPressed: () {}),
      ],
    ];

    Widget sheet() => Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: sheetChildren.length,
          itemBuilder: (c, i) => sheetChildren[i],
          separatorBuilder: (c, i) => vDiv,
        ));

    return _RoundedCornerSheet(
      isFullSized: _isFullSized,
      showAllColors: _showAllColors,
      onExpanded: onExpanded,
      child: Column(
        children: [
          if (_isFullSized && !_showAllColors) ...[
            Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final each in buttons.keys) ...[
                        Expanded(
                          child: _SheetButton(text: each, icon: buttons[each]),
                        ),
                        if (buttons.keys.last != each) const SizedBox(width: 10)
                      ]
                    ],
                  ),
                )),
            const Divider(
              color: Colors.transparent,
            )
          ],
          Expanded(
              child: _showAllColors
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(children: [
                        Expanded(
                          child: Wrap(
                            children: [
                              for (final each in primaries)
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Container(
                                    color: each,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _GreyCircleButton(
                          icon: Icons.close,
                          onPressed: onShowAllColors,
                        ),
                      ]),
                    )
                  : sheet()),
          if (!_isFullSized) const Divider(color: Colors.transparent),
        ],
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  final BuildContext context;
  final Color color;
  const _ColorPickerButton({@required this.context, @required this.color})
      : assert(context != null),
        assert(color != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => context
          .bloc<SelectionStyleBloc>()
          ?.add(SelectionStyle(type: HighlightType.highlight, color: color.value)),
      child: CircleAvatar(
        backgroundColor: color,
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SheetButton({@required this.text, @required this.icon})
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

class _ClearHighlightButton extends StatelessWidget {
  final BuildContext context;
  const _ClearHighlightButton({@required this.context}) : assert(context != null);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
            type: HighlightType.clear,
          )),
      child: ClipOval(
          child: CustomPaint(painter: DiagonalLinePainter(), child: const _GreyCircleButton())),
    );
  }
}

class _GreyCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _GreyCircleButton({this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed ?? () {},
      child: Container(
          child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: icon != null
                  ? Icon(
                      icon,
                      color: Colors.grey,
                    )
                  : null),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 5,
            ),
          )),
    );
  }
}

class _RoundedCornerSheet extends StatelessWidget {
  final Widget child;
  final bool isFullSized;
  final bool showAllColors;
  final VoidCallback onExpanded;
  const _RoundedCornerSheet(
      {@required this.child,
      this.isFullSized = true,
      this.showAllColors = false,
      @required this.onExpanded})
      : assert(child != null);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final dy = details.velocity.pixelsPerSecond.dy;
        // debugPrint(dy.toString());
        if (dy > 0) {
          Navigator.of(context).pop();
        } else if (isFullSized && dy >= 0 || !isFullSized && dy <= 0) {
          onExpanded();
        }
      },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          height: isFullSized ? 200 : 100,
          // margin: const EdgeInsets.fromLTRB(100, 0, 100, 0),
          decoration: ShapeDecoration(
              shadows: Theme.of(context).brightness == Brightness.light
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
              color: Theme.of(context).canvasColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                topLeft: Radius.circular(15),
              ))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: AppBar(
                centerTitle: true,
                backgroundColor: Colors.transparent,
                leading: Container(),
                elevation: 0,
                title: Container(
                  width: 50,
                  height: 5,
                  // isFullSized ? 5 : 25
                  // child: IconButton(
                  //   padding: const EdgeInsets.all(0),
                  //   icon: Icon(!isFullSized
                  //       ? FeatherIcons.chevronUp
                  //       : FeatherIcons.chevronDown),
                  //   color: Colors.grey,
                  //   onPressed: onExpanded,
                  // ),
                  decoration: ShapeDecoration(
                      color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                ),
              ),
            ),
            body: SafeArea(child: child),
          )),
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final startingPoint = Offset(0, size.height);
    final endingPoint = Offset(size.width, 0);

    canvas.drawLine(startingPoint, endingPoint, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

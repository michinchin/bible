import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/color_utils.dart';
import '../../ui/sheet/snap_sheet.dart';

class SelectionSheet extends StatefulWidget {
  final SheetSize sheetSize;

  // final bool fullyExpanded;
  const SelectionSheet({this.sheetSize, Key key}) : super(key: key);

  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> {
//  List<Color> defaultColors = [];
//  List<Color> secondaryColors = [];

  final buttons = <String, IconData>{
    'Learn': Icons.lightbulb_outline,
    'Explore': FeatherIcons.compass,
    'Compare': Icons.compare_arrows,
    'Define': FeatherIcons.bookOpen,
    // 'Copy': FeatherIcons.copy,
    // 'Note': FeatherIcons.edit2,
    'Audio': FeatherIcons.play,
    'Save': FeatherIcons.bookmark,
    'Print': FeatherIcons.printer,
    'Text': FeatherIcons.messageCircle,
    'Email': FeatherIcons.mail,
    'Facebook': FeatherIcons.facebook,
    'Twitter': FeatherIcons.twitter
  };

  final medButtons = <String, IconData>{
    'Compare': Icons.compare_arrows,
    'Define': FeatherIcons.bookOpen,
  };

  final keyButtons = <String, IconData>{
    'Note': FeatherIcons.edit,
    'Share': FeatherIcons.share,
    // 'Learn': Icons.lightbulb_outline,
    // 'Compare': FeatherIcons.compass
  };

  // bool _showAllColors;
  bool _underlineMode;

  // StreamSubscription<ThemeMode> _themeChangeStream;

  @override
  void initState() {
    //_addColors();
    // _themeChangeStream = context.bloc<ThemeModeBloc>().listen(_listenForThemeChange);

    // _showAllColors = false;
    _underlineMode = false;
    super.initState();
  }

  @override
  void dispose() {
    // _themeChangeStream.cancel();
    super.dispose();
  }

//  List<Color> _addColors() {
//    final colors = <Color>[];
//    for (var i = 1; i < 5; i++) {
//      colors.add(
//          tec.colorFromColorId(i, darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
//    }
//    for (var i = 6; i < 13; i++) {
//      colors.add(
//          tec.colorFromColorId(i, darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
//    }
//    return colors;
//  }

//  void _listenForThemeChange(ThemeMode mode) {
//    final colors = _addColors();
//    setState(() {
//      defaultColors = colors.getRange(0, 4).toList();
//      secondaryColors = colors.getRange(4, colors.length).toList();
//    });
//  }

  void onShowAllColors() {
    TecToast.show(context, 'this is moving to a dialog');
//    setState(() {
//      _showAllColors = !_showAllColors;
//    });
  }

  void onSwitchToUnderline() {
    setState(() {
      _underlineMode = !_underlineMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final editColorsButton = GreyCircleButton(
      icon: /* _showAllColors ? Icons.close : */ Icons.colorize,
      onPressed: onShowAllColors,
    );
    final underlineButton = GreyCircleButton(
      icon: _underlineMode ? FeatherIcons.edit3 : FeatherIcons.underline,
      onPressed: onSwitchToUnderline,
    );
    final noColorButton = GreyCircleButton(
      icon: Icons.format_color_reset,
      onPressed: () => context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
            type: HighlightType.clear,
          )),
    );
    final expandButton = GreyCircleButton(
      icon: Icons.keyboard_arrow_up,
      onPressed: () => context.bloc<SheetManagerBloc>().changeSize(SheetSize.medium),
    );

    final defaultColors = <Color>[
      Color(defaultColorIntForIndex(1)),
      Color(defaultColorIntForIndex(2)),
      Color(defaultColorIntForIndex(3)),
      Color(defaultColorIntForIndex(4)),
    ];
//    for (var i = 1; i < 5; i++) {
//      colors.add(
//          tec.colorFromColorId(i, darkMode: false));
//    }

    final smallScreen = MediaQuery.of(context).size.width < 350;
    final miniViewColors = smallScreen ? defaultColors.take(2) : defaultColors;

    final colors = [
//      if (_showAllColors) ...[
//        Row(children: [
//          Expanded(child: _ColorSlider(isUnderline: _underlineMode)),
//          noColorButton,
//          const SizedBox(width: 5),
//          underlineButton,
//          const SizedBox(width: 5),
//          editColorsButton
//        ])
//      ] else ...[
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        noColorButton,
        underlineButton,
        for (final color in defaultColors) ...[
          _ColorPickerButton(
            isForUnderline: _underlineMode,
            color: color,
          ),
        ],
        editColorsButton,
      ]),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.spaceAround,
//          children: [
//            for (final color in secondaryColors) ...[
//              _ColorPickerButton(
//                isForUnderline: _underlineMode,
//                color: color,
//              ),
//            ],
//          ],
//        )
//      ],
    ];
    final mediumViewChildren = <Widget>[
      ...colors,
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final each in medButtons.keys) ...[
            Expanded(
              child: SheetButton(text: each, icon: medButtons[each]),
            ),
            if (buttons.keys.last != each) const SizedBox(width: 10)
          ]
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final each in keyButtons.keys) ...[
            Expanded(
              child: SheetButton(text: each, icon: keyButtons[each]),
            ),
            if (buttons.keys.last != each) const SizedBox(width: 10)
          ]
        ],
      ),
    ];

    final miniChildren = [
      noColorButton,
      underlineButton,
      for (final color in miniViewColors) ...[
        _ColorPickerButton(
          isForUnderline: _underlineMode,
          color: color,
        ),
      ],
      for (final button in keyButtons.keys) ...[
        GreyCircleButton(
          icon: keyButtons[button],
          onPressed: () {},
        ),
      ],
      expandButton,
    ];

    Widget _miniView() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: miniChildren);
    // : Row(children: [
    //     Expanded(child: _ColorSlider(isUnderline: _underlineMode)),
    //     noColorButton,
    //     const SizedBox(width: 5),
    //     underlineButton,
    //     const SizedBox(width: 5),
    //     showColorsButton
    //   ]);

    Widget _mediumView() => Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          runSpacing: 10,
          children: mediumViewChildren,
        );

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(children: [
        if (widget.sheetSize == SheetSize.mini)
          Expanded(child: _miniView())
        else if (widget.sheetSize == SheetSize.medium)
          _mediumView()
        else if (widget.sheetSize == SheetSize.full) ...[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            runSpacing: 10,
            children: colors,
          ),
          const Divider(
            color: Colors.transparent,
            height: 10,
          ),
          // if (!widget.fullyExpanded)
          const Divider(color: Colors.transparent),
          Expanded(
            child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.only(top: 0),
                children: [
                  for (final each in buttons.keys) ...[
                    GreyCircleButton(
                      icon: buttons[each],
                      onPressed: () {},
                      title: each,
                    ),
                  ],
                ]),
          ),
        ]
      ]),
    );
  }
}

/*
class _ColorSlider extends StatefulWidget {
  final bool isUnderline;
  const _ColorSlider({this.isUnderline});
  @override
  __ColorSliderState createState() => __ColorSliderState();
}

class __ColorSliderState extends State<_ColorSlider> {
  List<Color> allColors = [];
  double _colorValue;
  bool _canEnd;
  StreamSubscription<ThemeMode> _themeChangeStream;

  @override
  void initState() {
    allColors = _addColors();
    _themeChangeStream = context.bloc<ThemeModeBloc>().listen(_listenForThemeChange);
    _colorValue = 0;
    super.initState();
  }

  @override
  void dispose() {
    _themeChangeStream.cancel();
    _themeChangeStream = null;
    super.dispose();
  }

  List<Color> _addColors() {
    final colors = <Color>[];
    for (var i = 6; i < 365; i++) {
      colors.add(
          tec.colorFromColorId(i, darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
    }
    return colors;
  }

  void _listenForThemeChange(ThemeMode mode) {
    final colors = _addColors();
    setState(() {
      allColors = colors;
    });
  }

  void changeColor(double value) {
    context.bloc<SelectionStyleBloc>()?.add(
          SelectionStyle(
              type: widget.isUnderline ? HighlightType.underline : HighlightType.highlight,
              color: allColors[_colorValue.toInt()].value,
              isTrialMode: true),
        );
    setState(() {
      _colorValue = value;
      _canEnd = true;
    });
  }

  void finishWithColor(double value) {
    if (_canEnd) {
      context.bloc<SelectionStyleBloc>()?.add(
            SelectionStyle(
              type: widget.isUnderline ? HighlightType.underline : HighlightType.highlight,
              color: allColors[_colorValue.toInt()].value,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Stack(alignment: Alignment.center, children: [
        Container(
          height: 20,
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              gradient: LinearGradient(colors: allColors)),
        ),
        GestureDetector(
            onTapCancel: () {
              _canEnd = false;
            },
            child: SliderTheme(
                data: SliderThemeData(
                    thumbColor: allColors[_colorValue.toInt()],
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    activeTickMarkColor: Colors.green,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20)),
                child: Slider(
                  onChanged: changeColor,
                  onChangeEnd: finishWithColor,
                  value: _colorValue,
                  min: 0,
                  max: 358,
                ))),
      ]),
    );
  }
}
*/

class _ColorPickerButton extends StatelessWidget {
  final bool isForUnderline;
  final Color color;
  final bool deletionMode;
  final VoidCallback onDeletion;
  final bool editMode;
  final VoidCallback onEdit;

  const _ColorPickerButton(
      {@required this.color,
      this.isForUnderline = false,
      this.deletionMode = false,
      this.editMode = false,
      this.onDeletion,
      this.onEdit})
      : assert(color != null);

  @override
  Widget build(BuildContext context) {
    const width = 15.0;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        if (deletionMode) {
          onDeletion();
        } else if (editMode) {
          onEdit();
        } else {
          context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                type: (isForUnderline) ? HighlightType.underline : HighlightType.highlight,
                color: color.value,
              ));
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isForUnderline)
            Container(
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: color),
              width: 35,
              height: width,
            )
          else
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 5,
                  )),
              child: CircleAvatar(
                backgroundColor: color,
                radius: width,
              ),
            ),
          if (deletionMode)
            Icon(
              FeatherIcons.trash,
              color: Theme.of(context).textColor.withOpacity(0.5),
              size: width,
            )
          else if (editMode)
            Icon(
              Icons.colorize,
              color: Theme.of(context).textColor.withOpacity(0.5),
              size: width,
            ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../ui/sheet/snap_sheet.dart';

class SelectionSheet extends StatefulWidget {
  final SheetSize sheetSize;
  // final bool fullyExpanded;
  const SelectionSheet({this.sheetSize});
  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> {
  List<Color> mainColors = [];

  final buttons = <String, IconData>{
    'Learn': Icons.lightbulb_outline,
    'Explore': FeatherIcons.compass,
    'Compare': Icons.compare_arrows,
    'Define': FeatherIcons.bookOpen,
    // 'Copy': FeatherIcons.copy,
    // 'Note': FeatherIcons.edit2,
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
    'Audio': FeatherIcons.play,
    'Note': FeatherIcons.edit,
    'Share': FeatherIcons.share,
    // 'Learn': Icons.lightbulb_outline,
    // 'Compare': FeatherIcons.compass
  };

  bool _showAllColors;
  bool _underlineMode;
  StreamSubscription<ThemeMode> _themeChangeStream;

  @override
  void initState() {
    _addColors();
    _themeChangeStream = context.bloc<ThemeModeBloc>().listen(_listenForThemeChange);

    _showAllColors = false;
    _underlineMode = false;
    super.initState();
  }

  @override
  void dispose() {
    _themeChangeStream.cancel();
    super.dispose();
  }

  List<Color> _addColors() {
    final colors = <Color>[];
    for (var i = 1; i < 11; i++) {
      colors.add(
          tec.colorFromColorId(i, darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
    }
    return colors;
  }

  void _listenForThemeChange(ThemeMode mode) {
    setState(() {
      mainColors = _addColors();
    });
  }

  void onShowAllColors() {
    setState(() {
      _showAllColors = !_showAllColors;
    });
  }

  void onSwitchToUnderline() {
    setState(() {
      _underlineMode = !_underlineMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showColorsButton = GreyCircleButton(
      icon: _showAllColors ? Icons.close : Icons.color_lens,
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
    final colors = [
      if (_showAllColors) ...[
        Row(children: [
          Expanded(child: _ColorSlider(isUnderline: _underlineMode)),
          noColorButton,
          const SizedBox(width: 5),
          underlineButton,
          const SizedBox(width: 5),
          showColorsButton
        ])
      ] else ...[
        noColorButton,
        underlineButton,
        for (final color in mainColors) ...[
          _ColorPickerButton(
            isForUnderline: _underlineMode,
            color: color,
          ),
        ],
        showColorsButton,
      ],
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

    final scrollingChildren = [
      noColorButton,
      underlineButton,
      for (final color in mainColors.take(4)) ...[
        _ColorPickerButton(
          isForUnderline: _underlineMode,
          color: color,
        ),
      ],
      showColorsButton,
      for (final button in keyButtons.keys) ...[
        GreyCircleButton(
          icon: keyButtons[button],
          onPressed: () {},
        ),
      ],
      const SizedBox(width: 15)
    ];

    Widget _miniView() => !_showAllColors
        ? ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment(0.8, Alignment.centerRight.y),
                colors: const [Colors.transparent, Colors.white],
              ).createShader(bounds);
            },
            child: ListView.separated(
                itemCount: scrollingChildren.length,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (c, i) => const SizedBox(width: 5),
                itemBuilder: (c, i) => scrollingChildren[i]))
        : Row(children: [
            Expanded(child: _ColorSlider(isUnderline: _underlineMode)),
            noColorButton,
            const SizedBox(width: 5),
            underlineButton,
            const SizedBox(width: 5),
            showColorsButton
          ]);

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
          Container(height: 50, child: _miniView())
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

class _ColorPickerButton extends StatelessWidget {
  final bool isForUnderline;
  final Color color;
  const _ColorPickerButton({@required this.color, this.isForUnderline = false})
      : assert(color != null);

  @override
  Widget build(BuildContext context) {
    return isForUnderline
        ? InkWell(
            customBorder: const RoundedRectangleBorder(),
            onTap: () => context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                  type: HighlightType.underline,
                  color: color.value,
                )),
            child: Container(
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: color),
              width: 40,
              height: 15,
            ),
          )
        : InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                  type: HighlightType.highlight,
                  color: color.value,
                )),
            child: CircleAvatar(
              backgroundColor: color,
            ),
          );
  }
}

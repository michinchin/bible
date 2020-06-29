import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';

class SelectionSheet extends StatefulWidget {
  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> {
  List<Color> mainColors = [];

  final icons = [
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

  bool _showAllColors;
  bool _underlineMode;

  @override
  void initState() {
    for (var i = 1; i < 5; i++) {
      mainColors.add(tec.colorFromColorId(i,
          darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
    }

    // _isFullSized = tec.Prefs.shared
    //     .getBool(Labels.prefSelectionSheetFullSize, defaultValue: false);

    _showAllColors = false;
    _underlineMode = false;
    super.initState();
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
    final clearAndUnderline = [
      _GreyCircleButton(
        icon: Icons.format_color_reset,
        onPressed: () =>
            context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
                  type: HighlightType.clear,
                )),
      ),
      _GreyCircleButton(
        icon: _underlineMode ? FeatherIcons.edit3 : FeatherIcons.underline,
        onPressed: onSwitchToUnderline,
      )
    ];

    final sheetChildren = [
      if (!_showAllColors) ...[
        ...clearAndUnderline,
        for (final color in mainColors) ...[
          _ColorPickerButton(
            isForUnderline: _underlineMode,
            color: color,
          ),
        ],
      ] else ...[
        _ColorSlider(isUnderline: _underlineMode),
        ...clearAndUnderline
      ],
      _GreyCircleButton(
        icon: Icons.color_lens,
        onPressed: onShowAllColors,
      ),
      for (final each in icons) ...[
        _GreyCircleButton(icon: each, onPressed: () {}),
      ],
      const Divider(color: Colors.transparent),
      Row(
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
    ];

    Widget sheet() => Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 5,
          spacing: 5,
          children: sheetChildren,
        )
        // : ListView.separated(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: sheetChildren.length,
        //     itemBuilder: (c, i) => sheetChildren[i],
        //     separatorBuilder: (c, i) => vDiv,
        //   )
        );

    return _RoundedCornerSheet(
      showAllColors: _showAllColors,
      child: Column(
        children: [
          SheetAppBar(),
          Expanded(flex: 2, child: sheet()),
          const Divider(
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class SheetAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: Container(),
          elevation: 0,
          title: Container(
            width: 50,
            height: 5,
            decoration: ShapeDecoration(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
        ),
      ),
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

  @override
  void initState() {
    for (var i = 6; i < 365; i++) {
      allColors.add(tec.colorFromColorId(i,
          darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
    }
    _colorValue = 0;
    super.initState();
  }

  void changeColor(double value) {
    context.bloc<SelectionStyleBloc>()?.add(
          SelectionStyle(
              type: widget.isUnderline
                  ? HighlightType.underline
                  : HighlightType.highlight,
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
              type: widget.isUnderline
                  ? HighlightType.underline
                  : HighlightType.highlight,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
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
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 20)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
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
  final bool showAllColors;

  const _RoundedCornerSheet({
    @required this.child,
    this.showAllColors = false,
  }) : assert(child != null);
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.12,
        minChildSize: 0.11,
        maxChildSize: 0.3,
        expand: false,
        builder: (c, scrollController) {
          return Container(
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
            child: SingleChildScrollView(
              controller: scrollController,
              child: SafeArea(child: Container(height: 310, child: child)),
            ),
          );
        }
        // ),
        );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';

class SelectionSheet extends StatefulWidget {
  // final bool fullyExpanded;
  // const SelectionSheet({this.fullyExpanded});
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
    'Copy': FeatherIcons.copy,
    'Notes': FeatherIcons.edit2,
    'Save': FeatherIcons.bookmark,
    'Print': FeatherIcons.printer,
    'Text': FeatherIcons.messageCircle,
    'Email': FeatherIcons.mail,
    'Facebook': FeatherIcons.facebook,
    'Twitter': FeatherIcons.twitter
  };

  final squareButtons = <String, IconData>{
    'Copy': FeatherIcons.copy,
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
    _themeChangeStream =
        context.bloc<ThemeModeBloc>().listen(_listenForThemeChange);

    _showAllColors = false;
    _underlineMode = false;
    super.initState();
  }

  @override
  void dispose() {
    _themeChangeStream.cancel();
    super.dispose();
  }

  void _listenForThemeChange(ThemeMode mode) {
    final colors = <Color>[];
    for (var i = 1; i < 5; i++) {
      colors.add(tec.colorFromColorId(i,
          darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
    }
    setState(() {
      mainColors = colors;
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
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(children: [
        if (!_showAllColors)
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _GreyCircleButton(
              icon: Icons.format_color_reset,
              onPressed: () =>
                  context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
                        type: HighlightType.clear,
                      )),
            ),
            _GreyCircleButton(
              icon:
                  _underlineMode ? FeatherIcons.edit3 : FeatherIcons.underline,
              onPressed: onSwitchToUnderline,
            ),
            for (final color in mainColors) ...[
              _ColorPickerButton(
                isForUnderline: _underlineMode,
                color: color,
              ),
            ],
            _GreyCircleButton(
              icon: Icons.color_lens,
              onPressed: onShowAllColors,
            ),
          ])
        else
          Row(children: [
            Expanded(child: _ColorSlider(isUnderline: _underlineMode)),
            _GreyCircleButton(
              icon: Icons.format_color_reset,
              onPressed: () =>
                  context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
                        type: HighlightType.clear,
                      )),
            ),
            const SizedBox(width: 5),
            _GreyCircleButton(
              icon:
                  _underlineMode ? FeatherIcons.edit3 : FeatherIcons.underline,
              onPressed: onSwitchToUnderline,
            ),
            const SizedBox(width: 5),
            _GreyCircleButton(
              icon: Icons.color_lens,
              onPressed: onShowAllColors,
            ),
          ]),
        const Divider(
          endIndent: 15,
          indent: 15,
        ),
        const Divider(
          color: Colors.transparent,
          height: 10,
        ),
        // if (!widget.fullyExpanded)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final each in squareButtons.keys) ...[
              Expanded(
                child: _SheetButton(text: each, icon: squareButtons[each]),
              ),
              if (buttons.keys.last != each) const SizedBox(width: 10)
            ]
          ],
        ),
        const Divider(color: Colors.transparent),
        Container(
          height: 300,
          child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.only(top: 0),
              physics: const NeverScrollableScrollPhysics(),
              // alignment: WrapAlignment.spaceAround,
              // crossAxisAlignment: WrapCrossAlignment.center,
              // runSpacing: 10,
              // spacing: 15,
              children: [
                for (final each in buttons.keys) ...[
                  _GreyCircleButton(
                    icon: buttons[each],
                    onPressed: () {},
                    title: each,
                  ),
                ],
              ]),
        ),
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
    _themeChangeStream =
        context.bloc<ThemeModeBloc>().listen(_listenForThemeChange);
    _colorValue = 0;
    super.initState();
  }

  @override
  void dispose() {
    _themeChangeStream.cancel();
    _themeChangeStream = null;
    super.dispose();
  }

  void _listenForThemeChange(ThemeMode mode) {
    final colors = <Color>[];
    for (var i = 6; i < 365; i++) {
      colors.add(tec.colorFromColorId(i,
          darkMode: context.bloc<ThemeModeBloc>().state == ThemeMode.dark));
    }
    setState(() {
      allColors = colors;
    });
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
  final String title;
  const _GreyCircleButton(
      {@required this.icon, @required this.onPressed, this.title});
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
          Expanded(flex: 2, child: circleIcon(30)),
          Expanded(
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

class SnapSheet extends StatefulWidget {
  final SheetController controller;
  final Function(SheetState, double) onSnap;
  final Widget body;
  final Widget child;
  final List<double> snappings;

  const SnapSheet({
    @required this.controller,
    @required this.child,
    @required this.onSnap,
    @required this.snappings,
    this.body,
  })  : assert(controller != null),
        assert(child != null),
        assert(onSnap != null),
        assert(snappings != null);

  @override
  _SnapSheetState createState() => _SnapSheetState();
}

// TODO(abby): save sheet size to prefs so open on default sizing
class _SnapSheetState extends State<SnapSheet> {
  @override
  Widget build(BuildContext context) {
    return SlidingSheet(
        controller: widget.controller,
        elevation: 8,
        cornerRadius: 15,
        isBackdropInteractable: false,
        duration: const Duration(milliseconds: 250),
        addTopViewPaddingOnFullscreen: true,
        snapSpec: SnapSpec(
          snappings: widget.snappings,
          onSnap: widget.onSnap,
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        color: Theme.of(context).cardColor,
        builder: (c, state) => Container(height: 500, child: widget.child),
        body: widget.body,
        headerBuilder: (context, state) {
          return Container(
            width: 30,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: ShapeDecoration(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          );
        });
  }
}

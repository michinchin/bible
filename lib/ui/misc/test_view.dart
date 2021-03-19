import 'package:flutter/material.dart';

import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/color_utils.dart';
import 'color_picker.dart';

const testViewType = 'TestView';

Widget testViewBuilder(BuildContext context, ViewState state, Size size) =>
    TestView(state: state, size: size);

Widget testViewPageableBuilder(BuildContext context, ViewState state, Size size) => PageableView(
      state: state,
      size: size,
      pageBuilder: (context, state, size, index) {
        return (index >= -2 && index <= 2)
            ? TestView(state: state, size: size, pageIndex: index)
            : null;
      },
      onPageChanged: (context, state, page) {
        dmPrint('View ${state.uid} onPageChanged($page)');
      },
    );

class TestView extends StatefulWidget {
  final ViewState state;
  final Size size;
  final int pageIndex;

  const TestView({
    Key key,
    @required this.state,
    @required this.size,
    this.pageIndex,
  }) : super(key: key);

  @override
  _TestViewState createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  Color _color = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ListView(
        children: [
          ColorPickerContext(
            parameters: const ColorPickerParameters(comboPopupSize: Size(0, 250)),
            child: ColorPickerCombo(
                color: _color, onColorChanged: (color) => setState(() => _color = color)),
          ),
          _Contents(color: _color),
        ],
      ),
    );
  }
}

class _Contents extends StatelessWidget {
  final Color color;

  const _Contents({Key key, @required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontWeight: FontWeight.bold);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const TecText('Light Mode', style: style),
          const SizedBox(height: 4),
          _BibleText(isDarkMode: false, color: color),
          const SizedBox(height: 16),
          const TecText('Dark Mode', style: style),
          const SizedBox(height: 4),
          _BibleText(isDarkMode: true, color: color, ifDarkSetTextColor: true),
          // const SizedBox(height: 16),
          // const TecText('Dark Mode Highlights:', style: style),
          // const SizedBox(height: 4),
          // _BibleText(isDarkMode: true, color: color),
        ],
      ),
    );
  }
}

class _BibleText extends StatelessWidget {
  final bool isDarkMode;
  final Color color;
  final bool ifDarkSetTextColor;

  const _BibleText({
    Key key,
    this.isDarkMode = false,
    this.color,
    this.ifDarkSetTextColor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? const Color(0xffbbbbbb) : Colors.black;

    final sReg = TextStyle(color: textColor, height: 1.3);
    const sRed = TextStyle(color: Colors.red, height: 1.3);
    final sBold = TextStyle(color: textColor, height: 1.3, fontWeight: FontWeight.bold);

    TextSpan txt(String text) => TextSpan(text: text, style: sReg);
    TextSpan red(String text) => TextSpan(text: text, style: sRed);
    TextSpan bold(String text) => TextSpan(text: text, style: sBold);

    final ulColor = colorWithColor(color, forHighlight: false, isDarkMode: isDarkMode);
    final hlColor = colorWithColor(color, forHighlight: true, isDarkMode: isDarkMode);

    final sUl = TextStyle(
        decoration: TextDecoration.underline, decorationThickness: 2, decorationColor: ulColor);
    final sHl = TextStyle(backgroundColor: hlColor);
    final sHLT = TextStyle(color: ulColor);

    TextSpan ul(String text, TextStyle style) => TextSpan(text: text, style: style.merge(sUl));
    TextSpan hl(String text, TextStyle style) => ifDarkSetTextColor
        ? TextSpan(text: text, style: style.merge(sHLT))
        : TextSpan(text: text, style: style.merge(sHl));

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.all(8),
      child: TecText.rich(
        TextSpan(
          children: [
            bold('3 '),
            txt('Jesus replied,'),
            red('"I tell you the truth, '),
            hl('unless you are born again', sRed),
            red(' '),
            ul('you cannot see the Kingdom of God', sRed),
            red('."\n'),
            txt('"'),
            ul('What do you mean?', sReg),
            txt('" exclaimed Nicodemus. "'),
            hl('How can an old man...', sReg),
          ],
        ),
      ),
    );
  }
}

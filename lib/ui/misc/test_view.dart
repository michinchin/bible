import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import 'color_picker.dart';

const testViewType = 'TestView';

Widget testViewBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
    TestView(key: bodyKey, state: state, size: size);

Widget testViewPageableBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
    PageableView(
      key: bodyKey,
      state: state,
      size: size,
      pageBuilder: (context, state, size, index) {
        return (index >= -2 && index <= 2)
            ? TestView(state: state, size: size, pageIndex: index)
            : null;
      },
      onPageChanged: (context, state, page) {
        tec.dmPrint('View ${state.uid} onPageChanged($page)');
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
            parameters: const ColorPickerParameters(
              trackHeight: 12,
              //alphaRectSize: 5,
              //alphaColor: Color(0xffe0e0e0),
              //paletteCursorSize: 24,
              //paletteCursorColor: Colors.white,
              //paletteCursorWidth: 2,
              colorContainerHeight: 76,
              withAlpha: false,
              //comboPopupSize: Size(200, 200),
              //comboColorContainerHeight: 24,
            ),
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
          _BibleText(isDark: false, color: color),
          const SizedBox(height: 16),
          const TecText('Dark Mode', style: style),
          const SizedBox(height: 4),
          _BibleText(isDark: true, color: color, ifDarkSetTextColor: true),
          // const SizedBox(height: 16),
          // const TecText('Dark Mode Highlights:', style: style),
          // const SizedBox(height: 4),
          // _BibleText(isDark: true, color: color),
        ],
      ),
    );
  }
}

final hsvBlack = HSVColor.fromColor(Colors.black);
final hsvWhite = HSVColor.fromColor(Colors.white);

Color colorWithColor(Color color, {bool isHighlight = false, bool isDark = false}) {
  // LERP TO BLACK OR WHITE
  // final l = isDark ? 0.70 : 0.80;
  // final newColor = Color.lerp(color, isDark ? Colors.black : Colors.white, l);

  // ALPHA-BLEND WITH BLACK OR WHITE
  // final overlay = isDark ? Colors.black.withAlpha(160) : Colors.white.withAlpha(200);
  // final newColor = Color.alphaBlend(overlay, color);

  // SET BRIGHTNESS
  final b = isHighlight ? (isDark ? 32 : 255) : (isDark ? 150 : 160);
  final cb = color.brightness();
  final d = b - cb;
  final brightnessColor = color.withBrightness(d);
  //tec.dmPrint('Brightness goal: $b, current: $cb, delta: $d, result: ${brightnessColor.brightness()}');

  // SET LUMINANCE
  final l = isHighlight ? (isDark ? 0.20 : 0.90) : (isDark ? 0.50 : 0.70);
  final luminanceColor = isDark ? color.darkenedToLuminance(l) : color.lightenedToLuminance(l);
  //newColor = isDark ? color.withLuminance(l) : color.withLuminance(l);
  //tec.dmPrint('Luminance goal: $l, actual: ${luminanceColor.computeLuminance().toStringAsFixed(3)}');

  //final newColor = brightnessColor;
  //final newColor = luminanceColor;
  final newColor = isDark ? brightnessColor : Color.lerp(brightnessColor, luminanceColor, color.blueness);

  return newColor;
}

class _BibleText extends StatelessWidget {
  final bool isDark;
  final Color color;
  final bool ifDarkSetTextColor;

  const _BibleText({
    Key key,
    this.isDark = false,
    this.color,
    this.ifDarkSetTextColor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xffbbbbbb) : Colors.black;

    final sReg = TextStyle(color: textColor, height: 1.3);
    const sRed = TextStyle(color: Colors.red, height: 1.3);
    final sBold = TextStyle(color: textColor, height: 1.3, fontWeight: FontWeight.bold);

    TextSpan txt(String text) => TextSpan(text: text, style: sReg);
    TextSpan red(String text) => TextSpan(text: text, style: sRed);
    TextSpan bold(String text) => TextSpan(text: text, style: sBold);

    final ulColor = colorWithColor(color, isHighlight: false, isDark: isDark);
    final hlColor = colorWithColor(color, isHighlight: true, isDark: isDark);

    final sUl = TextStyle(
        decoration: TextDecoration.underline, decorationThickness: 2, decorationColor: ulColor);
    final sHl = TextStyle(backgroundColor: hlColor);
    final sHLT = TextStyle(color: ulColor);

    TextSpan ul(String text, TextStyle style) => TextSpan(text: text, style: style.merge(sUl));
    TextSpan hl(String text, TextStyle style) => ifDarkSetTextColor
        ? TextSpan(text: text, style: style.merge(sHLT))
        : TextSpan(text: text, style: style.merge(sHl));

    return Container(
      color: isDark ? Colors.black : Colors.white,
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

extension TecUtilExtOnColor on Color {
  //-------------------------------------------------------------------------
  // Brightness related

  int brightness() {
    return ((red * 299 + green * 587 + blue * 114) / 1000).round();
  }

  bool isLight() {
    return !isDark();
  }

  bool isDark() {
    return brightness() < 128.0;
  }

  Color withBrightness(int amount) {
    final color = Color.fromARGB(
      alpha,
      math.max(0, math.min(255, red + amount)).round(),
      math.max(0, math.min(255, green + amount)).round(),
      math.max(0, math.min(255, blue + amount)).round(),
    );
    return color;
  }

  Color brighten([int amount = 10]) {
    final color = Color.fromARGB(
      alpha,
      math.max(0, math.min(255, red - (255 * -(amount / 100)).round())),
      math.max(0, math.min(255, green - (255 * -(amount / 100)).round())),
      math.max(0, math.min(255, blue - (255 * -(amount / 100)).round())),
    );
    return color;
  }

  //-------------------------------------------------------------------------
  // Luminance related

  Color lighten([int amount = 10]) {
    final hsl = toHsl()..l += amount / 100;
    hsl.l = clamp01(hsl.l);
    return colorFromHsl(hsl);
  }

  Color darken([int amount = 10]) {
    final hsl = toHsl()..l -= amount / 100;
    hsl.l = clamp01(hsl.l);
    return colorFromHsl(hsl);
  }

  Color withLuminance(double l) {
    final hsl = toHsl()..l = clamp01(l);
    return colorFromHsl(hsl);
  }

  Color lightenedToLuminance(double l) {
    final hsl = toHsl();
    hsl.l = math.max(hsl.l, clamp01(l));
    return colorFromHsl(hsl);
  }

  Color darkenedToLuminance(double l) {
    final hsl = toHsl();
    hsl.l = math.min(hsl.l, clamp01(l));
    return colorFromHsl(hsl);
  }

  //-------------------------------------------------------------------------
  // Saturation related

  Color withSaturation(double s) {
    final hsl = toHsl()..s = clamp01(s);
    return colorFromHsl(hsl);
  }

  Color saturateTo(double s) {
    final hsl = toHsl();
    hsl.s = math.max(hsl.s, clamp01(s));
    return colorFromHsl(hsl);
  }

  Color desaturateTo(double s) {
    final hsl = toHsl();
    hsl.s = math.min(hsl.s, clamp01(s));
    return colorFromHsl(hsl);
  }

  Color saturate([int amount = 10]) {
    final hsl = toHsl()..s += amount / 100;
    hsl.s = clamp01(hsl.s);
    return colorFromHsl(hsl);
  }

  Color desaturate([int amount = 10]) {
    final hsl = toHsl()..s -= amount / 100;
    hsl.s = clamp01(hsl.s);
    return colorFromHsl(hsl);
  }

  Color greyscale() {
    return desaturate(100);
  }

  //-------------------------------------------------------------------------
  // Hue related

  Color spin(double amount) {
    final hsl = toHsl();
    final hue = (hsl.h + amount) % 360;
    hsl.h = hue < 0 ? 360 + hue : hue;
    return colorFromHsl(hsl);
  }

  //-------------------------------------------------------------------------
  // Misc.

  Color mix({@required Color input, int amount = 50}) {
    final p = (amount.toDouble() / 100.0).round();
    final color = Color.fromARGB((input.alpha - alpha) * p + alpha, (input.red - red) * p + red,
        (input.green - green) * p + green, (input.blue - blue) * p + blue);
    return color;
  }

  Color complement() {
    final hsl = toHsl();
    hsl.h = (hsl.h + 180) % 360;
    return colorFromHsl(hsl);
  }

  //double get blueness => ((blue - ((red + green) / 2.0)) + 255.0) / 510.0;
  double get blueness => (blue - math.max(red, green) + 255.0) / 510.0;

  HslColor toHsl() {
    return rgbToHsl(red.toDouble(), green.toDouble(), blue.toDouble(), alpha.toDouble());
  }
}

class HslColor {
  double h;
  double s;
  double l;
  double a;

  HslColor({this.h, this.s, this.l, this.a = 0.0});

  @override
  String toString() {
    return 'HSL(h: $h, s: $s, l: $l, a: $a)';
  }
}

/// Returns a brightness value between 0 for darkest and 1 for lightest.
///
/// Represents the relative luminance of the color. This value is computationally
/// expensive to calculate.
///
/// See:
/// - <https://en.wikipedia.org/wiki/Relative_luminance>.
/// - <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
///
double computeLuminance(double r, double g, double b) {
  final rl = _linearizeColorComponent(r / 0xFF);
  final gl = _linearizeColorComponent(g / 0xFF);
  final bl = _linearizeColorComponent(b / 0xFF);
  return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl;
}

// See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
double _linearizeColorComponent(double component) {
  if (component <= 0.03928) return component / 12.92;
  return math.pow((component + 0.055) / 1.055, 2.4) as double;
}

HslColor rgbToHsl(double r1, double g1, double b1, double alpha) {
  final r = bound01(r1, 255.0);
  final g = bound01(g1, 255.0);
  final b = bound01(b1, 255.0);

  final max = [r, g, b].reduce(math.max);
  final min = [r, g, b].reduce(math.min);
  var h = 0.0;
  var s = 0.0;
  final l = (max + min) / 2;
  // final l = computeLuminance(r, g, b);

  if (max == min) {
    h = s = 0.0;
  } else {
    final d = max - min;
    s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);
    if (max == r) {
      h = (g - b) / d + (g < b ? 6 : 0);
    } else if (max == g) {
      h = (b - r) / d + 2;
    } else if (max == b) {
      h = (r - g) / d + 4;
    }
  }

  h /= 6.0;

  return HslColor(h: h * 360, s: s, l: l, a: alpha);
}

Color colorFromHsl(HslColor hsl) {
  final h = bound01(hsl.h, 360.0);
  final s = bound01(hsl.s * 100, 100.0);
  final l = bound01(hsl.l * 100, 100.0);

  double r;
  double g;
  double b;
  if (s == 0.0) {
    r = g = b = l;
  } else {
    final q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    final p = 2 * l - q;
    r = _hue2rgb(p, q, h + 1 / 3);
    g = _hue2rgb(p, q, h);
    b = _hue2rgb(p, q, h - 1 / 3);
  }
  return Color.fromARGB(hsl.a.round(), (r * 255).round(), (g * 255).round(), (b * 255).round());
}

double _hue2rgb(double p, double q, double t1) {
  var t = t1;
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
  return p;
}

double bound01(double n1, double max) {
  var n = max == 360.0 ? n1 : math.min(max, math.max(0.0, n1));
  final absDifference = n - max;
  if (absDifference.abs() < 0.000001) {
    return 1.0;
  }

  if (max == 360) {
    n = (n < 0 ? n % max + max : n % max) / max;
  } else {
    n = (n % max) / max;
  }

  return n;
}

double clamp01(double val) {
  return math.min(1.0, math.max(0.0, val));
}

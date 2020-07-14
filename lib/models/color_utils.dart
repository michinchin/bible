import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

///
/// Returns a new color, based on the given [color], that will look good for text
/// or underlining. Or, if [forHighlight] is true, for highlighting text.
///
/// If [isDark] is false (the default), the background color should be a light color
/// (e.g. white) with dark (e.g. black) text.
///
/// If [isDark] is true,the background color should be a dark color (e.g. black) with
/// light (e.g. light gray) text.
///
Color colorWithColor(Color color, {bool forHighlight = false, bool isDark = false}) {
  // BRIGHTNESS
  final b = forHighlight ? (isDark ? 32 : 255) : (isDark ? 150 : 160);
  final cb = color.brightness();
  final d = b - cb;
  final brightnessColor = color.withBrightness(d);
  //tec.dmPrint('Brightness goal: $b, current: $cb, delta: $d, result: ${brightnessColor.brightness()}');

  // LUMINANCE
  final l = forHighlight ? (isDark ? 0.20 : 0.90) : (isDark ? 0.50 : 0.70);
  final luminanceColor = isDark ? color.darkenedToLuminance(l) : color.lightenedToLuminance(l);
  //newColor = isDark ? color.withLuminance(l) : color.withLuminance(l);
  //tec.dmPrint('Luminance goal: $l, actual: ${luminanceColor.computeLuminance().toStringAsFixed(3)}');

  //final newColor = brightnessColor;
  //final newColor = luminanceColor;
  final newColor =
      isDark ? brightnessColor : Color.lerp(brightnessColor, luminanceColor, color.blueness);

  return newColor;
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
    final hsl = _toHsl()..l += amount / 100;
    hsl.l = _clamp01(hsl.l);
    return _colorFromHsl(hsl);
  }

  Color darken([int amount = 10]) {
    final hsl = _toHsl()..l -= amount / 100;
    hsl.l = _clamp01(hsl.l);
    return _colorFromHsl(hsl);
  }

  Color withLuminance(double l) {
    final hsl = _toHsl()..l = _clamp01(l);
    return _colorFromHsl(hsl);
  }

  Color lightenedToLuminance(double l) {
    final hsl = _toHsl();
    hsl.l = math.max(hsl.l, _clamp01(l));
    return _colorFromHsl(hsl);
  }

  Color darkenedToLuminance(double l) {
    final hsl = _toHsl();
    hsl.l = math.min(hsl.l, _clamp01(l));
    return _colorFromHsl(hsl);
  }

  //-------------------------------------------------------------------------
  // Saturation related

  Color withSaturation(double s) {
    final hsl = _toHsl()..s = _clamp01(s);
    return _colorFromHsl(hsl);
  }

  Color saturateTo(double s) {
    final hsl = _toHsl();
    hsl.s = math.max(hsl.s, _clamp01(s));
    return _colorFromHsl(hsl);
  }

  Color desaturateTo(double s) {
    final hsl = _toHsl();
    hsl.s = math.min(hsl.s, _clamp01(s));
    return _colorFromHsl(hsl);
  }

  Color saturate([int amount = 10]) {
    final hsl = _toHsl()..s += amount / 100;
    hsl.s = _clamp01(hsl.s);
    return _colorFromHsl(hsl);
  }

  Color desaturate([int amount = 10]) {
    final hsl = _toHsl()..s -= amount / 100;
    hsl.s = _clamp01(hsl.s);
    return _colorFromHsl(hsl);
  }

  Color greyscale() {
    return desaturate(100);
  }

  //-------------------------------------------------------------------------
  // Hue related

  Color spin(double amount) {
    final hsl = _toHsl();
    final hue = (hsl.h + amount) % 360;
    hsl.h = hue < 0 ? 360 + hue : hue;
    return _colorFromHsl(hsl);
  }

  //-------------------------------------------------------------------------
  // Misc.

  Color mix({@required Color input, int amount = 50}) {
    assert(input != null);
    final p = (amount.toDouble() / 100.0).round();
    final color = Color.fromARGB((input.alpha - alpha) * p + alpha, (input.red - red) * p + red,
        (input.green - green) * p + green, (input.blue - blue) * p + blue);
    return color;
  }

  Color complement() {
    final hsl = _toHsl();
    hsl.h = (hsl.h + 180) % 360;
    return _colorFromHsl(hsl);
  }

  //double get blueness => ((blue - ((red + green) / 2.0)) + 255.0) / 510.0;
  double get blueness => (blue - math.max(red, green) + 255.0) / 510.0;

  _HslColor _toHsl() {
    return rgbToHsl(red.toDouble(), green.toDouble(), blue.toDouble(), alpha.toDouble());
  }
}

class _HslColor {
  double h;
  double s;
  double l;
  double a;

  _HslColor({this.h, this.s, this.l, this.a = 0.0});

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

_HslColor rgbToHsl(double r1, double g1, double b1, double alpha) {
  final r = _bound01(r1, 255.0);
  final g = _bound01(g1, 255.0);
  final b = _bound01(b1, 255.0);

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

  return _HslColor(h: h * 360, s: s, l: l, a: alpha);
}

Color _colorFromHsl(_HslColor hsl) {
  final h = _bound01(hsl.h, 360.0);
  final s = _bound01(hsl.s * 100, 100.0);
  final l = _bound01(hsl.l * 100, 100.0);

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

double _bound01(double n1, double max) {
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

double _clamp01(double val) {
  return math.min(1.0, math.max(0.0, val));
}

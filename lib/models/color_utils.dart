import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

//---------------------------------------------------------------------------
// COLOR CACHES

int defaultColorIntForIndex(int index) {
  assert(index >= 1 && index <= 5);

  switch (index) {
    case 1:
      return 0xffcae1fe; // blue
    case 2:
      return 0xfffff193; // yellow
    case 3:
      return 0xffffc9e4; // pink
    case 4:
      return 0xffb3e487; // green
    case 5:
      return 0xff999999; // underline - gray
  }

  // assert will throw before we get here
  return 0;
}

///
/// Returns the color to use for text and underlines. Caches the result for
/// quick access next time.
///
Color textColorWith(Color color, {bool isDarkMode = false}) => isDarkMode
    ? _darkModeTx.colorFrom(color, isDarkMode: true, forHighlight: false)
    : _lightModeTx.colorFrom(color, isDarkMode: false, forHighlight: false);

final _darkModeTx = <Color, Color>{};
final _lightModeTx = <Color, Color>{};

///
/// Returns the color to use for highlights. Caches the result for quick access
/// next time.
///
Color highlightColorWith(Color color, {bool isDarkMode = false}) => isDarkMode
    ? _darkModeHl.colorFrom(color, isDarkMode: true, forHighlight: true)
    : _lightModeHl.colorFrom(color, isDarkMode: false, forHighlight: true);

final _darkModeHl = <Color, Color>{};
final _lightModeHl = <Color, Color>{};

extension on Map<Color, Color> {
  Color colorFrom(Color color, {bool isDarkMode = false, bool forHighlight = false}) =>
      this[color] ??
      (this[color] = colorWithColor(color, forHighlight: forHighlight, isDarkMode: isDarkMode));
}

///
/// Returns a new color, based on the given [color], that will look good for text
/// or underlining. Or, if [forHighlight] is true, for highlighting text.
///
/// If [isDarkMode] is false (the default), the background color should be a light color
/// with dark text. Otherwise, the background color should be a dark color with light
/// text.
///
Color colorWithColor(Color color, {bool forHighlight = false, bool isDarkMode = false}) {
  // Calculates the best color by tweaking the brightness.
  Color _brightness(Color color) {
    final idealBrightness = forHighlight ? (isDarkMode ? 32 : 255) : (isDarkMode ? 150 : 160);
    return color.withBrightness(idealBrightness - color.brightness(), 0xff);
  }

  // Calculates the best color by tweaking the luminance.
  Color _luminance(Color color) {
    // dark mode version 1 - used : (isDarkMode ? 0.50 : 0.70)
    // dark mode version 2 - used : (isDarkMode ? 0.70 : 0.70)

    final l = forHighlight ? (isDarkMode ? 0.20 : 0.90) : (isDarkMode ? 0.70 : 0.70);
    return isDarkMode ? color.darkenedToLuminance(l) : color.lightenedToLuminance(l);
    // return isDarkMode ? color.withLuminance(l) : color.withLuminance(l);
  }

  // dark mode version 3 - greens need to be more green. For green colors, we lerp
  // between the lumiance color and pure green
  // For all other colors, just return luminance(color) (save as version 2)
  Color _darkModeText(Color color) {
    if (!forHighlight && color.greenness > 0.55) {
      return Color.lerp(_luminance(color), const Color(0xff00ff00), color.greenness);
    }
    else {
      return _luminance(color);
    }
  }

  // For dark mode, the `luminance` algorithm seems to always produce the best color.
  // For light mode, the `brightness` algorithm works best for non-blue colors, but
  // the `luminance` algorithm works best for blue colors, so, we lerp between them
  // based the blueness of the color.

  // dark mode version 1 - used _brightness(color)
  // dark mode version 2 - used _luminance(color)

  final newColor = isDarkMode
      ? _darkModeText(color)
      : Color.lerp(_brightness(color), _luminance(color), color.blueness);

  return newColor;
}

extension TecUtilExtOnColor on Color {
  //-------------------------------------------------------------------------
  // Brightness related

  ///
  /// Returns the "brightness" of this color. Black == 0, white == 255.
  ///
  int brightness() {
    return ((red * 299 + green * 587 + blue * 114) / 1000).round();
  }

  ///
  /// Returns true if this a "light" color (i.e. its brightness is >= 128).
  ///
  bool isLight() {
    return !isDark();
  }

  ///
  /// Returns true if this is a "dark" color (i.e. its brightness is less than 128).
  ///
  bool isDark() {
    return brightness() < 128.0;
  }

  ///
  /// Returns the result of brightening this color to the given brightness value.
  ///
  Color withBrightness(int amount, [int alpha]) {
    final color = Color.fromARGB(
      alpha ?? this.alpha,
      math.max(0, math.min(255, red + amount)).round(),
      math.max(0, math.min(255, green + amount)).round(),
      math.max(0, math.min(255, blue + amount)).round(),
    );
    return color;
  }

  ///
  /// Returns the result of brightening this color by the given amount. The
  /// [amount] can be positive or negative and should be between -100 and 100.
  ///
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

  ///
  /// Returns the result of lightening this color's luminance by the given amount.
  ///
  Color lightenBy(int amount, {int alpha}) {
    final hsl = _toHsl(alpha: alpha)..l += amount / 100;
    hsl.l = _clamp01(hsl.l);
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of darkening this color's luminance by the given amount.
  ///
  Color darkenBy(int amount, {int alpha}) {
    final hsl = _toHsl(alpha: alpha)..l -= amount / 100;
    hsl.l = _clamp01(hsl.l);
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of updating this color's luminance to the given value.
  ///
  Color withLuminance(double l, {int alpha}) {
    final hsl = _toHsl(alpha: alpha)..l = _clamp01(l);
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of lightening the luminance of this color to the given
  /// value. If this color already has a luminance >= to the given value,
  /// this color is returned unchanged.
  ///
  Color lightenedToLuminance(double l, {int alpha}) {
    final hsl = _toHsl(alpha: alpha);
    final clamped = _clamp01(l);
    if (hsl.l >= clamped) return this;
    hsl.l = clamped;
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of darkening the luminance of this color to the given
  /// value. If this color already has a luminance <= to the given value,
  /// this color is returned unchanged.
  ///
  Color darkenedToLuminance(double l, {int alpha}) {
    final hsl = _toHsl(alpha: alpha);
    final clamped = _clamp01(l);
    if (hsl.l <= clamped) return this;
    hsl.l = clamped;
    return _colorFromHsl(hsl);
  }

  //-------------------------------------------------------------------------
  // Saturation related

  ///
  /// Returns the result of updating this color's saturation to the given value.
  ///
  Color withSaturation(double s, {int alpha}) {
    final hsl = _toHsl(alpha: alpha)..s = _clamp01(s);
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of saturating this color to the given value.
  ///
  Color saturateTo(double s, {int alpha}) {
    final hsl = _toHsl(alpha: alpha);
    hsl.s = math.max(hsl.s, _clamp01(s));
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of desaturating this color to the given value.
  ///
  Color desaturateTo(double s, {int alpha}) {
    final hsl = _toHsl(alpha: alpha);
    hsl.s = math.min(hsl.s, _clamp01(s));
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of saturating this color by the given [amount].
  ///
  Color saturateBy(int amount, {int alpha}) {
    final hsl = _toHsl(alpha: alpha)..s += amount / 100;
    hsl.s = _clamp01(hsl.s);
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of desaturating this color by the given [amount].
  ///
  Color desaturateBy(int amount, {int alpha}) {
    final hsl = _toHsl(alpha: alpha)..s -= amount / 100;
    hsl.s = _clamp01(hsl.s);
    return _colorFromHsl(hsl);
  }

  ///
  /// Returns the result of desaturating this color by 100%.
  ///
  Color greyscale() {
    return desaturateBy(100);
  }

  //-------------------------------------------------------------------------
  // Hue related

  ///
  /// Returns the color on the color wheel that is the given [amount] from this color.
  ///
  Color spin(double amount, {int alpha}) {
    final hsl = _toHsl(alpha: alpha);
    final hue = (hsl.h + amount) % 360;
    hsl.h = hue < 0 ? 360 + hue : hue;
    return _colorFromHsl(hsl);
  }

  //-------------------------------------------------------------------------
  // Misc.

  ///
  /// Returns the result of mixing this color with the [other] color.
  ///
  Color mix({@required Color other, int amount = 50}) {
    assert(other != null);
    final p = (amount.toDouble() / 100.0).round();
    final result = Color.fromARGB((other.alpha - alpha) * p + alpha, (other.red - red) * p + red,
        (other.green - green) * p + green, (other.blue - blue) * p + blue);
    return result;
  }

  ///
  /// Returns this color's complementary color (i.e. the color opposite this color
  /// on the color wheel).
  ///
  Color complement({int alpha}) {
    final hsl = _toHsl(alpha: alpha);
    hsl.h = (hsl.h + 180) % 360;
    return _colorFromHsl(hsl);
  }

  // Returns the "blueness" of the color, a number <= 0 && <= 1.0.
  double get blueness => (blue - math.max(red, green) + 255.0) / 510.0;

  // Returns the "greenness" of the color, a number <= 0 && <= 1.0.
  double get greenness => (green - math.max(red, blue) + 255.0) / 510.0;

  _HslColor _toHsl({@required int alpha}) {
    return _rgbToHsl(
        red.toDouble(), green.toDouble(), blue.toDouble(), (alpha ?? this.alpha).toDouble());
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

_HslColor _rgbToHsl(double r1, double g1, double b1, double alpha) {
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

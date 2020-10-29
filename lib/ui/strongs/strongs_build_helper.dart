import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'strongs_popup.dart';

///
/// [StrongsBuildHelper]
///
/// Note, a new [StrongsBuildHelper] should be created for each `TechHtml` widget build,
/// the same helper cannot be used for multiple widget builds.
///
class StrongsBuildHelper {
  TecHtmlTagElementFunc get tagHtmlElement => _tagHtmlElement;
  TecHtmlCheckElementFunc get toggleVisibility => null;
  TecHtmlCheckElementFunc get shouldSkip => null;

  var _isInXref = false;
  var _xrefElementLevel = 0;
  String _href;

  Object _tagHtmlElement(
    String name,
    LinkedHashMap<dynamic, String> attrs,
    String text,
    int level,
    bool isVisible,
  ) {
    if (_isInXref && level <= _xrefElementLevel) {
      _isInXref = false;
      _href = null;
    }

    if (!_isInXref && attrs.className.contains('xref')) {
      _isInXref = true;
      _xrefElementLevel = level;
      _href = attrs['href'];
    }

    return _href;
  }
}

///
/// Returns a TextSpan, WidgetSpan, or `null` for the given HTML text node.
///
InlineSpan strongsSpanForText(BuildContext context, String text, TextStyle style, Object tag) {
  if (tag is String && tag.isNotEmpty && tec.isNotNullOrEmpty(text)) {
    final recognizer = TapGestureRecognizer()..onTap = () => _onTappedSpanWithHref(context, tag);

    var textStyle = style;

    // Add xref styling to the span:
    textStyle = textStyle.merge(TextStyle(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: textStyle.color ?? Colors.blueAccent));

    return TaggableTextSpan(text: text, style: textStyle, tag: tag, recognizer: recognizer);
  }

  return TextSpan(text: text, style: style);
}

void _onTappedSpanWithHref(BuildContext context, String href) {
  tec.dmPrint('tapped $href');
  if (href.startsWith('G') || href.startsWith('H')) {
    if (href.contains('-')) {
      // e.g. "G1520-49", where 49 is book number
      // TODO(ron): ...
    } else if (href.trim().contains(' ')) {
      // e.g. "G1520 thing"
      // TODO(ron): ...
    } else {
      showStrongsPopup(context: context, title: href, strongsId: href);
    }
  }
}

String strongsHtmlWithFragment(
  String htmlFragment, {
  bool darkTheme = false,
  int fontSizePercent = 100,
  String vendorFolder,
}) {
  final s = StringBuffer()
    ..write('<!DOCTYPE html>\n'
        '<head>\n'
        '<meta charset="utf-8" />\n'
        '<meta name="viewport" content="width=device-width, '
        'initial-scale=1, maximum-scale=1, user-scalable=no" />\n'
        '<style> html { -webkit-text-size-adjust: none; } </style>\n');

  var bibleVendorCSS = '';
  if (vendorFolder != null) {
    bibleVendorCSS = vendorFolder;
    if (!vendorFolder.endsWith('/')) bibleVendorCSS += '/';
  }
  bibleVendorCSS += 'bible_vendor.css';
  s.write('<link rel="stylesheet" type="text/css" href="$bibleVendorCSS" />\n');

  s.write('<link rel="stylesheet" type="text/css" href="strongs.css" />\n');

  if (darkTheme) {
    s.write('<link rel="stylesheet" type="text/css" href="strongs_night.css" />\n');
  }

  s.write('<title></title>\n</head>\n\n');

  final color = (darkTheme ? 'black' : 'white');

  final fontSize = (fontSizePercent ?? 100);
  s.write('<body style="background-color: $color; '
      // 'margin-left: $marginLeft; margin-right: $marginRight; '
      // 'padding-top: $marginTop; padding-bottom: $marginBottom; '
      'font-size: $fontSize%;">\n');

  // ignore_for_file: cascade_invocations
  s.write('$htmlFragment\n\n');

  s.write('</body>\n</html>\n');

  return s.toString();
}

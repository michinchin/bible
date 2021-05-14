import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tec_util/tec_util.dart';

const _maxLinesLimit = 20;

class TecSearchResult extends StatefulWidget {
  final String text;
  final String title;
  final List<String> lFormattedKeywords;
  final int maxLines;
  final double textScaleFactor;
  final TextOverflow overflow;
  final double fontSize;
  final Color keywordColor;
  final Color textColor;

  const TecSearchResult(
      {Key key,
      @required this.text,
      this.title,
      this.lFormattedKeywords,
      this.maxLines,
      this.textScaleFactor = 1.0,
      this.fontSize,
      this.keywordColor = Colors.orange,
      this.textColor,
      this.overflow})
      : super(key: key);

  @override
  _TecSearchResultState createState() => _TecSearchResultState();

  static List<String> getLFormattedKeywords(String search) {
    var modKeywords = search.trim();
    var phrase = false, exact = false;

    if (modKeywords.isEmpty) {
      return <String>[];
    }

    urlEncodingExceptions.forEach((k, v) => modKeywords = modKeywords.replaceAll(RegExp(k), v));

    // phrase or exact search ?
    if (modKeywords[0] == '"' || modKeywords[0] == "'") {
      if (modKeywords.contains(' ')) {
        phrase = true;
      } else {
        exact = true;
      }

      // remove trailing quote
      if (modKeywords.length > 1 && modKeywords.endsWith(modKeywords[0])) {
        modKeywords = modKeywords.substring(1, modKeywords.length - 1);
      } else {
        modKeywords = modKeywords.substring(1);
      }
    } else {
      modKeywords = modKeywords;
    }

    // l = lowercase
    List<String> lFormattedKeywords;

    if (exact || phrase) {
      lFormattedKeywords = [modKeywords.trim().toLowerCase()];
    } else {
      lFormattedKeywords = modKeywords.toLowerCase().split(' ');
    }

    lFormattedKeywords
      ..removeWhere((s) => s.isEmpty)
      // put longest words first - looks better when truncation is going to happen...
      ..sort((a, b) => b.length.compareTo(a.length));

    return lFormattedKeywords;
  }
}

class _TecSearchResultState extends State<TecSearchResult> {
  List<TextSpan> spans;
  List<TextSpan> titleSpans;
  double _textScaleFactor;

  @override
  void didUpdateWidget(TecSearchResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!const ListEquality<String>()
            .equals(oldWidget.lFormattedKeywords, widget.lFormattedKeywords) ||
        widget.text != oldWidget.text) {
      _createSpans();
    }
  }

  List<TextSpan> _searchResTextSpans({
    @required String text,
    @required List<String> lFormattedKeywords,
    @required Color keywordColor,
  }) {
    final cleanText = removeDiacritics(text);
    final content = <TextSpan>[];

    final bold = <int, int>{};
    final lVerse = cleanText.toLowerCase();
    final a = 'a'.codeUnitAt(0);
    final z = 'z'.codeUnitAt(0);

    // find matching words (case insensitive search)
    for (final keyword in lFormattedKeywords) {
      var where = -1;

      while ((where = lVerse.indexOf(keyword, where + 1)) >= 0) {
        if (where == 0 || (lVerse.codeUnitAt(where - 1) < a) || lVerse.codeUnitAt(where - 1) > z) {
          final length = keyword.length;

          if (length <= 2 && lVerse.length > (where + length)) {
            // match only whole words
            if (lVerse.codeUnitAt(where + length) >= a && lVerse.codeUnitAt(where + length) <= z) {
              continue;
            }
          }

          bold[where] = length;
        }
      }
    }

    if (bold.isEmpty) {
      // no bold - should never happen
      content.add(TextSpan(text: cleanText));
    } else {
      final boldKeys = bold.keys.toList()..sort((a, b) => a.compareTo(b));

      var lastEnd = 0;

      for (final where in boldKeys) {
        if (where >= lastEnd) {
          if (where > 0) {
            // add any preceding text not bolded...
            content.add(TextSpan(text: cleanText.substring(lastEnd, where)));
          }

          // add the bold text...
          content.add(TextSpan(
              text: cleanText.substring(where, where + bold[where]),
              style: TextStyle(color: keywordColor)));

          lastEnd = where + bold[where];
        }
      }

      if (lastEnd < cleanText.length) {
        content.add(TextSpan(text: cleanText.substring(lastEnd)));
      }
    }

    return content;
  }

  void _createSpans() {
    if (widget.text != null) {
      var text = widget.text.replaceAll('\n', ' ');
      if (widget.maxLines != null) {
        text = _truncateText(text, widget.lFormattedKeywords);
      }

      if (widget.lFormattedKeywords != null) {
        spans = _searchResTextSpans(
            text: text,
            lFormattedKeywords: widget.lFormattedKeywords,
            keywordColor: widget.keywordColor);
      } else {
        spans = <TextSpan>[TextSpan(text: text)];
      }
    }

    if (widget.title != null) {
      if (widget.lFormattedKeywords != null) {
        titleSpans = _searchResTextSpans(
            text: widget.title,
            lFormattedKeywords: widget.lFormattedKeywords,
            keywordColor: widget.keywordColor);
      } else {
        titleSpans = <TextSpan>[TextSpan(text: widget.title)];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var style = (widget.fontSize == null)
        ? Theme.of(context).textTheme.bodyText2
        : Theme.of(context).textTheme.bodyText2.copyWith(fontSize: widget.fontSize);

    if (widget.textColor != null) {
      style = style.copyWith(color: widget.textColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: _textScaleFactor,
            text:
                TextSpan(children: titleSpans, style: style.copyWith(fontWeight: FontWeight.w500)),
          ),
        RichText(
            maxLines: (widget.maxLines == null) ? _maxLinesLimit : widget.maxLines,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: _textScaleFactor,
            text: TextSpan(children: spans, style: style)),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _textScaleFactor = (widget.textScaleFactor < 1.5) ? widget.textScaleFactor : 1.5;
    _createSpans();
  }

  int _previousSpace(String s, int index) {
    if (index < 0) {
      return 0;
    }

    final space = s.lastIndexOf(' ', index);
    return (space > 0) ? space + 1 : index;
  }

  String _truncateText(String info, List<String> lFormattedKeywords) {
    const maxDesc = 175;
    const minEnd = 60;
    var index = 0;

    if (lFormattedKeywords != null) {
      final lowerInfo = info.toLowerCase();
      for (final word in lFormattedKeywords) {
        index = lowerInfo.indexOf(word);

        // make sure this is the beginning of a word...
        while (index > 0 && isAlpha(lowerInfo[index - 1])) {
          index = lowerInfo.indexOf(word, index + 1);
        }

        // if we actually found a word beginning exit loop...
        if (index >= 0) {
          break;
        }
      }
    }

    if (index >= 0) {
      // go back a bit...
      var start = _previousSpace(info, index - (minEnd / 4).floor());

      if (info.length - start < minEnd) {
        // move the pointer back a bit...
        start = _previousSpace(info, info.length - minEnd);
      }

      return info.substring(start, start + min(info.length - start, maxDesc).floor());
    }

    // no matches found? return original string
    return info;
  }
}

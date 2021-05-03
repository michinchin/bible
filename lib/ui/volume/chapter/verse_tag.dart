import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:equatable/equatable.dart';
import 'package:tec_selectable/tec_selectable.dart';

import '../../../models/string_utils.dart';

///
/// Used to tag an HTML text node with the [verse] it is in, the [word] index
/// of the first word in the text node, and a boolean indicating whether or not
/// the associated text node is part of the actual verse text (as opposed to
/// being the verse number, a footnote, a section title, or other text marked
/// with v="0").
///
@immutable
class VerseTag extends Equatable with SplittableTextSpanTag<VerseTag> {
  final int verse;
  final int word;
  final int endVerse;
  final bool isInVerse;
  final bool isInXref;
  final bool isInFootnote;
  final bool isInMarginNote;
  final String href;

  const VerseTag({
    @required this.verse,
    @required this.word,
    int endVerse,
    this.isInVerse = false,
    this.isInXref = false,
    this.isInFootnote = false,
    this.isInMarginNote = false,
    this.href,
  })  : assert(verse != null &&
            word != null &&
            (endVerse == null || endVerse >= verse) &&
            isInVerse != null &&
            isInXref != null &&
            isInFootnote != null &&
            isInMarginNote != null),
        endVerse = endVerse ?? verse;

  VerseTag copyWith({
    int verse,
    int word,
    int endVerse,
    bool isInVerse,
    bool isInXref,
    bool isInFootnote,
    bool isInMarginNote,
    String href,
  }) =>
      VerseTag(
        verse: verse ?? this.verse,
        word: word ?? this.word,
        endVerse: endVerse ?? verse ?? this.endVerse,
        isInVerse: isInVerse ?? this.isInVerse,
        isInXref: isInXref ?? this.isInXref,
        isInFootnote: isInFootnote ?? this.isInFootnote,
        isInMarginNote: isInMarginNote ?? this.isInMarginNote,
        href: href ?? this.href,
      );

  @override
  List<Object> get props =>
      [verse, word, endVerse, isInVerse, isInXref, isInFootnote, isInMarginNote, href];

  @override
  String toString() {
    final buf = StringBuffer('{ "v": $verse, "w": $word');
    if (endVerse != verse) buf.write(', "endV": $endVerse');
    if (isInVerse) buf.write(', "inV": true');
    if (isInXref) buf.write(', "inXref": true');
    if (isInFootnote) buf.write(', "inFn": true');
    if (isInMarginNote) buf.write(', "inMn": true');
    if (href != null) buf.write(', "href": ${jsonEncode(href)}');
    buf.write(' }');
    return buf.toString();
  }

  @override
  List<VerseTag> splitWith(TextSpan span, {int atCharacter}) {
    final text = span?.toPlainText(includeSemanticsLabels: false);
    if (text != null && atCharacter > 0 && atCharacter < text.length - 1) {
      final wordCount = text.countOfWords(toIndex: atCharacter);
      return [this, copyWith(word: word + wordCount)];
    }
    return [this, this];
  }
}

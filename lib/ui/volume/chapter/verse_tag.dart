import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';

///
/// Used to tag an HTML text node with the [verse] it is in, the [word] index
/// of the first word in the text node, and a boolean indicating whether or not
/// the associated text node is part of the actual verse text (as apposed to
/// being the verse number, a footnote, a section title, or other text marked
/// with v="0").
///
@immutable
class VerseTag extends Equatable {
  final int verse;
  final int word;
  final int endVerse;
  final bool isInVerse;
  final bool isInXref;
  final bool isInFootnote;
  final String href;

  const VerseTag({
    @required this.verse,
    @required this.word,
    int endVerse,
    this.isInVerse = false,
    this.isInXref = false,
    this.isInFootnote = false,
    this.href,
  })  : assert(verse != null &&
            word != null &&
            (endVerse == null || endVerse >= verse) &&
            isInVerse != null &&
            isInXref != null &&
            isInFootnote != null),
        endVerse = endVerse ?? verse;

  VerseTag copyWith({
    int verse,
    int word,
    int endVerse,
    bool isInVerse,
    bool isInXref,
    bool isInFootnote,
    String href,
  }) =>
      VerseTag(
        verse: verse ?? this.verse,
        word: word ?? this.word,
        endVerse: endVerse ?? verse ?? this.endVerse,
        isInVerse: isInVerse ?? this.isInVerse,
        isInXref: isInXref ?? this.isInXref,
        isInFootnote: isInFootnote ?? this.isInFootnote,
        href: href ?? this.href,
      );

  @override
  List<Object> get props => [verse, word, endVerse, isInVerse, isInXref, isInFootnote, href];

  @override
  String toString() {
    final buf = StringBuffer('{ "v": $verse, "w": $word');
    if (endVerse != verse) buf.write(', "endV": $endVerse');
    if (isInVerse) buf.write(', "inV": true');
    if (isInXref) buf.write(', "inXref": true');
    if (isInFootnote) buf.write(', "inFn": true');
    if (href != null) buf.write(', "href": ${jsonEncode(href)}');
    buf.write(' }');
    return buf.toString();
  }
}

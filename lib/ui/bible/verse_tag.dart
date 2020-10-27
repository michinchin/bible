import 'package:flutter/foundation.dart';

///
/// [VerseTag]
///
/// Used to tag an HTML text node with the [verse] it is in, the [word] index
/// of the first word in the text node, and a boolean indicating whether or not
/// the associated text node is part of the actual verse text (as apposed to
/// being the verse number, a footnote, a section title, or other text marked
/// with v="0").
///
@immutable
class VerseTag {
  final int verse;
  final int word;
  final bool isInVerse;
  final bool isInXref;
  final bool isInFootnote;
  final String href;

  const VerseTag({
    @required this.verse,
    @required this.word,
    this.isInVerse = false,
    this.isInXref = false,
    this.isInFootnote = false,
    this.href,
  }) : assert(verse != null &&
            word != null &&
            isInVerse != null &&
            isInXref != null &&
            isInFootnote != null);

  VerseTag copyWith({
    int verse,
    int word,
    bool isInVerse,
    bool isInXref,
    bool isInFootnote,
    String href,
  }) =>
      VerseTag(
        verse: verse ?? this.verse,
        word: word ?? this.word,
        isInVerse: isInVerse ?? this.isInVerse,
        isInXref: isInXref ?? this.isInXref,
        isInFootnote: isInFootnote ?? this.isInFootnote,
        href: href ?? this.href,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseTag &&
          runtimeType == other.runtimeType &&
          verse == other.verse &&
          word == other.word &&
          isInVerse == other.isInVerse;

  @override
  int get hashCode => verse.hashCode ^ word.hashCode ^ isInVerse.hashCode;

  @override
  String toString() {
    return ('{ "v": $verse, "w": $word, "inV": $isInVerse }');
  }
}

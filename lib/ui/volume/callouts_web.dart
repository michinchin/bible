import 'dart:math';

import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

Future<void> copyCalloutsDB() async {}

Future<ErrorOrValue<Map<int, Map<int, ResourceIntro>>>> chapterCallouts(
    BookChapterVerse ref) async {
  final totalVerses =
      VolumesRepository.shared.bibleWithId(9).versesIn(book: ref.book, chapter: ref.chapter);

  final verses = <int>[];
  final offset = random(min: 1, max: 4);
  const delta = 10;
  final verse =
      (ref.verse + offset < totalVerses) ? ref.verse + offset : max(2, ref.verse - offset);
  for (var v = verse % delta; v < totalVerses; v += delta) {
    if (v >= 2) verses.add(v);
  }

  assert(verses.isNotEmpty);

  return VolumesRepository.shared.resourceCallouts(
      book: ref.book, chapter: ref.chapter, verses: verses, volumes: [1017, 1900]);
}

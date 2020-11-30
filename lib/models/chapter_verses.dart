import 'package:tec_cache/tec_cache.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

class ChapterVerses {
  Map<int, String> data = {};
  ChapterVerses({this.data});

  factory ChapterVerses.fromJson(Map<String, dynamic> json) {
    final verses = tec.as<Map<String, dynamic>>(json['verses']);
    final v = <int, String>{};
    for (final verseNum in verses.keys) {
      final verse = {int.parse(verseNum): tec.as<String>(verses[verseNum])};
      if (verse != null) {
        v.addAll(verse);
      }
    }
    return ChapterVerses(data: v);
  }

  static Future<ChapterVerses> fetch({Reference refForChapter}) async {
    final cacheParam =
        '${refForChapter.volume}/chapters/${refForChapter.book}_${refForChapter.chapter}';
    // check cloudfront cache
    final json = await TecCache.shared.jsonFromUrl(
      url: '${tec.streamUrl}/$cacheParam.json.gz',
      connectionTimeout: const Duration(seconds: 10),
    );

    if (tec.isNullOrEmpty(json)) {
      return Future.error('Error getting results from server');
    }
    return ChapterVerses.fromJson(json);
  }

  static String formatForShare(List<Reference> refs, Map<int, VerseText> verses,
      {bool includeRef = true}) {
    final buffer = StringBuffer();
    for (final ref in refs) {
      if (includeRef) {
        final label = ref.label();
        buffer.writeln(label);
      }
      var firstVerse = true;
      for (final verseNum in verses.keys) {
        var verseNumString = '';
        if (!firstVerse) {
          verseNumString += '[$verseNum';
          final endVerse = verses[verseNum].endVerse;
          if (verseNum < endVerse) {
            verseNumString += '-$endVerse] ';
          } else {
            verseNumString += '] ';
          }
        }
        buffer..write(verseNumString)..write(verses[verseNum].text);
        firstVerse = false;
      }
      if (ref != refs.last) {
        buffer.writeln('\n');
      }
    }
    return buffer.toString();
  }
}

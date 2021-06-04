import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart';

class Context {
  final int initialVerse;
  final int finalVerse;
  final String text;

  const Context({this.initialVerse = 0, this.finalVerse = 0, this.text = ''});

  static Future<Context> fetch({
    int translation,
    int book,
    int chapter,
    int verse,
    String content,
  }) async {
    final regex = RegExp(r'\[([0-9]+)\]');
    final arr = regex.allMatches(content).toList();
    var endVerse = verse;

    if (arr.isNotEmpty) {
      try {
        endVerse = int.parse(arr.last.group(1));
      } catch (_) {
        dmPrint('error getting range endVerse');
      }
    }

    final json = await TecCache.shared.jsonFromUrl(
      url: '$cloudFrontStreamUrl/$translation/chapters/${book}_$chapter.json',
    );

    final verses = json == null
        ? <int, String>{}
        : <int, String>{
            for (final e in as<Map<String, dynamic>>(json['verses']).entries)
              int.parse(e.key): as<String>(e.value)
          };

    var initialVerse = 0;
    var finalVerse = 0;

    String _getString(int verseId, int endVerseId) {
      var vId = verseId;
      var v = verseId - 1;
      var before = '';
      var after = '';
      const charsToShow = 200;
      final wholeChapter = verses;

      while (v >= 1 && before.length < charsToShow) {
        final verse = wholeChapter[v];
        if (verse != null) {
          if (before.isNotEmpty) {
            before = ' $before';
          }
          before = verse + before;
          before = ' [$v] $before';
        }
        v--;
      }
      initialVerse = ++v;

      final verse = wholeChapter[v];
      if (verse != null && verse.isNotEmpty) {
        before += ' [$verseId] ${wholeChapter[verseId]}';
      }

      // adding range verses...
      while (vId < endVerseId) {
        vId++;
        final verse = wholeChapter[vId];
        if (verse != null && verse.isNotEmpty) {
          before += ' [$vId] ${wholeChapter[vId]}';
        }
      }

      if (verseId <= wholeChapter.keys.last) {
        v = ++vId;
        while (v <= verseId + 10 && after.length < charsToShow && v <= wholeChapter.keys.last) {
          final verse = wholeChapter[v];
          if (verse != null) {
            if (after.isNotEmpty) {
              after += ' ';
            }
            after += ' [$v] ';
            after += verse;
          }
          v++;
        }
        finalVerse = --v;
      } else {
        finalVerse = ++v;
      }

      return before.replaceFirst(' ', '') + after;
    }

    final text = _getString(verse, endVerse);
    return Context(initialVerse: initialVerse, finalVerse: finalVerse, text: text);
  }
}

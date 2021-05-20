import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../chapter_verses.dart';

class VotdEntry {
  final String imageUrl;
  final String refs;
  final int year;
  final int ordinalDay;
  VotdEntry({this.imageUrl, this.refs, this.year, this.ordinalDay});

  Reference get ref {
    final hrefs = refs.split(';').map<Reference>((href) => Reference.fromHref(href)).toList();
    var finalRef = hrefs[0];
    for (var i = 0; i < hrefs.length - 1; i++) {
      final h1 = hrefs[i];
      final h2 = hrefs[i + 1];
      final sameBookChapter = h1.book == h2.book && h1.chapter == h2.chapter;
      final isSequential = h1.verse + 1 == h2.verse;
      if (sameBookChapter && isSequential) {
        finalRef = finalRef.copyWith(endVerse: h2.verse);
      }
    }
    return finalRef;
  }

  Future<ErrorOrValue<String>> getFormattedVerse(Bible bible) async {
    final refAndVerse = await bible?.referenceAndVerseTextWith(ref);
    if (refAndVerse.error == null &&
        refAndVerse.value != null &&
        isNotNullOrEmpty(refAndVerse.value.verseText)) {
      final verseText = refAndVerse.value.verseText;
      return ErrorOrValue(
          refAndVerse.error,
          ChapterVerses.formatForShare([refAndVerse.value.reference], verseText,
              includeRef: false));
    } else {
      return ErrorOrValue(refAndVerse.error, '');
    }
  }
}

class Votd {
  final List<dynamic> data;
  final Map<String, dynamic> specials;
  final List<String> verses;
  Votd({this.data, this.specials, this.verses});

  factory Votd.fromJson(Map<String, dynamic> json) {
    final specials = as<Map<String, dynamic>>(json['specials']);
    final data = as<List<dynamic>>(json['data']);

    return Votd(data: data, specials: specials);
  }

  static Future<Votd> fetch({int year}) async {
    final y = year ?? DateTime.now().year;
    const hostAndPath = '$cloudFrontStreamUrl/home';
    final fileName = 'votd-$y.json';
    final json = await TecCache.shared.jsonFromUrl(
        url: '$hostAndPath/$fileName',
        cachedPath: '${hostAndPath.replaceAll('https://', '')}/$fileName',
        bundlePath: 'assets/$fileName');

    if (json != null) {
      return Votd.fromJson(json);
    } else {
      return null;
    }
  }

  int ordinalDay(DateTime time) =>
      indexForDay(dayOfTheYear(time), year: time.year, length: data.length);

  VotdEntry forDateTime(DateTime time) {
    final ordinalDay =
        indexForDay(dayOfTheYear(time), year: time.year, length: data.length);
    if (isNotNullOrEmpty(specials) && isNotNullOrEmpty(data)) {
      final isSpecial = isNullOrEmpty(specials['${ordinalDay + 1}']);
      final image =
          as<String>(isSpecial ? data[ordinalDay][1] : specials['${ordinalDay + 1}'][1]);
      final refs =
          as<String>(isSpecial ? data[ordinalDay][0] : specials['${ordinalDay + 1}'][0]);
      return VotdEntry(
        imageUrl: '$cloudFrontStreamUrl/votd/$image',
        refs: refs,
        year: time.year,
        ordinalDay: ordinalDay,
      );
    }
    return null;
  }
}

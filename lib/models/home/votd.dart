import 'package:tec_cache/tec_cache.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

class VotdEntry {
  final String imageUrl;
  final String refs;
  VotdEntry({this.imageUrl, this.refs});

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

  Future<tec.ErrorOrValue<String>> getFormattedVerse(Bible bible) async {
    final verseText = await bible?.verseTextWith(ref.book, ref.chapter, ref.verses.toList());
    if (verseText.error == null && tec.isNotNullOrEmpty(verseText.value)) {
      final verse = verseText.value;
      return tec.ErrorOrValue(verseText.error, _formatVerse(verse));
    } else {
      return tec.ErrorOrValue(verseText.error, '');
    }
  }

  String _formatVerse(Map<int, String> verse) {
    // final buffer = StringBuffer();
    // for (final v in verse.keys) {
    //   if (v != verse.keys.first) {
    //     buffer.write(' [$v] ');
    //   }
    //   buffer.write('${verse[v]}');
    // }
    // return buffer.toString();
    return verse.values.join(' ');
  }
}

class Votd {
  final List<dynamic> data;
  final Map<String, dynamic> specials;
  final List<String> verses;
  Votd({this.data, this.specials, this.verses});

  factory Votd.fromJson(Map<String, dynamic> json) {
    final specials = tec.as<Map<String, dynamic>>(json['specials']);
    final data = tec.as<List<dynamic>>(json['data']);

    return Votd(data: data, specials: specials);
  }

  static Future<Votd> fetch(TecEnv env) async {
    final year = DateTime.now().year;
    final hostAndPath = '${env.streamServerAndVersion}/home';
    final fileName = 'votd-$year.json';
    final json = await TecCache().jsonFromUrl(
        url: 'https://$hostAndPath/$fileName',
        cachedPath: '$hostAndPath/$fileName',
        bundlePath: 'assets/$fileName');

    if (json != null) {
      return Votd.fromJson(json);
    } else {
      return null;
    }
  }

  VotdEntry forDateTime(DateTime time) {
    final ordinalDay = time.difference(DateTime(time.year, 1, 1)).inDays;
    if (tec.isNotNullOrEmpty(specials) && tec.isNotNullOrEmpty(data)) {
      final isSpecial = tec.isNullOrEmpty(specials['${ordinalDay + 1}']);
      final image =
          tec.as<String>(isSpecial ? data[ordinalDay][1] : specials['${ordinalDay + 1}'][1]);
      final refs =
          tec.as<String>(isSpecial ? data[ordinalDay][0] : specials['${ordinalDay + 1}'][0]);
      return VotdEntry(
        imageUrl: '${tec.streamUrl}/votd/$image',
        refs: refs,
      );
    }
    return null;
  }
}

extension DateTimeExtension on DateTime {
  int ordinalDay(int count) {
    final firstDay = DateTime.utc(year, 1, 1);
    final day = difference(firstDay).inDays;
    var index = (day > 0 ? day - 1 : 0); // Day starts at 1, index should start at 0.

    // Are we past Feb 28?
    if (day > 59) {
      if (isLeapYear(year)) {
        if (count == 365) {
          // It IS a leap year, is past Feb 28, and array DOES NOT have leap day entry, so decrement index.
          index--;
        }
      } else if (count == 366) {
        // It IS NOT a leap year, is past Feb 28, and array DOES have leap day entry, so increment index.
        index++;
      }
    }

    if (index >= count && count > 0) {
      // If index is greater than or equal to count, use the modulo operator to wrap index to fit in count.
      return index % count;
    } else {
      return index;
    }
  }

  bool isLeapYear(int year) => (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
}

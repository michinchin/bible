import 'package:tec_cache/tec_cache.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

class VotdEntry {
  final String imageUrl;
  final String refs;
  VotdEntry({this.imageUrl, this.refs});

// TODO(abby): this is broken
  Reference get ref => Reference.fromHref(refs.replaceAll(';', ','));

  Future<tec.ErrorOrValue<Map<int, String>>> getRes(Bible bible) =>
      bible.verseTextWith(ref.book, ref.chapter, ref.verses.toList());
}

class Votd {
  final List<dynamic> data;
  final Map<String, dynamic> specials;
  Votd({this.data, this.specials});

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
    final isSpecial = tec.isNullOrEmpty(specials['${ordinalDay + 1}']);
    final image =
        tec.as<String>(isSpecial ? data[ordinalDay][1] : specials['${ordinalDay + 1}'][1]);
    final refs = tec.as<String>(isSpecial ? data[ordinalDay][0] : specials['${ordinalDay + 1}'][0]);
    return VotdEntry(
      imageUrl: '${tec.streamUrl}/votd/$image',
      refs: refs,
    );
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

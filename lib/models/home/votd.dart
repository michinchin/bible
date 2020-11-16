import 'dart:collection';

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
    final refAndVerse = await bible?.referenceAndVerseTextWith(ref);
    if (refAndVerse.error == null &&
        refAndVerse.value != null &&
        tec.isNotNullOrEmpty(refAndVerse.value.verseText)) {
      final verseText = refAndVerse.value.verseText;
      return tec.ErrorOrValue(refAndVerse.error, _formatVerse(verseText));
    } else {
      return tec.ErrorOrValue(refAndVerse.error, '');
    }
  }

  String _formatVerse(LinkedHashMap<int, VerseText> verse) {
    final buffer = StringBuffer();
    for (final v in verse.keys) {
      if (v != verse.keys.first) {
        buffer.write(' [$v] ');
      }
      buffer.write('${verse[v].text}');
    }
    return buffer.toString();
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
    final ordinalDay =
        tec.indexForDay(tec.dayOfTheYear(time), year: time.year, length: data.length);
    if (tec.isNotNullOrEmpty(specials) && tec.isNotNullOrEmpty(data)) {
      final isSpecial = tec.isNullOrEmpty(specials['$ordinalDay']);
      final image = tec.as<String>(isSpecial ? data[ordinalDay][1] : specials['$ordinalDay'][1]);
      final refs = tec.as<String>(isSpecial ? data[ordinalDay][0] : specials['$ordinalDay'][0]);
      return VotdEntry(
        imageUrl: '${tec.streamUrl}/votd/$image',
        refs: refs,
      );
    }
    return null;
  }
}

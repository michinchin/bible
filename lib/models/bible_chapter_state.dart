import 'package:flutter/material.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

@immutable
class BibleChapterState {
  final int bibleId;
  final BookChapterVerse bcv;
  final int page;
  final String title;

  BibleChapterState(this.bibleId, this.bcv, this.page, {String title})
      : title = title ??
            VolumesRepository.shared
                .bibleWithId(bibleId)
                .titleWithHref('${bcv.book}/${bcv.chapter}');

  static BookChapterVerse initialBCV() {
    return const BookChapterVerse(50, 1, 1);
  }

  factory BibleChapterState.initial() {
    return BibleChapterState(51, initialBCV(), 0);
  }

  factory BibleChapterState.fromJson(Object o) {
    BookChapterVerse bcv;
    int page, bibleId;

    final json = (o is String) ? tec.parseJsonSync(o) : o;
    if (json is Map<String, dynamic>) {
      bibleId = tec.as<int>(json['vid']) ?? 50;
      bcv = BookChapterVerse.fromJson(json['bcv']) ?? initialBCV();
      page = tec.as<int>(json['page']) ?? 0;
    }

    return BibleChapterState(bibleId, bcv, page);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'vid': bibleId, 'bcv': bcv, 'page': page, 'title': title};
  }

  @override
  String toString() {
    return tec.toJsonString(toJson());
  }
}

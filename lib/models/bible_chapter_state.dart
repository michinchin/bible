import 'package:flutter/material.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

const _defaultBibleId = 9;
const _defaultBCV = BookChapterVerse(50, 1, 1);

@immutable
class BibleChapterState {
  final int bibleId;
  final BookChapterVerse bcv;
  final int page;
  final String title;

  BibleChapterState(this.bibleId, this.bcv, this.page, {String title})
      : assert(bibleId != null && bcv != null && page != null),
        title = title ??
            VolumesRepository.shared
                .bibleWithId(bibleId)
                .titleWithBookAndChapter(bcv.book, bcv.chapter, includeAbbreviation: true);

  factory BibleChapterState.initial() {
    return BibleChapterState(_defaultBibleId, _defaultBCV, 0);
  }

  factory BibleChapterState.fromJson(Object o) {
    int bibleId;
    BookChapterVerse bcv;
    int page;

    final json = (o is String) ? tec.parseJsonSync(o) : o;
    if (json is Map<String, dynamic>) {
      bibleId = tec.as<int>(json['vid']);
      bcv = BookChapterVerse.fromJson(json['bcv']);
      page = tec.as<int>(json['page']);
    }

    return BibleChapterState(
      bibleId ?? _defaultBibleId,
      bcv ?? _defaultBCV,
      page ?? 0,
    );
  }

  String get bookNameAndChapter =>
      VolumesRepository.shared.bibleWithId(bibleId).titleWithBookAndChapter(bcv.book, bcv.chapter);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'vid': bibleId, 'bcv': bcv, 'page': page, 'title': title};
  }

  @override
  String toString() {
    return tec.toJsonString(toJson());
  }
}

extension on Bible {
  String titleWithBookAndChapter(int book, int chapter, {bool includeAbbreviation = false}) {
    if (includeAbbreviation) {
      return '${nameOfBook(book)} $chapter, $abbreviation';
    }
    return '${nameOfBook(book)} $chapter';
  }
}

import 'package:flutter/material.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../blocs/view_data/view_data.dart';

@immutable
class BibleViewData extends ViewData {
  static const _defaultBibleId = 9;
  static const _defaultBCV = BookChapterVerse(50, 1, 1);

  final int bibleId;
  final BookChapterVerse bcv;
  final int page;

  const BibleViewData(this.bibleId, this.bcv, this.page)
      : assert(bibleId > 0 && bcv != null && page != null),
        super();

  String get bookNameAndChapter =>
      VolumesRepository.shared.bibleWithId(bibleId).titleWithBookAndChapter(bcv.book, bcv.chapter);

  @override
  List<Object> get props => super.props..addAll([bibleId, bcv, page]);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson() ?? <String, dynamic>{};
    json['vid'] = bibleId;
    json['bcv'] = bcv;
    json['page'] = page;
    return json;
  }

  factory BibleViewData.fromJson(Object json) {
    int bibleId;
    BookChapterVerse bcv;
    int page;

    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      bibleId = tec.as<int>(jsonMap['vid']);
      bcv = BookChapterVerse.fromJson(jsonMap['bcv']);
      page = tec.as<int>(jsonMap['page']);
    }

    return BibleViewData(bibleId ?? _defaultBibleId, bcv ?? _defaultBCV, page ?? 0);
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

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../view_manager/view_manager_bloc.dart';
import 'view_data.dart';

export 'view_data.dart';

const _defaultBibleId = 9;
const _defaultBCV = BookChapterVerse(50, 1, 1);

///
/// VolumeViewData
///
@immutable
class VolumeViewData extends ViewData {
  final int volumeId;
  final BookChapterVerse bcv;

  const VolumeViewData(this.volumeId, this.bcv)
      : assert(volumeId > 0 && bcv != null),
        super();

  factory VolumeViewData.fromContext(BuildContext context, int viewUid) {
    return VolumeViewData.fromJson(context.bloc<ViewManagerBloc>()?.dataWithView(viewUid));
  }

  String get bookNameAndChapter =>
      (VolumesRepository.shared.bibleWithId(volumeId) ?? VolumesRepository.shared.bibleWithId(9))
          .titleWithBookAndChapter(bcv.book, bcv.chapter);

  String get bookNameChapterAndAbbr {
    final volume = VolumesRepository.shared.volumeWithId(volumeId);
    assert(volume != null);
    final bible = volume is Bible ? volume : VolumesRepository.shared.bibleWithId(9);
    assert(bible != null && (volume.type != VolumeType.bible || identical(volume, bible)));
    return '${bible.titleWithBookAndChapter(bcv.book, bcv.chapter)}, ${volume.abbreviation}';
  }

  @override
  List<Object> get props => super.props..addAll([volumeId, bcv]);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson() ?? <String, dynamic>{};
    json['vid'] = volumeId;
    json['bcv'] = bcv;
    return json;
  }

  factory VolumeViewData.fromJson(Object json) {
    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    int volumeId;
    BookChapterVerse bcv;
    if (jsonMap is Map<String, dynamic>) {
      volumeId = tec.as<int>(jsonMap['vid']);
      bcv = BookChapterVerse.fromJson(jsonMap['bcv']);
    }
    return VolumeViewData(volumeId ?? _defaultBibleId, bcv ?? _defaultBCV);
  }
}

///
/// ChapterViewData
///
class ChapterViewData extends VolumeViewData {
  final int page;

  const ChapterViewData(int volumeId, BookChapterVerse bcv, this.page)
      : assert(page != null),
        super(volumeId, bcv);

  factory ChapterViewData.fromContext(BuildContext context, int viewUid) {
    return ChapterViewData.fromJson(context.bloc<ViewManagerBloc>()?.dataWithView(viewUid));
  }

  int get bibleId => volumeId;

  @override
  List<Object> get props => super.props..addAll([page]);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson() ?? <String, dynamic>{};
    json['page'] = page;
    return json;
  }

  factory ChapterViewData.fromJson(Object json) {
    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    final viewData = VolumeViewData.fromJson(jsonMap);
    int page;
    if (jsonMap is Map<String, dynamic>) {
      page = tec.as<int>(jsonMap['page']);
    }
    return ChapterViewData(viewData.volumeId, viewData.bcv, page ?? 0);
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

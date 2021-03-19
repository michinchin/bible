import 'package:flutter/material.dart';

import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';

import '../../blocs/shared_bible_ref_bloc.dart';
import 'study/study_view_data.dart';

export 'package:tec_views/tec_views.dart' show ViewData;

///
/// VolumeViewData
///
@immutable
class VolumeViewData extends ViewData {
  final int volumeId;
  final BookChapterVerse bcv;
  final int page;
  final bool useSharedRef;

  const VolumeViewData(
    this.volumeId,
    this.bcv,
    this.page, {
    @required this.useSharedRef,
  })  : assert(volumeId > 0 && bcv != null && page != null && useSharedRef != null),
        super();

  @override
  VolumeViewData copyWith({int volumeId, BookChapterVerse bcv, bool useSharedRef, int page}) =>
      VolumeViewData(
        volumeId ?? this.volumeId,
        bcv ?? this.bcv,
        page ?? this.page,
        useSharedRef: useSharedRef ?? this.useSharedRef,
      );

  factory VolumeViewData.fromContext(BuildContext context, int viewUid) {
    final jsonMap = parseJsonSync(context.viewManager?.dataWithView(viewUid));

    // This is kinda a hack, but if the json has a 'studyTab' key, it is `StudyViewData`.
    if (jsonMap?.containsKey('studyTab') ?? false) {
      return StudyViewData.fromJson(jsonMap);
    } else {
      return VolumeViewData.fromJson(jsonMap);
    }
  }

  String bookNameAndChapter({bool useShortBookName = false}) =>
      (VolumesRepository.shared.bibleWithId(volumeId) ??
              VolumesRepository.shared.bibleWithId(defaultBibleId))
          .titleWithBookAndChapter(bcv.book, bcv.chapter, useShortBookName: useShortBookName);

  String get bookNameChapterAndAbbr {
    final volume = VolumesRepository.shared.volumeWithId(volumeId);
    assert(volume != null);
    final bible = volume is Bible ? volume : VolumesRepository.shared.bibleWithId(defaultBibleId);
    assert(bible != null && (volume.type != VolumeType.bible || identical(volume, bible)));
    return '${bible.titleWithBookAndChapter(bcv.book, bcv.chapter)} ${volume.abbreviation}';
  }

  @override
  List<Object> get props => super.props..addAll([volumeId, bcv, page, useSharedRef]);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson() ?? <String, dynamic>{};
    json['vid'] = volumeId;
    json['bcv'] = bcv;
    json['page'] = page;
    if (!useSharedRef) json['useSharedRef'] = false;
    return json;
  }

  factory VolumeViewData.fromJson(Object json) {
    int volumeId;
    BookChapterVerse bcv;
    int page;
    bool useSharedRef;

    final jsonMap = json is String ? parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      volumeId = as<int>(jsonMap['vid']);
      bcv = BookChapterVerse.fromJson(jsonMap['bcv']);
      page = as<int>(jsonMap['page']);
      useSharedRef = as<bool>(jsonMap['useSharedRef']);
    }

    return VolumeViewData(
      volumeId ?? defaultBibleId,
      bcv ?? defaultBCV,
      page ?? 0,
      useSharedRef: useSharedRef ?? true,
    );
  }
}

extension VolumeViewDataExtOnViewData on ViewData {
  VolumeViewData get asVolumeViewData => this as VolumeViewData;
}

extension ViewManagerExtOnViewState on ViewState {
  VolumeViewData volumeDataWith(BuildContext context) => VolumeViewData.fromContext(context, uid);
}

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../shared_bible_ref_bloc.dart';
import '../view_manager/view_manager_bloc.dart';
import 'view_data.dart';

export 'view_data.dart';

const defaultBibleId = 9;
const defaultBCV = BookChapterVerse(50, 1, 1);

extension VolumeViewDataExtOnVolume on Volume {
  Bible get assocBible => this is Bible
      ? this as Bible
      : (VolumesRepository.shared.bibleWithId(assocVolumeId > 0 ? assocVolumeId : defaultBibleId) ??
          VolumesRepository.shared.bibleWithId(defaultBibleId));
}

///
/// VolumeViewData
///
@immutable
class VolumeViewData extends ViewData {
  final int volumeId;
  final BookChapterVerse bcv;
  final bool useSharedRef;

  const VolumeViewData(
    this.volumeId,
    this.bcv, {
    @required this.useSharedRef,
  })  : assert(volumeId > 0 && bcv != null && useSharedRef != null),
        super();

  @override
  VolumeViewData copyWith({int volumeId, BookChapterVerse bcv, bool useSharedRef}) =>
      VolumeViewData(
        volumeId ?? this.volumeId,
        bcv ?? this.bcv,
        useSharedRef: useSharedRef ?? this.useSharedRef,
      );

  factory VolumeViewData.fromContext(BuildContext context, int viewUid) {
    var viewData = VolumeViewData.fromJson(context.bloc<ViewManagerBloc>()?.dataWithView(viewUid));
    if (viewData.useSharedRef) {
      final bcv = context.bloc<SharedBibleRefBloc>()?.state;
      if (bcv != null) viewData = viewData.copyWith(bcv: bcv);
    }
    return viewData;
  }

  String get bookNameAndChapter => (VolumesRepository.shared.bibleWithId(volumeId) ??
          VolumesRepository.shared.bibleWithId(defaultBibleId))
      .titleWithBookAndChapter(bcv.book, bcv.chapter);

  String get bookNameChapterAndAbbr {
    final volume = VolumesRepository.shared.volumeWithId(volumeId);
    assert(volume != null);
    final bible = volume is Bible ? volume : VolumesRepository.shared.bibleWithId(defaultBibleId);
    assert(bible != null && (volume.type != VolumeType.bible || identical(volume, bible)));
    return '${bible.titleWithBookAndChapter(bcv.book, bcv.chapter)} | ${volume.abbreviation}';
  }

  @override
  List<Object> get props => super.props..addAll([volumeId, bcv]);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson() ?? <String, dynamic>{};
    json['vid'] = volumeId;
    json['bcv'] = bcv;
    if (!useSharedRef) json['useSharedRef'] = false;
    return json;
  }

  factory VolumeViewData.fromJson(Object json) {
    int volumeId;
    BookChapterVerse bcv;
    bool useSharedRef;

    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      volumeId = tec.as<int>(jsonMap['vid']);
      bcv = BookChapterVerse.fromJson(jsonMap['bcv']);
      useSharedRef = tec.as<bool>(jsonMap['useSharedRef']);
    }

    return VolumeViewData(
      volumeId ?? defaultBibleId,
      bcv ?? defaultBCV,
      useSharedRef: useSharedRef ?? true,
    );
  }
}

///
/// ChapterViewData
///
class ChapterViewData extends VolumeViewData {
  final int page;

  const ChapterViewData(
    int volumeId,
    BookChapterVerse bcv,
    this.page, {
    @required bool useSharedRef,
  })  : assert(page != null),
        super(volumeId, bcv, useSharedRef: useSharedRef);

  @override
  ChapterViewData copyWith({int volumeId, BookChapterVerse bcv, bool useSharedRef, int page}) =>
      ChapterViewData(
        volumeId ?? this.volumeId,
        bcv ?? this.bcv,
        page ?? this.page,
        useSharedRef: useSharedRef ?? this.useSharedRef,
      );

  factory ChapterViewData.fromContext(BuildContext context, int viewUid) {
    var viewData = ChapterViewData.fromJson(context.bloc<ViewManagerBloc>()?.dataWithView(viewUid));
    if (viewData.useSharedRef) {
      final bcv = context.bloc<SharedBibleRefBloc>()?.state;
      if (bcv != null) viewData = viewData.copyWith(bcv: bcv);
    }
    return viewData;
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

    return ChapterViewData(
      viewData.volumeId,
      viewData.bcv,
      page ?? 0,
      useSharedRef: viewData.useSharedRef,
    );
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

extension VolumeViewDataExtOnViewData on ViewData {
  VolumeViewData get asVolumeViewData => this as VolumeViewData;
  ChapterViewData get asChapterViewData => this as ChapterViewData;
}

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/shared_bible_ref_bloc.dart';
import '../../blocs/view_manager/view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';

export '../../blocs/view_manager/view_data.dart';

class ChapterViewDataBloc extends ViewDataBloc {
  ChapterViewDataBloc(ViewManagerBloc vmBloc, int viewUid, ChapterViewData data)
      : super(vmBloc, viewUid, data);

  @override
  Future<void> update(
    BuildContext context,
    ViewData viewData, {
    bool updateSharedRef = true,
  }) async {
    assert(viewData != null && viewData is ChapterViewData);
    await super.update(context, viewData);
    if (updateSharedRef && viewData is ChapterViewData && viewData.useSharedRef) {
      _isUpdatingSharedBibleRef = true;
      context.read<SharedBibleRefBloc>()?.update(viewData.bcv);
      _isUpdatingSharedBibleRef = false;
    }
  }

  bool get isUpdatingSharedBibleRef => _isUpdatingSharedBibleRef;
  var _isUpdatingSharedBibleRef = false;
}

///
/// ChapterViewData
///
@immutable
class ChapterViewData extends ViewData {
  final int volumeId;
  final BookChapterVerse bcv;
  final int page;
  final bool useSharedRef;

  const ChapterViewData(
    this.volumeId,
    this.bcv,
    this.page, {
    @required this.useSharedRef,
  })  : assert(volumeId > 0 && bcv != null && page != null && useSharedRef != null),
        super();

  @override
  ChapterViewData copyWith({int volumeId, BookChapterVerse bcv, bool useSharedRef, int page}) =>
      ChapterViewData(
        volumeId ?? this.volumeId,
        bcv ?? this.bcv,
        page ?? this.page,
        useSharedRef: useSharedRef ?? this.useSharedRef,
      );

  factory ChapterViewData.fromContext(BuildContext context, int viewUid) {
    return ChapterViewData.fromJson(context.viewManager?.dataWithView(viewUid));
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
    return '${bible.titleWithBookAndChapter(bcv.book, bcv.chapter)} | ${volume.abbreviation}';
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

  factory ChapterViewData.fromJson(Object json) {
    int volumeId;
    BookChapterVerse bcv;
    int page;
    bool useSharedRef;

    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      volumeId = tec.as<int>(jsonMap['vid']);
      bcv = BookChapterVerse.fromJson(jsonMap['bcv']);
      page = tec.as<int>(jsonMap['page']);
      useSharedRef = tec.as<bool>(jsonMap['useSharedRef']);
    }

    return ChapterViewData(
      volumeId ?? defaultBibleId,
      bcv ?? defaultBCV,
      page ?? 0,
      useSharedRef: useSharedRef ?? true,
    );
  }
}

extension ChapterViewDataExtOnViewData on ViewData {
  ChapterViewData get asChapterViewData => this as ChapterViewData;
}

extension ViewManagerExtOnViewState on ViewState {
  ChapterViewData chapterDataWith(BuildContext context) =>
      ChapterViewData.fromContext(context, uid);
}

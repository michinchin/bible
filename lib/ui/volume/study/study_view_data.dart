import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../volume_view_data_bloc.dart';

extension StudyViewDataExtOnViewData on ViewData {
  StudyViewData get asStudyViewData {
    if (this is StudyViewData) return this as StudyViewData;
    return StudyViewData.fromViewData(this as VolumeViewData);
  }
}

///
/// StudyViewData
///
@immutable
class StudyViewData extends VolumeViewData {
  final int studyTab;
  final List<StudyItem> resStack;

  const StudyViewData(
    int volumeId,
    BookChapterVerse bcv,
    int page, {
    @required bool useSharedRef,
    this.studyTab = 0,
    this.resStack = const [],
  })  : assert(volumeId != null && volumeId >= 1000 && volumeId < 7000),
        assert(bcv != null && page != null),
        assert(studyTab != null && resStack != null),
        super(volumeId, bcv, page, useSharedRef: useSharedRef);

  factory StudyViewData.fromViewData(VolumeViewData viewData) {
    return StudyViewData(viewData.volumeId, viewData.bcv, viewData.page,
        useSharedRef: viewData.useSharedRef);
  }

  @override
  StudyViewData copyWith({
    int volumeId,
    BookChapterVerse bcv,
    int page,
    bool useSharedRef,
    int studyTab,
    List<StudyItem> resStack,
  }) =>
      StudyViewData(
        volumeId ?? this.volumeId,
        bcv ?? this.bcv,
        page ?? this.page,
        useSharedRef: useSharedRef ?? this.useSharedRef,
        studyTab: studyTab ?? this.studyTab,
        resStack: resStack ?? this.resStack,
      );

  factory StudyViewData.fromContext(BuildContext context, int viewUid) {
    return StudyViewData.fromJson(context.viewManager?.dataWithView(viewUid));
  }

  @override
  List<Object> get props => super.props..addAll([studyTab, resStack]);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson() ?? <String, dynamic>{};
    if (studyTab != 0) json['studyTab'] = studyTab;
    if (resStack.isNotEmpty) json['resStack'] = resStack;
    return json;
  }

  factory StudyViewData.fromJson(Object json) {
    final sup = VolumeViewData.fromJson(json);

    var studyTab = 0;
    var resStack = <StudyItem>[];

    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      studyTab = tec.as<int>(jsonMap['studyTab']) ?? 0;
      final resStackJson = tec.asList<Map<String, dynamic>>(jsonMap['resStack']);
      if (tec.isNotNullOrEmpty(resStackJson)) {
        resStack = resStackJson.expand<StudyItem>((json) {
          final studyItem = StudyItem.fromJson(json);
          return studyItem == null ? [] : [studyItem];
        }).toList();
      }
    }

    return StudyViewData(
      sup.volumeId,
      sup.bcv,
      sup.page,
      useSharedRef: sup.useSharedRef,
      studyTab: studyTab,
      resStack: resStack,
    );
  }
}

///
/// StudyItem
///
@immutable
class StudyItem extends Equatable {
  final Resource res;
  final double scrollPercent;

  const StudyItem(this.res, this.scrollPercent);

  @override
  List<Object> get props => [res, scrollPercent];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'volumeId': res.volumeId,
        'res': res,
        'scrollPercent': scrollPercent,
      };

  factory StudyItem.fromJson(Object json) {
    Resource res;
    double scrollPercent;

    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      final volumeId = tec.as<int>(jsonMap['volumeId']);
      final resJson = tec.as<Map<String, dynamic>>(jsonMap['res']);
      if (volumeId != null && resJson != null) {
        res = Resource.fromJson(resJson, volume: volumeId);
        scrollPercent = tec.as<double>(jsonMap['scrollPercent']) ?? 0.0;
      }
    }

    if (res != null) {
      return StudyItem(res, scrollPercent ?? 0.0);
    }
    return null;
  }
}

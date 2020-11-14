import 'package:flutter/widgets.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../bible/chapter_view_data.dart';

class StudyViewDataBloc extends ChapterViewDataBloc {
  StudyViewDataBloc(ViewManagerBloc vmBloc, int viewUid, StudyViewData data)
      : super(vmBloc, viewUid, data);
}

extension StudyViewDataExtOnViewData on ViewData {
  StudyViewData get asStudyViewData => this as StudyViewData;
}

///
/// StudyViewData
///
@immutable
class StudyViewData extends ChapterViewData {
  final int foobar;

  const StudyViewData(
    this.foobar,
    int volumeId,
    BookChapterVerse bcv,
    int page, {
    @required bool useSharedRef,
  }) : super(volumeId, bcv, page, useSharedRef: useSharedRef);

  @override
  StudyViewData copyWith({
    int foobar,
    int volumeId,
    BookChapterVerse bcv,
    bool useSharedRef,
    int page,
  }) =>
      StudyViewData(
        foobar ?? this.foobar,
        volumeId ?? this.volumeId,
        bcv ?? this.bcv,
        page ?? this.page,
        useSharedRef: useSharedRef ?? this.useSharedRef,
      );

  factory StudyViewData.fromContext(BuildContext context, int viewUid) {
    return StudyViewData.fromJson(context.viewManager?.dataWithView(viewUid));
  }

  @override
  List<Object> get props => super.props..addAll([]);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson() ?? <String, dynamic>{};
    if (foobar != 0) json['foobar'] = foobar;
    return json;
  }

  factory StudyViewData.fromJson(Object json) {
    final sup = ChapterViewData.fromJson(json);

    var foobar = 0;

    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      foobar = tec.as<int>(jsonMap['foobar']);
    }

    return StudyViewData(foobar, sup.volumeId, sup.bcv, sup.page, useSharedRef: sup.useSharedRef);
  }
}

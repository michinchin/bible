import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../bible/chapter_view.dart';
import '../library/library.dart';
import 'study_view.dart';
import 'study_view_data.dart';
import 'volume_action_bar.dart';
import 'volume_view_data_bloc.dart';

class ViewableVolume extends Viewable {
  ViewableVolume(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return BlocProvider<VolumeViewDataBloc>.value(
      value: context.viewManager.dataBlocWithView(state.uid) as VolumeViewDataBloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<VolumeViewDataBloc, ViewData>(
          // When the ViewData changes, only rebuild if it changes type (Bible or Study Volume).
          buildWhen: (a, b) =>
              isBibleId(a.asVolumeViewData.volumeId) != isBibleId(b.asVolumeViewData.volumeId),
          builder: (context, viewData) {
            return isBibleId(viewData.asVolumeViewData.volumeId)
                ? PageableChapterView(viewState: state, size: size)
                : StudyView(viewState: state, size: size, viewData: viewData as VolumeViewData);
          },
        ),
      ),
    );
  }

  @override
  Widget floatingTitleBuilder(BuildContext context, ViewState state, Size size) {
    return BlocProvider<VolumeViewDataBloc>.value(
      value: context.viewManager.dataBlocWithView(state.uid) as VolumeViewDataBloc,
      child: VolumeViewActionBar(state: state, size: size),
    );
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) {
    return state?.uid == null
        ? 'Bible'
        : VolumeViewData.fromContext(context, state.uid).bookNameChapterAndAbbr;
  }

  @override
  Future<ViewData> dataForNewView({
    BuildContext context,
    int currentViewId,
    Map<String, dynamic> options,
  }) async {
    final volumeId = await selectVolumeInLibrary(
      context,
      title: 'Open New...',
      initialTabPrefix: options == null ? null : tec.as<String>(options['tab']),
    );
    // tec.dmPrint('selected $bibleId');

    if (volumeId != null) {
      final previous = VolumeViewData.fromContext(context, currentViewId);
      assert(previous != null);
      if (isBibleId(volumeId)) {
        return VolumeViewData(volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
      } else if (isStudyVolumeId(volumeId)) {
        return StudyViewData(0, volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
      }
      assert(false);
    }

    return null;
  }

  @override
  ViewDataBloc createViewDataBloc(BuildContext context, ViewState state) {
    var data = VolumeViewData.fromContext(context, state.uid);
    if (isBibleId(data.volumeId)) {
      return VolumeViewDataBloc(context.viewManager, state.uid, data);
    } else if (isStudyVolumeId(data.volumeId)) {
      data = StudyViewData.fromContext(context, state.uid);
      assert(data != null);
      return StudyViewDataBloc(context.viewManager, state.uid, data as StudyViewData);
    } else {
      assert(false);
    }
    return null;
  }
}

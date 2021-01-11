import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/const.dart';
import '../library/library.dart';
import '../menu/reorder_views.dart';
import 'chapter/chapter_view.dart';
import 'study/study_view.dart';
import 'study/study_view_data.dart';
import 'volume_action_bar.dart';
import 'volume_view_data_bloc.dart';

class ViewableVolume extends Viewable {
  ViewableVolume(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VolumeViewDataBloc>.value(
            value: context.viewManager.dataBlocWithView(state.uid) as VolumeViewDataBloc),
        BlocProvider<DragOverlayCubit>(create: (_) => DragOverlayCubit(state.uid))
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body:
            // Stack(
            //   children: [
            BlocBuilder<VolumeViewDataBloc, ViewData>(
          // When the ViewData changes, only rebuild if it changes type (Bible or Study Volume).
          buildWhen: (a, b) =>
              isBibleId(a.asVolumeViewData.volumeId) != isBibleId(b.asVolumeViewData.volumeId),
          builder: (context, viewData) {
            final child = isBibleId(viewData.asVolumeViewData.volumeId)
                ? PageableChapterView(viewState: state, size: size)
                : StudyView(viewState: state, size: size);
            context.tbloc<DragOverlayCubit>().clear();

            return DragTargetView(child: child, viewUid: state.uid);
          },
        ),

        //     Container(
        //       height: 44,
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         gradient: LinearGradient(
        //           tileMode: TileMode.clamp,
        //           begin: const Alignment(0.0, -0.75),
        //           end: const Alignment(0.0, 1.0),
        //           colors: [Theme.of(context).backgroundColor, Colors.white.withOpacity(0.0)],
        //         ),
        //       ),
        //     ),
        //     Positioned(
        //       bottom: 0.0,
        //       height: 44,
        //       left: 0.0,
        //       right: 0.0,
        //       child: Container(
        //         // height: 44,
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           gradient: LinearGradient(
        //             tileMode: TileMode.clamp,
        //             begin: const Alignment(0.0, -1.0),
        //             end: const Alignment(0.0, 0.75),
        //             colors: [Colors.white.withOpacity(0.0), Theme.of(context).backgroundColor],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
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
      final viewUid = currentViewId ?? context.viewManager?.state?.views?.lastWhere((el) => el.type == Const.viewTypeVolume, orElse: () => null)?.uid;
      final previous = viewUid == null ? VolumeViewData.fromJson(null) : VolumeViewData.fromContext(context, viewUid);
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
      return VolumeViewDataBloc(context.viewManager, state.uid, data as StudyViewData);
    } else {
      assert(false);
    }
    return null;
  }
}

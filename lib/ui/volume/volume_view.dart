import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

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
        BlocProvider<DragOverlayCubit>(create: (_) => DragOverlayCubit())
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

            return DragTarget<int>(
                onWillAccept: (b) {
                  return true;
                },
                onLeave: (b) {
                  // tec.dmPrint(b);
                  if (b != state.uid) {
                    context.tbloc<DragOverlayCubit>().clear();
                  }
                },
                onAccept: (b) {
                  // tec.dmPrint('$b ${state.uid}');
                  context.tbloc<DragOverlayCubit>().clear();
                  if (b != state.uid) {
                    context.viewManager?.add(ViewManagerEvent.move(
                        fromPosition: context.viewManager.indexOfView(b),
                        toPosition: context.viewManager.indexOfView(state.uid)));
                  }
                },
                onMove: (details) =>
                    context.tbloc<DragOverlayCubit>().onMove(context, details, state.uid),
                builder: (c, cd, rd) =>
                    BlocBuilder<DragOverlayCubit, DragOverlayDetails>(builder: (context, s) {
                      return Container(
                          foregroundDecoration: s.inRect && !s.sameView
                              ? BoxDecoration(color: Colors.grey.withOpacity(0.3))
                              : const BoxDecoration(color: Colors.transparent),
                          child: s.sameView && s.inRect
                              ? Stack(alignment: Alignment.center, children: [
                                  child,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      DragTarget<int>(
                                          onAccept: (d) {
                                            context.tbloc<DragOverlayCubit>().clear();
                                            context.viewManager
                                                .add(ViewManagerEvent.remove(state.uid));
                                          },
                                          builder: (c, cd, rd) => Card(
                                                shape: const CircleBorder(),
                                                elevation: cd.isNotEmpty ? 0 : 10,
                                                child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor: cd.isNotEmpty
                                                      ? Colors.grey.withOpacity(0.5)
                                                      : Theme.of(context).cardColor,
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Theme.of(context).textColor,
                                                  ),
                                                ),
                                              )),
                                      DragTarget<int>(
                                        onWillAccept: (d) => true,
                                        onAccept: (d) {
                                          // context.viewManager
                                          //     .add(ViewManagerEvent.);
                                        },
                                        builder: (c, cd, rd) => Card(
                                          shape: const CircleBorder(),
                                          elevation: cd.isNotEmpty ? 0 : 10,
                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundColor: cd.isNotEmpty
                                                ? Colors.grey.withOpacity(0.5)
                                                : Theme.of(context).cardColor,
                                            child: Icon(
                                              Icons.visibility_off_outlined,
                                              color: Theme.of(context).textColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DragTarget<int>(
                                          onWillAccept: (d) => true,
                                          onAccept: (d) {
                                            context.viewManager
                                                .add(ViewManagerEvent.maximize(state.uid));
                                          },
                                          builder: (c, cd, rd) => Card(
                                                shape: const CircleBorder(),
                                                elevation: cd.isNotEmpty ? 0 : 10,
                                                child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor: cd.isNotEmpty
                                                      ? Colors.grey.withOpacity(0.5)
                                                      : Theme.of(context).cardColor,
                                                  child: Icon(
                                                    Icons.fullscreen,
                                                    color: Theme.of(context).textColor,
                                                  ),
                                                ),
                                              )),
                                    ],
                                  )
                                ])
                              : child);
                    }));
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
      return VolumeViewDataBloc(context.viewManager, state.uid, data as StudyViewData);
    } else {
      assert(false);
    }
    return null;
  }
}

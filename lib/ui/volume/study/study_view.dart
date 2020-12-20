import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../../blocs/shared_bible_ref_bloc.dart';
import '../../common/common.dart';
import '../../common/tec_auto_hide_app_bar.dart';
import '../chapter/chapter_view.dart';
import '../volume_view_data_bloc.dart';
import 'study_res_bloc.dart';
import 'study_res_view.dart';
import 'study_view_bloc.dart';

class StudyView extends StatelessWidget {
  final ViewState viewState;
  final Size size;

  const StudyView({Key key, this.viewState, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SharedBibleRefBloc, BookChapterVerse>(
      listener: _sharedBibleRefChanged,
      child: BlocProvider(
        create: (_) => StudyViewBloc()
          ..updateWithData(context.read<VolumeViewDataBloc>().state.asVolumeViewData),
        child: BlocListener<VolumeViewDataBloc, ViewData>(
          listener: (context, viewData) =>
              context.read<StudyViewBloc>().updateWithData(viewData as VolumeViewData),
          child: BlocBuilder<StudyViewBloc, StudyViewState>(
            builder: (context, state) {
              // tec.dmPrint('StudyView.build in StudyViewBloc volume: ${state.volumeId}');
              if (state.sections == null || state.sections.isEmpty) {
                return const Center(child: LoadingIndicator());
              }

              const aboutTitle = 'About';
              const introTitle = 'Intro';
              const resourcesTitle = 'Resources';
              const notesTitle = 'Notes';
              const titles = [aboutTitle, introTitle, resourcesTitle, notesTitle];

              final tabTitles = state.sections.map((e) => titles[e.index]).toList();
              final textStyle = Theme.of(context).textTheme.headline2;

              Widget childForTab(String title) {
                switch (title) {
                  case aboutTitle:
                  case introTitle:
                    return BlocProvider(
                      create: (_) {
                        final viewData = context.read<VolumeViewDataBloc>().state.asVolumeViewData;
                        return StudyResBloc(
                            volumeId: viewData.volumeId,
                            book: title == introTitle ? viewData.bcv.book : 0,
                            chapter: 0,
                            type: ResourceType.introduction);
                      },
                      child: BlocListener<VolumeViewDataBloc, ViewData>(
                        listener: (context, viewData) {
                          if (viewData is VolumeViewData) {
                            // tec.dmPrint('childForTab VolumeViewDataBloc listener volume: '
                            //     '${viewData.volumeId} book: ${viewData.bcv.book}');
                            context.read<StudyResBloc>().update(
                                volumeId: viewData.volumeId,
                                book: title == introTitle ? viewData.bcv.book : 0);
                          }
                        },
                        child: const StudyResView(padding: EdgeInsets.fromLTRB(0, 70, 0, 50)),
                      ),
                    );
                  case notesTitle:
                    return PageableChapterView(
                        viewState: viewState,
                        size: size,
                        htmlPadding: const EdgeInsets.only(top: 50));
                  default:
                    return Center(child: Text(title, style: textStyle));
                }
              }

              final tabs = tabTitles.map((e) => Tab(text: e)).toList();
              final tabContents = tabTitles.map(childForTab).toList();

              return DefaultTabController(
                length: tabs.length,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: TecAutoHideAppBar(
                    appBar: PreferredSizeWidgetWithPadding(
                      padding: const EdgeInsets.only(top: 20),
                      widget: TabBar(tabs: tabs, isScrollable: true),
                    ),
                    body: TabBarView(children: tabContents),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  ///
  /// This is called when the shared bible reference changes.
  ///
  Future<void> _sharedBibleRefChanged(BuildContext context, BookChapterVerse sharedRef) async {
    final viewDataBloc = context.read<VolumeViewDataBloc>();
    final viewData = viewDataBloc.state.asVolumeViewData;
    if (!viewDataBloc.isUpdatingSharedBibleRef &&
        viewData.useSharedRef &&
        viewData.bcv != sharedRef) {
      final newViewData = viewData.copyWith(bcv: sharedRef);
      // tec.dmPrint('StudyView shared ref changed to $sharedRef, '
      //     'calling viewDataBloc.update with $newViewData');
      await viewDataBloc.update(context, newViewData, updateSharedRef: false);
    }
  }
}

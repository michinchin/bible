import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../../blocs/shared_bible_ref_bloc.dart';
import '../../../translations.dart';
import '../../common/common.dart';
import '../../common/tec_auto_hide_app_bar.dart';
import '../../common/tec_navigator.dart';
import '../chapter/chapter_view.dart';
import '../volume_view_data_bloc.dart';
import 'shared_app_bar_bloc.dart';
import 'study_res_bloc.dart';
import 'study_res_view.dart';
import 'study_view_bloc.dart';
import 'study_view_data.dart';

class StudyView extends StatefulWidget {
  final ViewState viewState;
  final Size size;

  const StudyView({Key key, this.viewState, this.size}) : super(key: key);

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  TabController _updateTabController(BuildContext context, {int initialIndex = 0, int length}) {
    if (_tabController == null || _tabController.length != length) {
      _tabController?.dispose();
      _tabController = TabController(initialIndex: initialIndex, length: length, vsync: this)
        ..addListener(() {
          tec.dmPrint('Study tabs changed to index ${_tabController.index}');
          context.read<SharedAppBarBloc>().update(null);

          final bloc = context.read<VolumeViewDataBloc>();
          bloc.update(context, bloc.state.asStudyViewData.copyWith(studyTab: _tabController.index));
        });
    }
    return _tabController;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SharedBibleRefBloc, BookChapterVerse>(
      listener: handleSharedBibleRefChange,
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

              final _aboutTitle = 'About'.i18n;
              final _introTitle = 'Intro'.i18n;
              final _resourcesTitle = 'Resources'.i18n;
              final _notesTitle = 'Notes'.i18n;
              final _titles = [_aboutTitle, _introTitle, _resourcesTitle, _notesTitle];

              final tabTitles = state.sections.map((e) => _titles[e.index]).toList();

              final tabs = tabTitles.map((e) => Tab(text: e)).toList();

              return BlocProvider(
                create: (context) => SharedAppBarBloc(),
                child: BlocBuilder<SharedAppBarBloc, SharedAppBarState>(
                  builder: (context, appBarState) {
                    final studyViewData = context.tbloc<VolumeViewDataBloc>().state.asStudyViewData;

                    final tabController = _updateTabController(context,
                        length: tabs.length, initialIndex: studyViewData.studyTab);

                    final appBar = PreferredSizeColumn(
                      padding: const EdgeInsets.only(top: 20),
                      children: [
                        TabBar(tabs: tabs, controller: tabController, isScrollable: true),
                        if (appBarState.title != null || appBarState.onTapBack != null)
                          AppBar(
                            title: Text(appBarState.title ?? ''),
                            backgroundColor: Theme.of(context).backgroundColor,
                            centerTitle: true,
                            elevation: 1,
                            leading: appBarState.onTapBack == null
                                ? null
                                : BackButton(onPressed: appBarState.onTapBack),
                          ),
                      ],
                    );

                    final top = appBar.preferredSize.height;
                    tec.dmPrint('top padding: $top');
                    final padding = EdgeInsets.fromLTRB(0, top, 0, 50);

                    final tabContents = StudySection.values
                        .map((section) => _TabContent(
                              viewState: widget.viewState,
                              size: widget.size,
                              padding: padding,
                              section: section,
                              sectionTitle: _titles[section.index],
                            ))
                        .toList();

                    return Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: TecAutoHideAppBar(
                        appBar: appBar,
                        body: TabBarView(children: tabContents, controller: tabController),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final ViewState viewState;
  final Size size;
  final EdgeInsets padding;
  final StudySection section;
  final String sectionTitle;

  const _TabContent(
      {Key key, this.viewState, this.size, this.padding, this.section, this.sectionTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (section == StudySection.notes) {
      return PageableChapterView(
          viewState: viewState, size: size, htmlPadding: const EdgeInsets.only(top: 50));
    } else {
      final isIntro = section == StudySection.intros;
      final isResources = section == StudySection.resources;

      return BlocProvider<StudyResBloc>(
        create: (_) {
          final viewData = context.read<VolumeViewDataBloc>().state.asVolumeViewData;
          // final studyViewData = viewData?.asStudyViewData;

          if (isResources) {
            // The root Resources folder.
            return StudyResBloc.withResource(Resource(
                id: 0,
                volumeId: viewData.volumeId,
                types: const {ResourceType.folder},
                title: sectionTitle));
          } else {
            return StudyResBloc(
                volumeId: viewData.volumeId,
                book: isIntro ? viewData.bcv.book : 0,
                chapter: 0,
                type: ResourceType.introduction);
          }
        },
        child: BlocListener<VolumeViewDataBloc, ViewData>(
          listener: (context, viewData) {
            if (viewData is VolumeViewData) {
              if (isResources) {
                context.read<StudyResBloc>().update(volumeId: viewData.volumeId);
              } else {
                context.read<StudyResBloc>().update(
                    volumeId: viewData.volumeId,
                    book: isIntro ? viewData.bcv.book : 0,
                    type: ResourceType.introduction);
              }
            }
          },
          child: isResources
              ? _RootFolderNavigator(viewSize: size, padding: padding)
              : StudyResView(viewSize: size, padding: padding),
        ),
      );
    }
  }
}

class _RootFolderNavigator extends StatelessWidget {
  final Size viewSize;
  final EdgeInsets padding;

  const _RootFolderNavigator({Key key, this.viewSize, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigatorWithHeroController(
      onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (context) => BlocBuilder<StudyResBloc, StudyRes>(
          builder: (context, studyRes) {
            return Scaffold(
              // appBar: MinHeightAppBar(appBar: AppBar(elevation: 0)),
              body: StudyResView(viewSize: viewSize, padding: padding),
            );
          },
        ),
      ),
    );
  }
}

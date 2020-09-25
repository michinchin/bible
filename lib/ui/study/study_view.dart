import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_data/volume_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../common/bible_chapter_title.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../misc/view_actions.dart';

class ViewableStudyContent extends Viewable {
  ViewableStudyContent(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return _StudyView(state: state, size: size);
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) {
    return state?.uid == null
        ? 'Study'
        : VolumeViewData.fromContext(context, state.uid).bookNameChapterAndAbbr;
  }

  @override
  Future<ViewData> dataForNewView({BuildContext context, int currentViewId}) async {
    final volumeId = await selectVolume(context,
        title: 'Select Study Content',
        filter: const VolumesFilter(volumeType: VolumeType.studyContent));
    // tec.dmPrint('selected $bibleId');

    if (volumeId != null) {
      final vmBloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
      final previous = VolumeViewData.fromJson(vmBloc?.dataWithView(currentViewId));
      assert(previous != null);
      return VolumeViewData(volumeId, previous.bcv);
    }

    return null;
  }
}

class _StudyView extends StatelessWidget {
  final ViewState state;
  final Size size;

  const _StudyView({Key key, this.state, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabTitles = ['About', 'Intro', 'Resources', 'Notes'];
    final textStyle = Theme.of(context).textTheme.headline2;

    Widget childForTab(String title) {
      final index = tabTitles.indexOf(title);
      switch (index) {
        case 3:
          return StudyNotes();
        default:
          return Center(child: Text(title, style: textStyle));
      }
    }

    final tabs = tabTitles.map((e) => Tab(text: e)).toList();
    final tabContents = tabTitles.map(childForTab).toList();

    return BlocProvider(
      create: (context) {
        final vmBloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
        final viewData = ChapterViewData.fromJson(vmBloc.dataWithView(state.uid));
        // _bible = VolumesRepository.shared.bibleWithId(viewData.bibleId);
        // _bcvPageZero = viewData.bcv;
        return ViewDataBloc(vmBloc, state.uid, viewData);
      },
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: MinHeightAppBar(
            appBar: AppBar(
              centerTitle: false,
              title: BibleChapterTitle(volumeType: VolumeType.studyContent, onUpdate: _onUpdate),
              actions: defaultActionsBuilder(context, state, size),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                expandedHeight: kTextTabBarHeight,
                title: TabBar(tabs: tabs, isScrollable: true),
              ),
              SliverFillRemaining(
                child: TabBarView(children: tabContents),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onUpdate(
      BuildContext context, int newVolumeId, BookChapterVerse newBcv, VolumeViewData viewData) {
    if (newVolumeId == null || newBcv == null) return;
    if (newVolumeId != viewData.volumeId || newBcv != viewData.bcv) {
      context.bloc<ViewDataBloc>()?.update(VolumeViewData(newVolumeId, newBcv));
    }
  }
}

class StudyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('NOTES', style: Theme.of(context).textTheme.headline2));
  }
}

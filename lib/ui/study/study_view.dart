import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_data/chapter_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../bible/chapter_title.dart';
import '../bible/chapter_view.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../menu/view_actions.dart';

class ViewableStudyContent extends Viewable {
  ViewableStudyContent(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return PageableChapterView(state: state, size: size);
    // return StudyView(state: state, size: size);
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) {
    return state?.uid == null
        ? 'Study'
        : ChapterViewData.fromContext(context, state.uid).bookNameChapterAndAbbr;
  }

  @override
  Future<ViewData> dataForNewView({BuildContext context, int currentViewId}) async {
    final volumeId = await selectVolume(context,
        title: 'Select Study Content',
        filter: const VolumesFilter(volumeType: VolumeType.studyContent));
    // tec.dmPrint('selected $bibleId');

    if (volumeId != null) {
      final previous = ChapterViewData.fromContext(context, currentViewId);
      assert(previous != null);
      return previous.copyWith(volumeId: volumeId);
    }

    return null;
  }
}

class StudyView extends StatelessWidget {
  final ViewState state;
  final Size size;

  const StudyView({Key key, this.state, this.size}) : super(key: key);

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
        final viewData = ChapterViewData.fromContext(context, state.uid);
        return ChapterViewDataBloc(context.viewManager, state.uid, viewData);
      },
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: MinHeightAppBar(
            appBar: AppBar(
              centerTitle: false,
              title: ChapterTitle(volumeType: VolumeType.studyContent),
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
}

class StudyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('NOTES', style: Theme.of(context).textTheme.headline2));
  }
}

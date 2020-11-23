import 'package:bible/ui/home/expandable_fab.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../bible/chapter_title.dart';
import '../bible/chapter_view.dart';
import '../bible/chapter_view_app_bar.dart';
import '../bible/chapter_view_data.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../menu/view_actions.dart';
import 'study_view_data.dart';

class ViewableVolume extends Viewable {
  ViewableVolume(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return _VolumeViewScaffold(state: state, size: size);
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) {
    return state?.uid == null
        ? 'Bible'
        : ChapterViewData.fromContext(context, state.uid).bookNameChapterAndAbbr;
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
      final previous = ChapterViewData.fromContext(context, currentViewId);
      assert(previous != null);
      if (isBibleId(volumeId)) {
        return ChapterViewData(volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
      } else if (isStudyVolumeId(volumeId)) {
        return StudyViewData(0, volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
      }
      assert(false);
    }

    return null;
  }
}

class _VolumeViewScaffold extends StatelessWidget {
  final ViewState state;
  final Size size;

  const _VolumeViewScaffold({Key key, @required this.state, @required this.size})
      : assert(state != null && size != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) {
          var data = ChapterViewData.fromContext(context, state.uid);
          if (isBibleId(data.volumeId)) {
            return ChapterViewDataBloc(context.viewManager, state.uid, data);
          } else if (isStudyVolumeId(data.volumeId)) {
            data = StudyViewData.fromContext(context, state.uid);
            assert(data != null);
            return StudyViewDataBloc(context.viewManager, state.uid, data as StudyViewData);
          } else {
            assert(false);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _VolumeViewAppBar(state: state, size: size),
          body: _VolumeViewBody(state: state, size: size),
        ),
      );
}

class _VolumeViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ViewState state;
  final Size size;

  const _VolumeViewAppBar({Key key, @required this.state, @required this.size})
      : assert(state != null && size != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<ChapterViewDataBloc, ViewData>(
        builder: (context, data) {
          if (data is ChapterViewData) {
            return ChapterViewAppBar(
              volumeType: isBibleId(data.volumeId) ? VolumeType.bible : VolumeType.studyContent,
              viewState: state,
              size: size,
            );
          }
          throw Exception('VolumeViewAppBar data must be ChapterViewData');
        },
      );

  @override
  Size get preferredSize => const MinHeightAppBar().preferredSize;
}

class _VolumeViewBody extends StatelessWidget {
  final ViewState state;
  final Size size;

  const _VolumeViewBody({Key key, @required this.state, @required this.size})
      : assert(state != null && size != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => PageableChapterView(state: state, size: size);

  // @override
  // Widget build(BuildContext context) => BlocBuilder<ChapterViewDataBloc, ViewData>(
  //       builder: (context, data) {
  //         if (data is ChapterViewData) {
  //           return Container();
  //         }
  //         throw Exception('VolumeViewAppBar data must be ChapterViewData');
  //       },
  //     );
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
                // backgroundColor: Colors.orange[100],
                floating: true,
                snap: true,
                expandedHeight: 88, // kTextTabBarHeight,
                //title: Text('hello'),
                flexibleSpace: OverflowBox(
                  maxHeight: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'hello',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      Center(child: TabBar(tabs: tabs, isScrollable: true)),
                    ],
                  ),
                ),
                elevation: 0,
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
    return Container(
        color: Colors.red[100],
        child: Center(child: Text('NOTES', style: Theme.of(context).textTheme.headline2)));
  }
}

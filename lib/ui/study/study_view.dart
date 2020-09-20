import 'package:flutter/material.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../common/common.dart';
import '../misc/view_actions.dart';

const studyViewType = 'StudyView';

String studyViewDefaultData() {
  return '';
}

Widget studyViewBuilder(BuildContext context, ViewState state, Size size) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');

  final textStyle = Theme.of(context).textTheme.headline2;
  Widget childForTab(String title) => Center(child: Text(title, style: textStyle));

  final tabTitles = ['About', 'Intro', 'Resources', 'Notes'];
  final tabs = tabTitles.map((e) => Tab(text: e)).toList();
  final tabContents = tabTitles.map(childForTab).toList();

  return DefaultTabController(
    length: tabs.length,
    child: Scaffold(
      appBar: MinHeightAppBar(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Study View'),
          actions: defaultActionsBuilder(context, state, size),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: kTextTabBarHeight,
            title: TabBar(tabs: tabs),
          ),
          SliverFillRemaining(
            child: TabBarView(children: tabContents),
          ),
        ],
      ),
    ),
  );
}

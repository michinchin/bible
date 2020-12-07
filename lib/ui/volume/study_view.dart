import 'package:flutter/material.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tec_util/tec_util.dart' as tec;
// import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
// import '../bible/chapter_view.dart';
// import 'study_view_data.dart';
// import 'volume_view_data_bloc.dart';

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

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              // backgroundColor: Colors.orange[100],
              floating: true,
              snap: true,
              expandedHeight: 110, // kTextTabBarHeight,
              flexibleSpace: OverflowBox(
                maxHeight: double.infinity,
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        '<Volume Title Goes Here>',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      Center(
                        child: TabBar(
                          tabs: tabs,
                          isScrollable: true,
                        ),
                      ),
                    ],
                  ),
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
    );
  }
}

class StudyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('NOTES', style: Theme.of(context).textTheme.headline2));
  }
}

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
  return Scaffold(
    appBar: MinHeightAppBar(
      appBar: AppBar(
        elevation: 3.0,
        centerTitle: false,
        title: const Text('Study View'),
        actions: defaultActionsBuilder(context, state, size),
      ),
    ),
    body: Container(),
  );
}

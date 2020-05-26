import 'package:flutter/material.dart';

import '../../blocs/view_manager_bloc.dart';
import '../common/tec_page_view.dart';

const bibleChapterType = 'BibleChapter';

Widget bibleChapterViewBuilder(BuildContext context, ViewState state) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');
  return PageableView(
    state: state,
    controllerBuilder: () => TecPageController(initialPage: 1),
    pageBuilder: (context, state, index) {
      return (index >= -2 && index <= 2) ? BibleChapterView(state: state, pageIndex: index) : null;
    },
  );
}

class BibleChapterView extends StatelessWidget {
  final ViewState state;
  final int pageIndex;

  const BibleChapterView({Key key, @required this.state, @required this.pageIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.green[300],
        borderRadius: const BorderRadius.all(Radius.circular(36)),
        //border: Border.all(),
      ),
      child: Center(
        child: Text(
          'Bible View ${state.uid}, Page $pageIndex',
          style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

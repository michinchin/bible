import 'package:flutter/material.dart';

import '../../blocs/view_manager_bloc.dart';

const bibleChapterTypeName = 'BibleChapter';

Widget bibleChapterPageBuilder(BuildContext context, ViewState state, int index) {
  return (index >= -2 && index <= 2)
      ? BibleChapterView(pageIndex: index)
      : null;
}

class BibleChapterView extends StatelessWidget {
  final int pageIndex;

  const BibleChapterView({Key key, @required this.pageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.all(Radius.circular(36)),
        //border: Border.all(),
      ),
      child: Center(
        child: Text(
          'page $pageIndex',
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

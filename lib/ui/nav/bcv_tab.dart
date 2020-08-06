import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/pref_item.dart';
import '../common/tec_tab_indicator.dart';
import 'nav.dart';

class BCVTabView extends StatelessWidget {
  final Function(BuildContext, PrefItems) listener;
  final TabController tabController;
  const BCVTabView({this.listener, this.tabController});

  @override
  Widget build(BuildContext context) {
    final navBloc = context.bloc<NavBloc>(); // ignore: close_sinks
    final prefState = context.bloc<PrefItemsBloc>()?.state;
    final items = prefState?.items ?? [];
    final navGridViewEnabled = (items.valueOfItemWithId(navLayout) ?? 0) != 0;
    final nav2TapEnabled = (items.valueOfItemWithId(nav2Tap) ?? 0) != 0;
    return BlocListener<PrefItemsBloc, PrefItems>(
        listener: listener,
        child: SafeArea(
            child: Column(
          children: [
            const SizedBox(height: 5),
            TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicator:
                  BubbleTabIndicator(color: tabColors[navBloc.state.tabIndex].withOpacity(0.5)),
              controller: tabController,
              labelColor: Theme.of(context).textColor.withOpacity(0.7),
              unselectedLabelColor: Theme.of(context).textColor.withOpacity(0.7),
              tabs: [
                const Tab(text: 'BOOK'),
                const Tab(text: 'CHAPTER'),
                if (!nav2TapEnabled) const Tab(text: 'VERSE')
              ],
            ),
            Expanded(
              child: TabBarView(controller: tabController, children: [
                _BookView(navGridViewEnabled: navGridViewEnabled),
                _ChapterView(nav2TapEnabled: nav2TapEnabled),
                if (!nav2TapEnabled) _VerseView(),
              ]),
            ),
          ],
        )));
  }
}

class _ChapterView extends StatelessWidget {
  final bool nav2TapEnabled;
  const _ChapterView({this.nav2TapEnabled});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);
    final bible = VolumesRepository.shared.bibleWithId(51);

    final ref = context.bloc<NavBloc>().state.ref;
    final chapters = bible.chaptersIn(book: ref.book);

    return _DynamicGrid(
      children: [
        for (var i = 1; i <= chapters; i++) ...[
          FlatButton(
            padding: const EdgeInsets.all(0),
            shape: const StadiumBorder(),
            color: Colors.grey.withOpacity(0.1),
            textColor: ref.chapter == i ? tabColors[1] : textColor,
            onPressed: () {
              if (nav2TapEnabled) {
                Navigator.of(context).maybePop(ref.copyWith(chapter: i));
              } else {
                context.bloc<NavBloc>().selectChapter(ref.book, bible.nameOfBook(ref.book), i);
              }
            },
            child: Text(i.toString()),
          ),
        ]
      ],
    );
  }
}

class _VerseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);
    final bible = VolumesRepository.shared.bibleWithId(51);

    final ref = context.bloc<NavBloc>().state.ref;
    final book = ref.book;
    final chapter = ref.chapter;
    final verses = bible.versesIn(book: book, chapter: chapter);

    return _DynamicGrid(
      children: [
        for (var i = 1; i <= verses; i++) ...[
          FlatButton(
            padding: const EdgeInsets.all(0),
            shape: const StadiumBorder(),
            color: Colors.grey.withOpacity(0.1),
            textColor: ref.verse == i ? tabColors[2] : textColor,
            onPressed: () {
              // TODO(abby): manually assigning end verse...probably shouldn't do this
              final updatedRef = ref.copyWith(verse: i, endVerse: i);
              context.bloc<NavBloc>().add(NavEvent.setRef(ref: updatedRef));
              Navigator.of(context).maybePop(updatedRef);
            },
            child: Text(i.toString()),
          ),
        ]
      ],
    );
  }
}

class _BookView extends StatelessWidget {
  final bool navGridViewEnabled;
  const _BookView({this.navGridViewEnabled});

  @override
  Widget build(BuildContext context) {
    final bible = VolumesRepository.shared.bibleWithId(51);
    // ignore: prefer_collection_literals
    final bookNames = LinkedHashMap<int, String>();
    var book = bible.firstBook;
    while (book != 0) {
      bookNames[book] = bible.shortNameOfBook(book);
      final nextBook = bible.bookAfter(book);
      book = (nextBook == book ? 0 : nextBook);
    }
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);

    final ot = bookNames.keys.takeWhile(bible.isOTBook).toList();
    final nt = bookNames.keys.where(bible.isNTBook).toList();
    final ref = context.bloc<NavBloc>().state.ref;

    Widget gridView(List<int> books) => _DynamicGrid(
          children: [
            for (final book in books) ...[
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  shape: const StadiumBorder(),
                  color: Colors.grey.withOpacity(0.1),
                  textColor: ref.book == book ? tabColors[0] : textColor,
                  onPressed: () => context.bloc<NavBloc>().selectBook(book, bible.nameOfBook(book)),
                  child: Text(
                    bookNames[book],
                  ),
                ),
              ),
            ]
          ],
        );

    // Widget wrap(List<int> books) => Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 5),
    //     child: Wrap(spacing: 2, children: [
    //       for (final book in books) ...[
    //         ButtonTheme(
    //           minWidth: 50,
    //           child: FlatButton(
    //             padding: const EdgeInsets.all(0),
    //             shape: const StadiumBorder(),
    //             color: Colors.grey.withOpacity(0.1),
    //             textColor: ref.book == book ? tabColors[0] : textColor,
    //             onPressed: () => context.bloc<NavBloc>().selectBook(book, bible.nameOfBook(book)),
    //             child: Text(
    //               bookNames[book],
    //             ),
    //           ),
    //         ),
    //       ]
    //     ]));

    Widget list(List<int> books) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: books.length,
        separatorBuilder: (c, i) => const Divider(
              height: 1,
            ),
        itemBuilder: (c, i) => ListTile(
              onTap: () => c.bloc<NavBloc>().selectBook(books[i], bible.nameOfBook(books[i])),
              title: Text(
                bible.nameOfBook(books[i]),
                textAlign: TextAlign.left,
                style: TextStyle(color: ref.book == books[i] ? tabColors[0] : textColor),
              ),
            ));

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'OLD TESTAMENT',
                style: Theme.of(context).textTheme.caption,
              )),
          if (navGridViewEnabled) gridView(ot) else list(ot),
          const Divider(color: Colors.transparent),
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'NEW TESTAMENT',
                style: Theme.of(context).textTheme.caption,
              )),
          if (navGridViewEnabled) gridView(nt) else list(nt),
          const Divider(color: Colors.transparent),
        ],
      ),
    );
  }
}

class _DynamicGrid extends StatelessWidget {
  final List<Widget> children;
  const _DynamicGrid({@required this.children}) : assert(children != null);
  @override
  Widget build(BuildContext context) {
    final smallScreen = MediaQuery.of(context).size.height <= 568;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GridView.extent(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            maxCrossAxisExtent: 50,
            childAspectRatio: smallScreen ? 1.8 : 1.5,
            crossAxisSpacing: smallScreen ? 5 : 10,
            mainAxisSpacing: smallScreen ? 5 : 10,
            children: children));
  }
}

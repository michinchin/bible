import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../common/common.dart';

Future<BookChapterVerse> navigate(BuildContext context, BookChapterVerse bcv) {
  final isLargeScreen =
      MediaQuery.of(context).size.width > 500 && MediaQuery.of(context).size.height > 600;
  if (isLargeScreen) {
    return showTecDialog<BookChapterVerse>(
      context: context,
      useRootNavigator: true,
      cornerRadius: 15,
      builder: (context) => BlocProvider(
          create: (context) => NavBloc(bcv),
          child: Container(height: 600, width: 500, child: Nav())),
    );
  }

  // Other ways we could show the nav UI:
//  return showTecModalPopup<BookChapterVerse>(
//       context: context,
//       alignment: Alignment.center,
//       // useRootNavigator: false,
//       builder: (context) => TecPopupSheet(
//           child: BlocProvider(
//               create: (context) => NavBloc(bcv),
//               child: Container(height: 600, width: 500, child: Nav()))),

  return Navigator.of(context, rootNavigator: true)
      .push<BookChapterVerse>(TecPageRoute<BookChapterVerse>(
          fullscreenDialog: true,
          builder: (context) => BlocProvider(
                create: (context) => NavBloc(bcv),
                child: Nav(),
              )));
}

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(
        () => context.bloc<NavBloc>().add(NavEvent.changeIndex(index: _tabController.index)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: appBarThemeWithContext(context),
        tabBarTheme: tabBarThemeWithContext(context),
      ),
      child: BlocListener<NavBloc, NavState>(
          bloc: context.bloc<NavBloc>(),
          listener: (c, s) {
            if (s.tabIndex < _tabController.length) {
              _tabController.animateTo(s.tabIndex);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const TextField(
                decoration: InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Navigate'),
              ),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BubbleTabIndicator(color: Theme.of(context).textColor.withOpacity(0.5)),
                controller: _tabController,
                labelColor: Theme.of(context).textColor.withOpacity(0.7),
                unselectedLabelColor: Theme.of(context).textColor.withOpacity(0.7),
                // labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [Tab(text: 'BOOK'), Tab(text: 'CHAPTER'), Tab(text: 'VERSE')],
              ),
            ),
            body: SafeArea(
              child: TabBarView(controller: _tabController, children: [
                _BookView(),
                _ChapterView(),
                _VerseView(),
              ]),
            ),
          )),
    );
  }
}

class _ChapterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);
    final bible = VolumesRepository.shared.bibleWithId(51);
    final isLargeScreen = MediaQuery.of(context).size.width > 500;
    final wideScreen = MediaQuery.of(context).size.width > 400;

    return BlocBuilder<NavBloc, NavState>(builder: (c, s) {
      final book = s.bcv.book;
      final chapters = bible.chaptersIn(book: s.bcv.book);

      return Column(
        children: [
          // Align(
          //   alignment: Alignment.topRight,
          //   child: Switch.adaptive(value: twoTap, onChanged: (b) {}),
          // ),
          Expanded(
            child: GridView.count(
              crossAxisCount: isLargeScreen || wideScreen ? 6 : 5,
              shrinkWrap: true,
              childAspectRatio: isLargeScreen ? 3 : 2,
              padding: const EdgeInsets.all(15),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (var i = 1; i <= chapters; i++) ...[
                  FlatButton(
                    padding: const EdgeInsets.all(0),
                    shape: const StadiumBorder(),
                    color: Colors.grey.withOpacity(0.1),
                    textColor: textColor,
                    onPressed: () {
                      context.bloc<NavBloc>().add(const NavEvent.changeIndex(index: 2));
                      context
                          .bloc<NavBloc>()
                          .add(NavEvent.setBookChapterVerse(bcv: BookChapterVerse(book, i, 1)));
                      // Navigator.of(context).maybePop(BookChapterVerse(book, book == 23 ? 119 : 1, 1));
                    },
                    child: Text(i.toString()),
                  ),
                ]
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _VerseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);
    final bible = VolumesRepository.shared.bibleWithId(51);
    final isLargeScreen = MediaQuery.of(context).size.width > 500;
    final wideScreen = MediaQuery.of(context).size.width > 400;

    return BlocBuilder<NavBloc, NavState>(builder: (c, s) {
      final book = s.bcv.book;
      final chapter = s.bcv.chapter;
      final verses = bible.versesIn(book: book, chapter: chapter);

      return GridView.count(
        crossAxisCount: isLargeScreen || wideScreen ? 6 : 5,
        shrinkWrap: true,
        childAspectRatio: isLargeScreen ? 3 : 2,
        padding: const EdgeInsets.all(15),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          for (var i = 1; i <= verses; i++) ...[
            FlatButton(
              padding: const EdgeInsets.all(0),
              shape: const StadiumBorder(),
              color: Colors.grey.withOpacity(0.1),
              textColor: textColor,
              onPressed: () {
                context
                    .bloc<NavBloc>()
                    .add(NavEvent.setBookChapterVerse(bcv: s.bcv.copyWith(verse: i)));
                Navigator.of(context).maybePop(s.bcv.copyWith(verse: i));
              },
              child: Text(i.toString()),
            ),
          ]
        ],
      );
    });
  }
}

class _BookView extends StatelessWidget {
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
    // final isLargeScreen = MediaQuery.of(context).size.width > 500;
    // final wideScreen = MediaQuery.of(context).size.width > 400;

    // List<Widget> _lineInGridView() {
    //   final divs = <Widget>[];
    //   final count = isLargeScreen ? 9 : 6;
    //   for (var i = 0; i < count; i++) {
    //     divs.add(const VerticalDivider(color: Colors.transparent));
    //   }
    //   return divs;
    // }

    final ot = bookNames.keys.takeWhile(bible.isOTBook);
    final nt = bookNames.keys.where(bible.isNTBook);
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
          Wrap(spacing: 5, runSpacing: 0, children: [
            for (final book in ot) ...[
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  shape: const StadiumBorder(),
                  color: Colors.grey.withOpacity(0.1),
                  textColor: textColor,
                  onPressed: () {
                    context.bloc<NavBloc>().add(const NavEvent.changeIndex(index: 1));
                    context.bloc<NavBloc>().add(NavEvent.setBookChapterVerse(
                        bcv: BookChapterVerse(book, book == 23 ? 119 : 1, 1)));
                    // Navigator.of(context).maybePop(BookChapterVerse(book, book == 23 ? 119 : 1, 1));
                  },
                  child: Text(
                    bookNames[book],
                  ),
                ),
              ),
            ]
          ]),
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'NEW TESTAMENT',
                style: Theme.of(context).textTheme.caption,
              )),
          Wrap(spacing: 5, children: [
            for (final book in nt) ...[
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  shape: const StadiumBorder(),
                  color: Colors.grey.withOpacity(0.1),
                  textColor: textColor,
                  onPressed: () {
                    context.bloc<NavBloc>().add(const NavEvent.changeIndex(index: 1));
                    context.bloc<NavBloc>().add(NavEvent.setBookChapterVerse(
                        bcv: BookChapterVerse(book, book == 23 ? 119 : 1, 1)));
                    // Navigator.of(context).maybePop(BookChapterVerse(book, book == 23 ? 119 : 1, 1));
                  },
                  child: Text(
                    bookNames[book],
                  ),
                ),
              ),
            ]
          ]),
          const Divider(color: Colors.transparent),
        ],
      ),
    );
  }
}

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../common/common.dart';

Future<BookChapterVerse> navigate(BuildContext context) {
  // return showTecModalPopup<BookChapterVerse>(
  //   context: context,
  //   alignment: Alignment.center,
  //   // useRootNavigator: false,
  //   builder: (context) => TecPopupSheet(child: Nav()),
  // );

  // Other ways we could show the nav UI:

  // return showTecDialog<BookChapterVerse>(
  //   context: context,
  //   useRootNavigator: false,
  //   maxWidth: 400,
  //   builder: (context) => Scaffold(appBar: const ManagedViewAppBar(), body: Nav()),
  // );

  return Navigator.of(context, rootNavigator: true)
      .push<BookChapterVerse>(TecPageRoute<BookChapterVerse>(
          fullscreenDialog: true,
          builder: (context) => BlocProvider(
                create: (context) => NavBloc(BookChapterVerse.fromHref('51/1/1')),
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
                controller: _tabController,
                tabs: const [Tab(text: 'Book'), Tab(text: 'Chapter'), Tab(text: 'Verse')],
              ),
            ),
            body: TabBarView(controller: _tabController, children: [
              _BookView(),
              _ChapterView(),
              _VerseView(),
            ]),
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

    return BlocBuilder<NavBloc, NavState>(builder: (c, s) {
      final book = s.bcv.book;
      final chapters = bible.chaptersIn(book: s.bcv.book);

      return GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        childAspectRatio: 2,
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

    return BlocBuilder<NavBloc, NavState>(builder: (c, s) {
      final book = s.bcv.book;
      final chapter = s.bcv.chapter;
      final verses = bible.versesIn(book: book, chapter: chapter);

      return GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        childAspectRatio: 2,
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

    List<Widget> _lineInGridView() {
      final divs = <Widget>[];
      for (var i = 0; i < 6; i++) {
        divs.add(const VerticalDivider(color: Colors.transparent));
      }
      return divs;
    }

    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      childAspectRatio: 2,
      padding: const EdgeInsets.all(15),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        for (final book in bookNames.keys) ...[
          FlatButton(
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
          if (book == 46) ..._lineInGridView(),
        ]
      ],
    );
  }
}

// class Nav extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       //tec.dmPrint('Nav constraints: $constraints');

//       final bible = VolumesRepository.shared.bibleWithId(51);

//       // ignore: prefer_collection_literals
//       final bookNames = LinkedHashMap<int, String>();
//       var book = bible.firstBook;
//       while (book != 0) {
//         bookNames[book] = bible.shortNameOfBook(book);
//         final nextBook = bible.bookAfter(book);
//         book = (nextBook == book ? 0 : nextBook);
//       }

//       final bookKeys = bookNames.keys.toList();

//       final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
//       final otColor = isDarkTheme ? const Color(0xff111122) : Colors.blue[50];
//       final ntColor = isDarkTheme ? const Color(0xff221111) : Colors.red[50];
//       final textColor = isDarkTheme ? const Color(0xff777777) : const Color(0xff333333);

//       const minCellWidth = 46.0;
//       final cellWidth = constraints.maxWidth == double.infinity
//           ? minCellWidth
//           : math.min(66.0, (constraints.maxWidth / 6).roundToDouble());
//       const cellHeight = 34.0;
//       const rowCount = 6;
//       var x = 0.0, y = 0.0, c = 0;
//       final b = <Widget>[
//         Container(
//             width: cellWidth * rowCount,
//             height: (bookKeys.length.toDouble() / rowCount).ceilToDouble() * cellHeight)
//       ];
//       for (var i = 0; i < bookKeys.length; i++) {
//         c += 1;
//         if (c > rowCount) {
//           c = 1;
//           x = 0;
//           y += cellHeight;
//         }
//         final book = bookKeys[i];
//         b.add(
//           Positioned.fromRect(
//             rect: Rect.fromLTWH(x, y, cellWidth - 2, cellHeight - 2),
//             child: CupertinoButton(
//               padding: EdgeInsets.zero,
//               child: Text(
//                 '${bookNames[book]}',
//                 style: TextStyle(color: textColor),
//               ),
//               color: bible.isNTBook(bookKeys[i]) ? ntColor : otColor,
//               borderRadius: null,
//               onPressed: () {
//                 // TODO(mike): Remove this after nav is done
//                 Navigator.of(context).maybePop(BookChapterVerse(book, book == 23 ? 119 : 1, 1));
//               },
//             ),
//           ),
//         );

//         x += cellWidth;
//       }

//       return Stack(children: b);
//     });
//   }
// }

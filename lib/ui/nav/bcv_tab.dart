import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/content_settings.dart';
import '../../blocs/search/nav_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../common/tec_tab_indicator.dart';
import 'nav.dart';

class BCVTabView extends StatelessWidget {
  final Function(BuildContext, PrefItems) listener;
  final TabController tabController;
  final TextEditingController searchController;
  const BCVTabView(
      {@required this.listener, @required this.tabController, @required this.searchController});

  @override
  Widget build(BuildContext context) {
    final navBloc = context.tbloc<NavBloc>(); // ignore: close_sinks
    final prefState = context.tbloc<PrefItemsBloc>(); // ignore: close_sinks
    final navGridViewEnabled = prefState.itemBool(PrefItemId.navLayout);
    final nav3TapEnabled = prefState.itemBool(PrefItemId.nav3Tap);
    return BlocListener<PrefItemsBloc, PrefItems>(
        listener: listener,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 5),
              TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicator:
                    BubbleTabIndicator(color: tabColors[navBloc.state.tabIndex].withOpacity(0.5)),
                controller: tabController,
                labelColor: barTextColor(context),
                unselectedLabelColor: barTextColor(context),
                tabs: [
                  const Tab(text: 'BOOK'),
                  const Tab(text: 'CHAPTER'),
                  if (nav3TapEnabled) const Tab(text: 'VERSE')
                ],
              ),
              Expanded(
                child: TabBarView(controller: tabController, children: [
                  _BookView(
                    navGridViewEnabled: navGridViewEnabled,
                    searchController: searchController,
                  ),
                  _ChapterView(
                    nav3TapEnabled: nav3TapEnabled,
                    searchController: searchController,
                  ),
                  if (nav3TapEnabled) _VerseView(),
                ]),
              ),
            ],
          ),
        ));
  }
}

class _ChapterView extends StatelessWidget {
  final bool nav3TapEnabled;
  final TextEditingController searchController;
  const _ChapterView({@required this.nav3TapEnabled, @required this.searchController});

  @override
  Widget build(BuildContext context) {
    final textColor = barTextColor(context);
    final bible = VolumesRepository.shared.bibleWithId(Const.defaultBible);

    final ref = context.tbloc<NavBloc>().state.ref;
    final chapters = bible.chaptersIn(book: ref.book);

    void updateSearch(String s) => searchController
      ..text = s
      ..selection = TextSelection.collapsed(offset: s.length);

    return SingleChildScrollView(
      child: _DynamicGrid(
        children: [
          for (var i = 1; i <= chapters; i++) ...[
            _PillButton(
              textColor: ref.chapter == i ? tabColors[NavTabs.chapter.index] : textColor,
              onPressed: () {
                if (!nav3TapEnabled) {
                  Navigator.of(context).maybePop(ref.copyWith(chapter: i));
                } else {
                  updateSearch('${bible.nameOfBook(ref.book)} $i:');
                  context.tbloc<NavBloc>().selectChapter(ref.book, bible.nameOfBook(ref.book), i);
                }
              },
              text: i.toString(),
            ),
          ]
        ],
      ),
    );
  }
}

class _VerseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColor = barTextColor(context);
    final bible = VolumesRepository.shared.bibleWithId(9);

    final ref = context.tbloc<NavBloc>().state.ref;
    final book = ref.book;
    final chapter = ref.chapter;
    final verses = bible.versesIn(book: book, chapter: chapter);

    return _DynamicGrid(
      children: [
        for (var i = 1; i <= verses; i++) ...[
          _PillButton(
            onPressed: () {
              final updatedRef = ref.copyWith(verse: i, endVerse: i);
              context.tbloc<NavBloc>().add(NavEvent.setRef(ref: updatedRef));
              Navigator.of(context).maybePop(updatedRef);
            },
            textColor: ref.verse == i ? tabColors[NavTabs.verse.index] : textColor,
            text: i.toString(),
          )
        ]
      ],
    );
  }
}

class _BookView extends StatelessWidget {
  final bool navGridViewEnabled;
  final TextEditingController searchController;
  const _BookView({@required this.navGridViewEnabled, @required this.searchController});

  @override
  Widget build(BuildContext context) {
    final bible = VolumesRepository.shared.bibleWithId(Const.defaultBible);
    final navCanonical = context.tbloc<PrefItemsBloc>().itemBool(PrefItemId.navBookOrder);
    void updateSearch(String s) => searchController
      ..text = s
      ..selection = TextSelection.collapsed(offset: s.length);

    // ignore: prefer_collection_literals
    final bookNames = LinkedHashMap<int, String>();
    var book = bible.firstBook;
    while (book != 0) {
      bookNames[book] = bible.shortNameOfBook(book);
      final nextBook = bible.bookAfter(book);
      book = (nextBook == book ? 0 : nextBook);
    }
    final textColor = barTextColor(context);

    final ot = bookNames.keys.takeWhile(bible.isOTBook).toList();
    final nt = bookNames.keys.where(bible.isNTBook).toList();

    String removeDigits(String s) {
      final idx = s.indexOf(RegExp('[0-9]+'));
      if (idx != -1) {
        return '${s.substring(1)} ${s[idx]}'.trim();
      }
      return s;
    }

    final alphabeticalList = bookNames.keys.toList()
      ..sort((k1, k2) =>
          compareNatural(removeDigits(bible.nameOfBook(k1)), removeDigits(bible.nameOfBook(k2))));
    final ref = context.tbloc<NavBloc>().state.ref;

    void onTap(int book) {
      //ignore: close_sinks
      final bloc = context.tbloc<NavBloc>();
      // if book only has one chapter, special case
      if (bible.chaptersIn(book: book) == 1) {
        if (context.tbloc<PrefItemsBloc>().itemBool(PrefItemId.nav3Tap)) {
          final nameOfBook = bible.nameOfBook(book);
          updateSearch(nameOfBook);
          bloc
            ..selectBook(book, nameOfBook)
            ..add(NavEvent.changeTabIndex(index: NavTabs.verse.index));
        } else {
          Navigator.of(context).maybePop(bloc.state.ref.copyWith(book: book));
        }
      } else {
        final nameOfBook = bible.nameOfBook(book);
        updateSearch(nameOfBook);
        bloc.selectBook(book, bible.nameOfBook(book));
      }
    }

    Widget gridView(List<int> books) => _DynamicGrid(
          children: [
            for (final book in books) ...[
              _PillButton(
                text: bookNames[book],
                onPressed: () => onTap(book),
                textColor: ref.book == book ? tabColors[NavTabs.book.index] : textColor,
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
    //             padding: EdgeInsets.zero,
    //             shape: const StadiumBorder(),
    //             color: Colors.grey.withOpacity(0.1),
    //             textColor: ref.book == book ? tabColors[0] : textColor,
    //             onPressed: () => context.tbloc<NavBloc>().selectBook(book, bible.nameOfBook(book)),
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
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (c, i) => ListTile(
              onTap: () => onTap(books[i]),
              title: Text(
                bible.nameOfBook(books[i]),
                textAlign: TextAlign.left,
                style: TextStyle(color: ref.book == books[i] ? tabColors[1] : textColor),
              ),
            ));

    if (!navGridViewEnabled) {
      return ListView(children: [
        if (!navCanonical) ...[
          list(alphabeticalList)
        ] else ...[
          const ListLabel('OLD TESTAMENT'),
          list(ot),
          const ListLabel('NEW TESTAMENT'),
          list(nt)
        ]
      ]);
    } else {
      return ListView(
        children: [
          if (!navCanonical) ...[
            gridView(alphabeticalList)
          ] else ...[
            const ListLabel('OLD TESTAMENT'),
            gridView(ot),
            const ListLabel('NEW TESTAMENT'),
            gridView(nt)
          ]
        ],
      );
    }
  }
}

class _DynamicGrid extends StatelessWidget {
  final List<Widget> children;
  const _DynamicGrid({@required this.children}) : assert(children != null);
  @override
  Widget build(BuildContext context) {
    dmPrint(
        'width: ${MediaQuery.of(context).size.width}\nheight: ${MediaQuery.of(context).size.height}');
    final smallHeight =
        MediaQuery.of(context).size.height <= 685; // pixel 2 height, iphonex height = 812
    final smallWidth = MediaQuery.of(context).size.width <= 375;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isLargeScreen =
        MediaQuery.of(context).size.width > 500 && MediaQuery.of(context).size.height > 600;

    double extentCalculated() {
      if (textScaleFactor >= 2.0 ||
          context.tbloc<ContentSettingsBloc>().state.textScaleFactor >= 2.0) {
        return 100;
      }
      if (((smallWidth && !smallHeight) || isLargeScreen) ||
          !smallWidth && !smallHeight && !isLargeScreen) {
        return 60;
      } else if (smallWidth) {
        return 50;
      }
      return 70;
    }

    // tec.dmPrint('textScaleFactor: ${textScaleFactor}');

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GridView.extent(
            padding: const EdgeInsets.only(bottom: 10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            maxCrossAxisExtent: extentCalculated(),
            childAspectRatio: smallHeight ? 1.8 : 1.5,
            crossAxisSpacing: smallHeight ? 5 : 8,
            mainAxisSpacing: smallHeight ? 5 : 8,
            children: children));
  }
}

class _PillButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color textColor;
  final String text;
  const _PillButton({@required this.onPressed, @required this.textColor, @required this.text});
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.zero,
      shape: const StadiumBorder(),
      color: Theme.of(context).cardColor,
      textColor: textColor,
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        textScaleFactor: context.tbloc<ContentSettingsBloc>().state.textScaleFactor,
        maxLines: 1,
      ),
    );
  }
}

// class BookNav extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       // tec.dmPrint('Nav constraints: $constraints');
//       final area = constraints.maxHeight * constraints.minHeight;

//       final bible = VolumesRepository.shared.bibleWithId(9);

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
//             child: _PillButton(
//               text: '${bookNames[book]}',
//               textColor: textColor,
//               onPressed: () {
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

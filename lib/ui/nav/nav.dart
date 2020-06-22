import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

//import '../../blocs/view_manager_bloc.dart';
import '../common/common.dart';

Future<BookChapterVerse> navigate(BuildContext context) {
  return showTecModalPopup<BookChapterVerse>(
    context: context,
    popupMode: TecPopupMode.slideDown,
    useRootNavigator: false,
    builder: (context) => TecPopupSheet(child: Nav()),
  );

  // Other ways we could show the nav UI:

  // return showTecDialog<BookChapterVerse>(
  //   context: context,
  //   useRootNavigator: false,
  //   maxWidth: 400,
  //   builder: (context) => Scaffold(appBar: const ManagedViewAppBar(), body: Nav()),
  // );

  // return Navigator.of(context).push<BookChapterVerse>(TecPageRoute<BookChapterVerse>(
  //   fullscreenDialog: true,
  //   builder: (context) => Scaffold(appBar: const ManagedViewAppBar(), body: Nav()),
  // ));
}

class Nav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      //tec.dmPrint('Nav constraints: $constraints');

      final bible = VolumesRepository.shared.bibleWithId(51);

      // ignore: prefer_collection_literals
      final bookNames = LinkedHashMap<int, String>();
      var book = bible.firstBook;
      while (book != 0) {
        bookNames[book] = bible.shortNameOfBook(book);
        final nextBook = bible.bookAfter(book);
        book = (nextBook == book ? 0 : nextBook);
      }

      final bookKeys = bookNames.keys.toList();

      final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
      final otColor = isDarkTheme ? const Color(0xff111122) : Colors.blue[50];
      final ntColor = isDarkTheme ? const Color(0xff221111) : Colors.red[50];
      final textColor = isDarkTheme ? const Color(0xff777777) : const Color(0xff333333);

      const minCellWidth = 46.0;
      final cellWidth = constraints.maxWidth == double.infinity
          ? minCellWidth
          : math.min(66.0, (constraints.maxWidth / 6).roundToDouble());
      const cellHeight = 34.0;
      const rowCount = 6;
      var x = 0.0, y = 0.0, c = 0;
      final b = <Widget>[
        Container(
            width: cellWidth * rowCount,
            height: (bookKeys.length.toDouble() / rowCount).ceilToDouble() * cellHeight)
      ];
      for (var i = 0; i < bookKeys.length; i++) {
        c += 1;
        if (c > rowCount) {
          c = 1;
          x = 0;
          y += cellHeight;
        }
        final book = bookKeys[i];
        b.add(
          Positioned.fromRect(
            rect: Rect.fromLTWH(x, y, cellWidth - 2, cellHeight - 2),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                '${bookNames[book]}',
                style: TextStyle(color: textColor),
              ),
              color: bible.isNTBook(bookKeys[i]) ? ntColor : otColor,
              borderRadius: null,
              onPressed: () {
                Navigator.of(context).maybePop(BookChapterVerse(book, 1, 1));
              },
            ),
          ),
        );

        x += cellWidth;
      }

      return Stack(children: b);
    });
  }
}

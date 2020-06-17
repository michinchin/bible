import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_volumes/tec_volumes.dart';

//import '../../blocs/view_manager_bloc.dart';

class Nav extends StatelessWidget {
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

    final bookKeys = bookNames.keys.toList();

    const cellWidth = 40.0;
    const cellHeight = 30.0;
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
      b.add(
        Positioned.fromRect(
          rect: Rect.fromLTWH(x, y, cellWidth - 2, cellHeight - 2),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              '${bookNames[bookKeys[i]]}',
              style: const TextStyle(color: Colors.black),
            ),
            color: bible.isNTBook(bookKeys[i]) ? Colors.red[50] : Colors.blue[50],
            borderRadius: null,
            onPressed: () {},
          ),
        ),
      );

      x += cellWidth;
    }

    return Stack(children: b);
  }
}

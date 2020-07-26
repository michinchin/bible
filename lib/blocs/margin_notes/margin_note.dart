import 'package:flutter/foundation.dart';

import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

class MarginNote extends UserItem {
  MarginNote({
    int id,
    @required int volume,
    @required int book,
    @required int chapter,
    @required int verse,
    int created,
    int deleted = 0,
    @required String text,
    int modified,
  }) : super(
      volumeId: volume,
      book: book,
      chapter: chapter,
      verse: verse,
      type: UserItemType.marginNote.index,
      created: created ?? tec.dbIntFromDateTime(DateTime.now()),
      id: id,
      deleted: deleted,
      info: text,
      modified: modified ?? tec.dbIntFromDateTime(DateTime.now()));

  factory MarginNote.from(UserItem item) {
    return MarginNote(
      volume: item.volumeId,
      book: item.book,
      chapter: item.chapter,
      verse: item.verse,
      text: item.info,
      modified: item.modified ?? tec.dbIntFromDateTime(DateTime.now()),
      created: item.created ?? tec.dbIntFromDateTime(DateTime.now()),
      deleted: item.deleted,
      id: item.id,
    );
  }

  String get text => info;

  static String getTitle(UserItem item) {
    final ref = Reference(
      volume: item.volumeId,
      book: item.book,
      chapter: item.chapter,
      verse: item.verse,
    );

    return '${ref.label()} Note';
  }

  static Map<String, dynamic> createState(UserItem item) {
    final data = <String, dynamic>{};
    data['id'] = item.id;
    data['title'] = getTitle(item);
    return data;
  }
}


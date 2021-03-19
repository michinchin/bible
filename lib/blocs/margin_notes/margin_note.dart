import 'package:flutter/foundation.dart';

import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/reference_ext.dart';

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
      created: created ?? dbIntFromDateTime(DateTime.now()),
      id: id,
      deleted: deleted,
      info: text,
      modified: modified ?? dbIntFromDateTime(DateTime.now()));

  factory MarginNote.from(UserItem item) {
    return MarginNote(
      volume: item.volumeId,
      book: item.book,
      chapter: item.chapter,
      verse: item.verse,
      text: item.info,
      modified: item.modified ?? dbIntFromDateTime(DateTime.now()),
      created: item.created ?? dbIntFromDateTime(DateTime.now()),
      deleted: item.deleted,
      id: item.id,
    );
  }

  String get text => info;

  Map<String, dynamic> stateJson() {
    final ref = Reference(
      volume: volumeId,
      book: book,
      chapter: chapter,
      verse: verse,
    );

    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = '${ref.label()} Note';
    return data;
  }
}


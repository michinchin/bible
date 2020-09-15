import 'package:flutter/foundation.dart';

import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;

enum PrefItemDataType { json, string, bool, int }

class PrefItemId {
  /// highlight/underline colors
  static const customColor1 = 1;
  static const customColor2 = 2;
  static const customColor3 = 3;
  static const customColor4 = 4;
  static const customColors = [customColor1, customColor2, customColor3, customColor4];

  /// grid view default (0), scroll view (1)
  static const navLayout = 5;

  /// 3-tap default (0), 2-tap (1)
  static const nav3Tap = 6;

  /// volumeIds chosen for search filter
  static const translationsFilter = 7;

  /// show books canonically (0) or alphabetically (1)
  static const navBookOrder = 8;

  /// include the link on copy/share (0), or don't (1)
  static const includeShareLink = 9;

  /// abbreviate translations in nav (0), or don't (1)
  static const translationsAbbreviated = 10;

  /// what format to keep the search filter page (grid view or list view)
  static const searchFilterBookGridView = 11;
  static const searchFilterTranslationGridView = 12;
}

class PrefItem extends tua.UserItem {
  PrefItem({
    @required PrefItemDataType prefItemDataType,
    @required int prefItemId, // 1-4 for custom colors
    int verse, // 0|1 for bool value or as int value
    String info = '',
    DateTime created,
    int deleted = 0,
    int id,
    DateTime modified,
  }) : super(
          type: tua.UserItemType.prefItem.index,
          chapter: prefItemDataType.index,
          book: prefItemId,
          verse: verse,
          info: info,
          created: tec.dbIntFromDateTime(created ?? DateTime.now()),
          deleted: deleted,
          modified: tec.dbIntFromDateTime(modified ?? DateTime.now()),
          id: id,
        );

  factory PrefItem.from(tua.UserItem item) => PrefItem(
      prefItemDataType: PrefItemDataType.values[item.chapter],
      prefItemId: item.book,
      verse: item.verse,
      info: item.info,
      id: item.id,
      deleted: item.deleted,
      created: tec.dateOnlyFromDbInt(item.created),
      modified: tec.dateOnlyFromDbInt(item.modified));
}

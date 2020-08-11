import 'package:flutter/foundation.dart';

import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;

enum PrefItemDataType { json, string, bool, int }
// enum PrefItemType {
//   /*1-4*/ customColors,
//   /*5-6*/ navPrefs,
// }

const customColor1 = 1;
const customColor2 = 2;
const customColor3 = 3;
const customColor4 = 4;
const customColors = [customColor1, customColor2, customColor3, customColor4];
const navLayout = 5; // grid view default (0), scroll view (1)
const nav2Tap = 6; // 3-tap default (0), 2-tap (1)
const translationsFilter = 7;

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

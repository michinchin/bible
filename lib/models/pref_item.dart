import 'package:flutter/foundation.dart';

import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart';

enum PrefItemDataType { json, string, bool, int }

/// default pref items to be per device (value pair)
class PrefItemId {
  /// highlight/underline colors
  static const customColor1 = 1;
  static const customColor2 = 2;
  static const customColor3 = 3;
  static const customColor4 = 4;

  /// unique id is (100 + color id)
  static const saveToDbList = [
    customColor1,
    customColor2,
    customColor3,
    customColor4,
    translationsFilter
  ];

  static const saveToPrefsList = [
    navLayout,
    nav3Tap,
    navBookOrder,
    includeShareLink,
    translationsAbbreviated,
    searchFilterBookGridView,
    searchFilterTranslationGridView,
    closeAfterCopyShare,
    priorityTranslations,
    syncChapter,
    syncVerse,
  ];

  static int uniqueId(int id) => 100 + id;
  static String keyForPrefs(int id) => 'prefItem_$id';

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

  /// selection sheet setting
  static const closeAfterCopyShare = 13;

  /// priority translations for sorting individual search result translations
  static const priorityTranslations = 14;

  /// all bible views have same chapter
  static const syncChapter = 15;

  /// bible views with same chapter also have same verse
  static const syncVerse = 16;

}

class PrefItem extends tua.UserItem {
  PrefItem({
    @required PrefItemDataType prefItemDataType,
    @required int prefItemId, // 1-4 for custom colors
    int intValue, // 0|1 for bool value or as int value
    String stringValue = '',
    DateTime created,
    int deleted = 0,
    int id,
    DateTime modified,
  }) : super(
          type: tua.UserItemType.prefItem.index,
          chapter: prefItemDataType.index,
          book: prefItemId,
          verse: intValue,
          info: stringValue,
          created: dbIntFromDateTime(created ?? DateTime.now()),
          deleted: deleted,
          modified: dbIntFromDateTime(modified ?? DateTime.now()),
          id: id,
        );

  factory PrefItem.from(tua.UserItem item) => PrefItem(
      prefItemDataType: PrefItemDataType.values[item.chapter],
      prefItemId: item.book,
      intValue: item.verse,
      stringValue: item.info,
      id: item.id,
      deleted: item.deleted,
      created: dateOnlyFromDbInt(item.created),
      modified: dateOnlyFromDbInt(item.modified));
}

extension PrefItemHelper on PrefItem {
  bool get saveToDb => PrefItemId.saveToDbList.contains(book);
  int get uniqueId => 100 + book;
  String get keyForPrefs => 'prefItem_$book';
  String get valueToSave {
    final type = PrefItemDataType.values[chapter];
    switch (type) {
      case PrefItemDataType.bool:
      case PrefItemDataType.int:
        return '${chapter}_$verse';
      case PrefItemDataType.string:
      case PrefItemDataType.json:
        return '${chapter}_$info';
    }
    return '';
  }

  static PrefItem fromSharedPrefs(String key, String value) {
    final splitValue = value.split('_');
    final prefItemDataType = int.parse(splitValue.first);
    final prefItemId = int.parse(key.split('_').last);

    if (prefItemDataType == PrefItemDataType.bool.index ||
        prefItemDataType == PrefItemDataType.int.index) {
      final verse = int.parse(splitValue.last);
      return PrefItem(
          prefItemDataType: PrefItemDataType.values[prefItemDataType],
          prefItemId: prefItemId,
          intValue: verse);
    } else {
      final info = splitValue.last;
      return PrefItem(
          prefItemDataType: PrefItemDataType.values[prefItemDataType],
          prefItemId: prefItemId,
          stringValue: info);
    }
  }
}

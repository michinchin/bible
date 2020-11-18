import 'dart:math' as math;

import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../app_settings.dart';

const votdType = 1;
const dotdType = 2;
const savedVolumeId = 7000;

class OtdSave extends UserItem {
  OtdSave(
      {int id,
      int parentId,
      int deleted = 0,
      int created,
      int modified,
      this.cardType,
      this.year,
      this.day})
      : super(
          type: UserItemType.completed.index,
          id: id,
          parentId: parentId,
          deleted: deleted,
          created: created ?? tec.dbIntFromDateTime(DateTime.now()),
          modified: modified ?? tec.dbIntFromDateTime(DateTime.now()),
        );
  final int cardType;
  final int year;
  final int day;

  factory OtdSave.from(UserItem item) => OtdSave(
      id: item.id,
      parentId: item.parentId,
      deleted: item.deleted,
      created: item.created,
      modified: item.modified,
      cardType: _getCardTypeId(item.parentId),
      year: _getCardYear(item.parentId),
      day: _getCardDayOfYear(item.parentId));

  static int _getCardTypeId(int itemId) {
    return ((itemId & 0x1FE00000) >> 21);
  }

  static int _getCardYear(int itemId) {
    return ((itemId & 0x1FFE00) >> 9);
  }

  static int _getCardDayOfYear(int itemId) {
    return (itemId & 0x1FF);
  }
}

class OtdSaves {
  List<OtdSave> data;
  OtdSaves(this.data);

  static Future<OtdSaves> fetch() async {
    final items =
        await AppSettings.shared.userAccount.userDb.getItemsOfTypes([UserItemType.completed]);

    if (items != null) {
      final saved = items.where((s) => s.volumeId == savedVolumeId).toList();
      final otdSaves = saved.map((s) => OtdSave.from(s)).toList();
      if (_removeRepeats(otdSaves)) {
        await AppSettings.shared.userAccount.userDb.saveSyncItems(otdSaves);
      }
      return OtdSaves(otdSaves);
    }

    return null;
  }

  static bool _removeRepeats(List<OtdSave> saves) {
    final ids = saves.map((s) => s.parentId).toSet();
    final removed = ids.length != saves.length;
    saves.retainWhere((s) => ids.remove(s.parentId));
    return removed;
  }

  Future<UserItem> saveOtd({int cardTypeId, int year, int day}) async {
    if (cardTypeId != null && year != null && day != null) {
      final index = indexOf(cardTypeId, year, day);
      UserItem item;
      if (index != -1) {
        item = data[index].copyWith(deleted: data[index].isDeleted ? 0: 1);
      } else {
        item = UserItem(
            type: UserItemType.completed.index,
            parentId: _getCompletedItemId(cardTypeId, year, day),
            volumeId: savedVolumeId);
      }
      return AppSettings.shared.userAccount.userDb.saveItem(item);
    }
    return null;
  }

  static int _getCompletedItemId(int cardTypeId, int year, int day) {
    return ((math.max(0, math.min(255, cardTypeId)) << 21) |
        (math.max(0, math.min(4095, year)) << 9) |
        (math.max(0, math.min(511, day))));
  }

  bool hasItem(int type, int year, int day) =>
      (data?.indexWhere((i) => i.day == day && i.cardType == type && i.year == year) ?? -1) != -1;
  int indexOf(int type, int year, int day) =>
      data?.indexWhere((i) => i.day == day && i.cardType == type && i.year == year) ?? -1;
}

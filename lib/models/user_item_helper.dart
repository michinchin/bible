import 'dart:convert';

import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_volumes/tec_volumes.dart';

import 'package:tec_util/tec_util.dart' as tec;

import 'app_settings.dart';
import 'search/search_history_item.dart';

class UserItemHelper {
  static const searchHistoryParentId = 3; // using note user item type
  static const navHistoryParentId = 4; // using book user item type

  /// save navigation history item from reference
  static Future<UserItem> saveNavHistoryItem(
    Reference ref,
  ) =>
      AppSettings.shared.userAccount.userDb.saveItem(UserItem(
          type: UserItemType.bookmark.index, parentId: navHistoryParentId, info: ref.toString()));

  /// navigation history items from db
  static Future<List<Reference>> navHistoryItemsFromDb() async {
    final items = await AppSettings.shared.userAccount.userDb
        .getItemsWithParent(navHistoryParentId, ofTypes: [UserItemType.bookmark]);
    final refs = <Reference>[];
    for (final i in items) {
      final ref = Reference.fromJson(i.info).copyWith(modified: tec.dateTimeFromDbInt(i.modified));
      refs.add(ref);
    }
    return refs;
  }

  /// search history items from db
  static Future<List<SearchHistoryItem>> searchHistoryItemsFromDb() async {
    final items = await AppSettings.shared.userAccount.userDb
        .getItemsWithParent(searchHistoryParentId, ofTypes: [UserItemType.note]);
    final searchItems = <SearchHistoryItem>[];
    for (final i in items) {
      final item = SearchHistoryItem.fromJson(tec.parseJsonSync(i.info));
      searchItems.add(item);
    }
    return searchItems;
  }

  /// save search history item to db
  static Future<UserItem> saveSearchHistoryItem(SearchHistoryItem item) =>
      AppSettings.shared.userAccount.userDb.saveItem(UserItem(
          type: UserItemType.note.index,
          parentId: searchHistoryParentId,
          info: tec.toJsonString(item.toJson())));
}

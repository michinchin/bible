import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_volumes/tec_volumes.dart';

import 'package:tec_util/tec_util.dart';

import 'app_settings.dart';
import 'search/search_history_item.dart';

class UserItemHelper {
  static const searchHistoryParentId = 3; // using note user item type
  static const navHistoryParentId = 4; // using bookmark user item type
  /// only allow 50 items to save at a time
  static const maxHistoryLength = 50;

  /// save navigation history item from reference
  static Future<void> saveNavHistoryItem(
    Reference ref,
  ) async {
    final items = await AppSettings.shared.userAccount.userDb
        .getItemsWithParent(navHistoryParentId, ofTypes: [UserItemType.bookmark]);

    // trim list to be 50
    if (items.length > maxHistoryLength) {
      for (var i = maxHistoryLength; i < items.length; i++) {
        items[i] = items[i].copyWith(deleted: 1);
        await AppSettings.shared.userAccount.userDb.saveItem(items[i]);
      }
    }
    final index = items.indexWhere((i) =>
        i.book == ref.book &&
        i.chapter == ref.chapter &&
        i.verse == ref.verse &&
        i.volumeId == ref.volume);

    UserItem item;
    if (index != -1) {
      item = items[index].copyWith(modified: DateTime.now(), deleted: 0);
    } else {
      item = createBookmark(ref).copyWith(parentId: navHistoryParentId);
    }

    await AppSettings.shared.userAccount.userDb.saveItem(item);
  }

  static UserItem createBookmark(Reference ref) => UserItem(
        created: dbIntFromDateTime(DateTime.now()),
        type: UserItemType.bookmark.index,
        book: ref.book,
        chapter: ref.chapter,
        verse: ref.verse,
        volumeId: ref.volume,
      );

  /// navigation history items from db
  static Future<List<Reference>> navHistoryItemsFromDb() async {
    final items = await AppSettings.shared.userAccount.userDb
        .getItemsWithParent(navHistoryParentId, ofTypes: [UserItemType.bookmark]);
    final refs = <Reference>[];
    final itemsToDelete = <UserItem>[];
    for (final i in items) {
      if (i.book == 0 || i.chapter == 0 || i.verse == 0 || i.volumeId == 0) {
        // delete invalid history entries
        itemsToDelete.add(i.copyWith(deleted: 1));
      } else {
        final ref = Reference(
          book: i.book,
          chapter: i.chapter,
          verse: i.verse,
          volume: i.volumeId,
        ).copyWith(modified: dateTimeFromDbInt(i.modified));
        refs.add(ref);
      }
    }

    if (itemsToDelete.isNotEmpty) {
      await AppSettings.shared.userAccount.userDb.saveSyncItems(itemsToDelete);
    }

    return refs;
  }

  /// search history items from db
  static Future<List<SearchHistoryItem>> searchHistoryItemsFromDb() async {
    final items = await AppSettings.shared.userAccount.userDb
        .getItemsWithParent(searchHistoryParentId, ofTypes: [UserItemType.note]);
    final searchItems = <SearchHistoryItem>[];
    for (final i in items) {
      final item = SearchHistoryItem.fromJson(parseJsonSync(i.info));
      if (item != null) {
        searchItems.add(item);
      }
    }
    return searchItems;
  }

  /// create user item from search history item
  static UserItem createSearchHistoryUserItem(SearchHistoryItem item) => UserItem(
      created: dbIntFromDateTime(DateTime.now()),
      type: UserItemType.note.index,
      parentId: searchHistoryParentId,
      info: toJsonString(item.toJson()));

  /// save search history item to db
  static Future<void> saveSearchHistoryItem(SearchHistoryItem searchHistoryItem) async {
    final items = await AppSettings.shared.userAccount.userDb
        .getItemsWithParent(searchHistoryParentId, ofTypes: [UserItemType.note]);

    // trim list to be 50 items
    if (items.length > maxHistoryLength) {
      for (var i = maxHistoryLength; i < items.length; i++) {
        items[i] = items[i].copyWith(deleted: 1);
        await AppSettings.shared.userAccount.userDb.saveItem(items[i]);
      }
    }

    // if item is already in list, move to top
    final lowerCaseSearch = searchHistoryItem.search.toLowerCase().trim();
    final index = items.indexWhere((i) =>
        lowerCaseSearch ==
        SearchHistoryItem.fromJson(parseJsonSync(i.info))?.search?.toLowerCase()?.trim());

    UserItem item;
    if (index != -1) {
      item = items[index].copyWith(
          modified: DateTime.now(), info: toJsonString(searchHistoryItem.toJson()), deleted: 0);
    } else {
      item = createSearchHistoryUserItem(searchHistoryItem);
    }
    await AppSettings.shared.userAccount.userDb.saveItem(item);
  }
}

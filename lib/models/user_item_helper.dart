import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_volumes/tec_volumes.dart';

class UserItemHelper {
  // static const historyParentId = 2; current history?
  static const searchHistoryParentId = 3; // note user item type
  static const navHistoryParentId = 4; // book user item type

  static UserItem navHistoryItem(
    Reference ref,
  ) =>
      UserItem(
          type: UserItemType.bookmark.index,
          parentId: navHistoryParentId,
          info: ref.toJson().toString());

  static UserItem searchHistoryItem(
    String search,
  ) =>
      UserItem(type: UserItemType.note.index, parentId: searchHistoryParentId, info: search);
}

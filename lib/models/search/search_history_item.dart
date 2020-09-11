import 'package:freezed_annotation/freezed_annotation.dart';
part 'search_history_item.freezed.dart';
part 'search_history_item.g.dart';

@freezed
abstract class SearchHistoryItem with _$SearchHistoryItem {
  const factory SearchHistoryItem({
    @required String search,
    @required String volumesFiltered,
    @required String booksFiltered,
    // @required int index,
    @required DateTime modified
  }) = _SearchHistoryItem;

  /// fromJson
  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryItemFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'search_history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
SearchHistoryItem _$SearchHistoryItemFromJson(Map<String, dynamic> json) {
  return _SearchHistoryItem.fromJson(json);
}

class _$SearchHistoryItemTearOff {
  const _$SearchHistoryItemTearOff();

// ignore: unused_element
  _SearchHistoryItem call(
      {@required String search,
      @required String volumesFiltered,
      @required String booksFiltered,
      @required int modified}) {
    return _SearchHistoryItem(
      search: search,
      volumesFiltered: volumesFiltered,
      booksFiltered: booksFiltered,
      modified: modified,
    );
  }
}

// ignore: unused_element
const $SearchHistoryItem = _$SearchHistoryItemTearOff();

mixin _$SearchHistoryItem {
  String get search;
  String get volumesFiltered;
  String get booksFiltered;
  int get modified;

  Map<String, dynamic> toJson();
  $SearchHistoryItemCopyWith<SearchHistoryItem> get copyWith;
}

abstract class $SearchHistoryItemCopyWith<$Res> {
  factory $SearchHistoryItemCopyWith(
          SearchHistoryItem value, $Res Function(SearchHistoryItem) then) =
      _$SearchHistoryItemCopyWithImpl<$Res>;
  $Res call(
      {String search,
      String volumesFiltered,
      String booksFiltered,
      int modified});
}

class _$SearchHistoryItemCopyWithImpl<$Res>
    implements $SearchHistoryItemCopyWith<$Res> {
  _$SearchHistoryItemCopyWithImpl(this._value, this._then);

  final SearchHistoryItem _value;
  // ignore: unused_field
  final $Res Function(SearchHistoryItem) _then;

  @override
  $Res call({
    Object search = freezed,
    Object volumesFiltered = freezed,
    Object booksFiltered = freezed,
    Object modified = freezed,
  }) {
    return _then(_value.copyWith(
      search: search == freezed ? _value.search : search as String,
      volumesFiltered: volumesFiltered == freezed
          ? _value.volumesFiltered
          : volumesFiltered as String,
      booksFiltered: booksFiltered == freezed
          ? _value.booksFiltered
          : booksFiltered as String,
      modified: modified == freezed ? _value.modified : modified as int,
    ));
  }
}

abstract class _$SearchHistoryItemCopyWith<$Res>
    implements $SearchHistoryItemCopyWith<$Res> {
  factory _$SearchHistoryItemCopyWith(
          _SearchHistoryItem value, $Res Function(_SearchHistoryItem) then) =
      __$SearchHistoryItemCopyWithImpl<$Res>;
  @override
  $Res call(
      {String search,
      String volumesFiltered,
      String booksFiltered,
      int modified});
}

class __$SearchHistoryItemCopyWithImpl<$Res>
    extends _$SearchHistoryItemCopyWithImpl<$Res>
    implements _$SearchHistoryItemCopyWith<$Res> {
  __$SearchHistoryItemCopyWithImpl(
      _SearchHistoryItem _value, $Res Function(_SearchHistoryItem) _then)
      : super(_value, (v) => _then(v as _SearchHistoryItem));

  @override
  _SearchHistoryItem get _value => super._value as _SearchHistoryItem;

  @override
  $Res call({
    Object search = freezed,
    Object volumesFiltered = freezed,
    Object booksFiltered = freezed,
    Object modified = freezed,
  }) {
    return _then(_SearchHistoryItem(
      search: search == freezed ? _value.search : search as String,
      volumesFiltered: volumesFiltered == freezed
          ? _value.volumesFiltered
          : volumesFiltered as String,
      booksFiltered: booksFiltered == freezed
          ? _value.booksFiltered
          : booksFiltered as String,
      modified: modified == freezed ? _value.modified : modified as int,
    ));
  }
}

@JsonSerializable()
class _$_SearchHistoryItem implements _SearchHistoryItem {
  const _$_SearchHistoryItem(
      {@required this.search,
      @required this.volumesFiltered,
      @required this.booksFiltered,
      @required this.modified})
      : assert(search != null),
        assert(volumesFiltered != null),
        assert(booksFiltered != null),
        assert(modified != null);

  factory _$_SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$_$_SearchHistoryItemFromJson(json);

  @override
  final String search;
  @override
  final String volumesFiltered;
  @override
  final String booksFiltered;
  @override
  final int modified;

  @override
  String toString() {
    return 'SearchHistoryItem(search: $search, volumesFiltered: $volumesFiltered, booksFiltered: $booksFiltered, modified: $modified)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SearchHistoryItem &&
            (identical(other.search, search) ||
                const DeepCollectionEquality().equals(other.search, search)) &&
            (identical(other.volumesFiltered, volumesFiltered) ||
                const DeepCollectionEquality()
                    .equals(other.volumesFiltered, volumesFiltered)) &&
            (identical(other.booksFiltered, booksFiltered) ||
                const DeepCollectionEquality()
                    .equals(other.booksFiltered, booksFiltered)) &&
            (identical(other.modified, modified) ||
                const DeepCollectionEquality()
                    .equals(other.modified, modified)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(search) ^
      const DeepCollectionEquality().hash(volumesFiltered) ^
      const DeepCollectionEquality().hash(booksFiltered) ^
      const DeepCollectionEquality().hash(modified);

  @override
  _$SearchHistoryItemCopyWith<_SearchHistoryItem> get copyWith =>
      __$SearchHistoryItemCopyWithImpl<_SearchHistoryItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_SearchHistoryItemToJson(this);
  }
}

abstract class _SearchHistoryItem implements SearchHistoryItem {
  const factory _SearchHistoryItem(
      {@required String search,
      @required String volumesFiltered,
      @required String booksFiltered,
      @required int modified}) = _$_SearchHistoryItem;

  factory _SearchHistoryItem.fromJson(Map<String, dynamic> json) =
      _$_SearchHistoryItem.fromJson;

  @override
  String get search;
  @override
  String get volumesFiltered;
  @override
  String get booksFiltered;
  @override
  int get modified;
  @override
  _$SearchHistoryItemCopyWith<_SearchHistoryItem> get copyWith;
}

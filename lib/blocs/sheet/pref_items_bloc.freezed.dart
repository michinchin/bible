// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'pref_items_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$PrefItemEventTearOff {
  const _$PrefItemEventTearOff();

// ignore: unused_element
  _Add add({@required PrefItem prefItem}) {
    return _Add(
      prefItem: prefItem,
    );
  }

// ignore: unused_element
  _Delete delete({@required PrefItem prefItem}) {
    return _Delete(
      prefItem: prefItem,
    );
  }

// ignore: unused_element
  _Update update({@required PrefItem prefItem}) {
    return _Update(
      prefItem: prefItem,
    );
  }
}

// ignore: unused_element
const $PrefItemEvent = _$PrefItemEventTearOff();

mixin _$PrefItemEvent {
  PrefItem get prefItem;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(PrefItem prefItem),
    @required Result delete(PrefItem prefItem),
    @required Result update(PrefItem prefItem),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(PrefItem prefItem),
    Result delete(PrefItem prefItem),
    Result update(PrefItem prefItem),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result update(_Update value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result delete(_Delete value),
    Result update(_Update value),
    @required Result orElse(),
  });

  $PrefItemEventCopyWith<PrefItemEvent> get copyWith;
}

abstract class $PrefItemEventCopyWith<$Res> {
  factory $PrefItemEventCopyWith(
          PrefItemEvent value, $Res Function(PrefItemEvent) then) =
      _$PrefItemEventCopyWithImpl<$Res>;
  $Res call({PrefItem prefItem});
}

class _$PrefItemEventCopyWithImpl<$Res>
    implements $PrefItemEventCopyWith<$Res> {
  _$PrefItemEventCopyWithImpl(this._value, this._then);

  final PrefItemEvent _value;
  // ignore: unused_field
  final $Res Function(PrefItemEvent) _then;

  @override
  $Res call({
    Object prefItem = freezed,
  }) {
    return _then(_value.copyWith(
      prefItem: prefItem == freezed ? _value.prefItem : prefItem as PrefItem,
    ));
  }
}

abstract class _$AddCopyWith<$Res> implements $PrefItemEventCopyWith<$Res> {
  factory _$AddCopyWith(_Add value, $Res Function(_Add) then) =
      __$AddCopyWithImpl<$Res>;
  @override
  $Res call({PrefItem prefItem});
}

class __$AddCopyWithImpl<$Res> extends _$PrefItemEventCopyWithImpl<$Res>
    implements _$AddCopyWith<$Res> {
  __$AddCopyWithImpl(_Add _value, $Res Function(_Add) _then)
      : super(_value, (v) => _then(v as _Add));

  @override
  _Add get _value => super._value as _Add;

  @override
  $Res call({
    Object prefItem = freezed,
  }) {
    return _then(_Add(
      prefItem: prefItem == freezed ? _value.prefItem : prefItem as PrefItem,
    ));
  }
}

class _$_Add implements _Add {
  const _$_Add({@required this.prefItem}) : assert(prefItem != null);

  @override
  final PrefItem prefItem;

  @override
  String toString() {
    return 'PrefItemEvent.add(prefItem: $prefItem)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Add &&
            (identical(other.prefItem, prefItem) ||
                const DeepCollectionEquality()
                    .equals(other.prefItem, prefItem)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(prefItem);

  @override
  _$AddCopyWith<_Add> get copyWith =>
      __$AddCopyWithImpl<_Add>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(PrefItem prefItem),
    @required Result delete(PrefItem prefItem),
    @required Result update(PrefItem prefItem),
  }) {
    assert(add != null);
    assert(delete != null);
    assert(update != null);
    return add(prefItem);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(PrefItem prefItem),
    Result delete(PrefItem prefItem),
    Result update(PrefItem prefItem),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(prefItem);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result update(_Update value),
  }) {
    assert(add != null);
    assert(delete != null);
    assert(update != null);
    return add(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result delete(_Delete value),
    Result update(_Update value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(this);
    }
    return orElse();
  }
}

abstract class _Add implements PrefItemEvent {
  const factory _Add({@required PrefItem prefItem}) = _$_Add;

  @override
  PrefItem get prefItem;
  @override
  _$AddCopyWith<_Add> get copyWith;
}

abstract class _$DeleteCopyWith<$Res> implements $PrefItemEventCopyWith<$Res> {
  factory _$DeleteCopyWith(_Delete value, $Res Function(_Delete) then) =
      __$DeleteCopyWithImpl<$Res>;
  @override
  $Res call({PrefItem prefItem});
}

class __$DeleteCopyWithImpl<$Res> extends _$PrefItemEventCopyWithImpl<$Res>
    implements _$DeleteCopyWith<$Res> {
  __$DeleteCopyWithImpl(_Delete _value, $Res Function(_Delete) _then)
      : super(_value, (v) => _then(v as _Delete));

  @override
  _Delete get _value => super._value as _Delete;

  @override
  $Res call({
    Object prefItem = freezed,
  }) {
    return _then(_Delete(
      prefItem: prefItem == freezed ? _value.prefItem : prefItem as PrefItem,
    ));
  }
}

class _$_Delete implements _Delete {
  const _$_Delete({@required this.prefItem}) : assert(prefItem != null);

  @override
  final PrefItem prefItem;

  @override
  String toString() {
    return 'PrefItemEvent.delete(prefItem: $prefItem)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Delete &&
            (identical(other.prefItem, prefItem) ||
                const DeepCollectionEquality()
                    .equals(other.prefItem, prefItem)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(prefItem);

  @override
  _$DeleteCopyWith<_Delete> get copyWith =>
      __$DeleteCopyWithImpl<_Delete>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(PrefItem prefItem),
    @required Result delete(PrefItem prefItem),
    @required Result update(PrefItem prefItem),
  }) {
    assert(add != null);
    assert(delete != null);
    assert(update != null);
    return delete(prefItem);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(PrefItem prefItem),
    Result delete(PrefItem prefItem),
    Result update(PrefItem prefItem),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (delete != null) {
      return delete(prefItem);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result update(_Update value),
  }) {
    assert(add != null);
    assert(delete != null);
    assert(update != null);
    return delete(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result delete(_Delete value),
    Result update(_Update value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class _Delete implements PrefItemEvent {
  const factory _Delete({@required PrefItem prefItem}) = _$_Delete;

  @override
  PrefItem get prefItem;
  @override
  _$DeleteCopyWith<_Delete> get copyWith;
}

abstract class _$UpdateCopyWith<$Res> implements $PrefItemEventCopyWith<$Res> {
  factory _$UpdateCopyWith(_Update value, $Res Function(_Update) then) =
      __$UpdateCopyWithImpl<$Res>;
  @override
  $Res call({PrefItem prefItem});
}

class __$UpdateCopyWithImpl<$Res> extends _$PrefItemEventCopyWithImpl<$Res>
    implements _$UpdateCopyWith<$Res> {
  __$UpdateCopyWithImpl(_Update _value, $Res Function(_Update) _then)
      : super(_value, (v) => _then(v as _Update));

  @override
  _Update get _value => super._value as _Update;

  @override
  $Res call({
    Object prefItem = freezed,
  }) {
    return _then(_Update(
      prefItem: prefItem == freezed ? _value.prefItem : prefItem as PrefItem,
    ));
  }
}

class _$_Update implements _Update {
  const _$_Update({@required this.prefItem}) : assert(prefItem != null);

  @override
  final PrefItem prefItem;

  @override
  String toString() {
    return 'PrefItemEvent.update(prefItem: $prefItem)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Update &&
            (identical(other.prefItem, prefItem) ||
                const DeepCollectionEquality()
                    .equals(other.prefItem, prefItem)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(prefItem);

  @override
  _$UpdateCopyWith<_Update> get copyWith =>
      __$UpdateCopyWithImpl<_Update>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(PrefItem prefItem),
    @required Result delete(PrefItem prefItem),
    @required Result update(PrefItem prefItem),
  }) {
    assert(add != null);
    assert(delete != null);
    assert(update != null);
    return update(prefItem);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(PrefItem prefItem),
    Result delete(PrefItem prefItem),
    Result update(PrefItem prefItem),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (update != null) {
      return update(prefItem);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result update(_Update value),
  }) {
    assert(add != null);
    assert(delete != null);
    assert(update != null);
    return update(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result delete(_Delete value),
    Result update(_Update value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class _Update implements PrefItemEvent {
  const factory _Update({@required PrefItem prefItem}) = _$_Update;

  @override
  PrefItem get prefItem;
  @override
  _$UpdateCopyWith<_Update> get copyWith;
}

class _$PrefItemsTearOff {
  const _$PrefItemsTearOff();

// ignore: unused_element
  _PrefItems call(List<PrefItem> items) {
    return _PrefItems(
      items,
    );
  }
}

// ignore: unused_element
const $PrefItems = _$PrefItemsTearOff();

mixin _$PrefItems {
  List<PrefItem> get items;

  $PrefItemsCopyWith<PrefItems> get copyWith;
}

abstract class $PrefItemsCopyWith<$Res> {
  factory $PrefItemsCopyWith(PrefItems value, $Res Function(PrefItems) then) =
      _$PrefItemsCopyWithImpl<$Res>;
  $Res call({List<PrefItem> items});
}

class _$PrefItemsCopyWithImpl<$Res> implements $PrefItemsCopyWith<$Res> {
  _$PrefItemsCopyWithImpl(this._value, this._then);

  final PrefItems _value;
  // ignore: unused_field
  final $Res Function(PrefItems) _then;

  @override
  $Res call({
    Object items = freezed,
  }) {
    return _then(_value.copyWith(
      items: items == freezed ? _value.items : items as List<PrefItem>,
    ));
  }
}

abstract class _$PrefItemsCopyWith<$Res> implements $PrefItemsCopyWith<$Res> {
  factory _$PrefItemsCopyWith(
          _PrefItems value, $Res Function(_PrefItems) then) =
      __$PrefItemsCopyWithImpl<$Res>;
  @override
  $Res call({List<PrefItem> items});
}

class __$PrefItemsCopyWithImpl<$Res> extends _$PrefItemsCopyWithImpl<$Res>
    implements _$PrefItemsCopyWith<$Res> {
  __$PrefItemsCopyWithImpl(_PrefItems _value, $Res Function(_PrefItems) _then)
      : super(_value, (v) => _then(v as _PrefItems));

  @override
  _PrefItems get _value => super._value as _PrefItems;

  @override
  $Res call({
    Object items = freezed,
  }) {
    return _then(_PrefItems(
      items == freezed ? _value.items : items as List<PrefItem>,
    ));
  }
}

class _$_PrefItems implements _PrefItems {
  const _$_PrefItems(this.items) : assert(items != null);

  @override
  final List<PrefItem> items;

  @override
  String toString() {
    return 'PrefItems(items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _PrefItems &&
            (identical(other.items, items) ||
                const DeepCollectionEquality().equals(other.items, items)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(items);

  @override
  _$PrefItemsCopyWith<_PrefItems> get copyWith =>
      __$PrefItemsCopyWithImpl<_PrefItems>(this, _$identity);
}

abstract class _PrefItems implements PrefItems {
  const factory _PrefItems(List<PrefItem> items) = _$_PrefItems;

  @override
  List<PrefItem> get items;
  @override
  _$PrefItemsCopyWith<_PrefItems> get copyWith;
}

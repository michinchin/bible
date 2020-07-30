// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'highlights_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$ChapterHighlightsTearOff {
  const _$ChapterHighlightsTearOff();

// ignore: unused_element
  _ChapterHighlights call(
      int volume, int book, int chapter, List<Highlight> highlights,
      {bool loaded}) {
    return _ChapterHighlights(
      volume,
      book,
      chapter,
      highlights,
      loaded: loaded,
    );
  }
}

// ignore: unused_element
const $ChapterHighlights = _$ChapterHighlightsTearOff();

mixin _$ChapterHighlights {
  int get volume;
  int get book;
  int get chapter;
  List<Highlight> get highlights;
  bool get loaded;

  $ChapterHighlightsCopyWith<ChapterHighlights> get copyWith;
}

abstract class $ChapterHighlightsCopyWith<$Res> {
  factory $ChapterHighlightsCopyWith(
          ChapterHighlights value, $Res Function(ChapterHighlights) then) =
      _$ChapterHighlightsCopyWithImpl<$Res>;
  $Res call(
      {int volume,
      int book,
      int chapter,
      List<Highlight> highlights,
      bool loaded});
}

class _$ChapterHighlightsCopyWithImpl<$Res>
    implements $ChapterHighlightsCopyWith<$Res> {
  _$ChapterHighlightsCopyWithImpl(this._value, this._then);

  final ChapterHighlights _value;
  // ignore: unused_field
  final $Res Function(ChapterHighlights) _then;

  @override
  $Res call({
    Object volume = freezed,
    Object book = freezed,
    Object chapter = freezed,
    Object highlights = freezed,
    Object loaded = freezed,
  }) {
    return _then(_value.copyWith(
      volume: volume == freezed ? _value.volume : volume as int,
      book: book == freezed ? _value.book : book as int,
      chapter: chapter == freezed ? _value.chapter : chapter as int,
      highlights: highlights == freezed
          ? _value.highlights
          : highlights as List<Highlight>,
      loaded: loaded == freezed ? _value.loaded : loaded as bool,
    ));
  }
}

abstract class _$ChapterHighlightsCopyWith<$Res>
    implements $ChapterHighlightsCopyWith<$Res> {
  factory _$ChapterHighlightsCopyWith(
          _ChapterHighlights value, $Res Function(_ChapterHighlights) then) =
      __$ChapterHighlightsCopyWithImpl<$Res>;
  @override
  $Res call(
      {int volume,
      int book,
      int chapter,
      List<Highlight> highlights,
      bool loaded});
}

class __$ChapterHighlightsCopyWithImpl<$Res>
    extends _$ChapterHighlightsCopyWithImpl<$Res>
    implements _$ChapterHighlightsCopyWith<$Res> {
  __$ChapterHighlightsCopyWithImpl(
      _ChapterHighlights _value, $Res Function(_ChapterHighlights) _then)
      : super(_value, (v) => _then(v as _ChapterHighlights));

  @override
  _ChapterHighlights get _value => super._value as _ChapterHighlights;

  @override
  $Res call({
    Object volume = freezed,
    Object book = freezed,
    Object chapter = freezed,
    Object highlights = freezed,
    Object loaded = freezed,
  }) {
    return _then(_ChapterHighlights(
      volume == freezed ? _value.volume : volume as int,
      book == freezed ? _value.book : book as int,
      chapter == freezed ? _value.chapter : chapter as int,
      highlights == freezed ? _value.highlights : highlights as List<Highlight>,
      loaded: loaded == freezed ? _value.loaded : loaded as bool,
    ));
  }
}

class _$_ChapterHighlights
    with DiagnosticableTreeMixin
    implements _ChapterHighlights {
  const _$_ChapterHighlights(
      this.volume, this.book, this.chapter, this.highlights,
      {this.loaded})
      : assert(volume != null),
        assert(book != null),
        assert(chapter != null),
        assert(highlights != null);

  @override
  final int volume;
  @override
  final int book;
  @override
  final int chapter;
  @override
  final List<Highlight> highlights;
  @override
  final bool loaded;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChapterHighlights(volume: $volume, book: $book, chapter: $chapter, highlights: $highlights, loaded: $loaded)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChapterHighlights'))
      ..add(DiagnosticsProperty('volume', volume))
      ..add(DiagnosticsProperty('book', book))
      ..add(DiagnosticsProperty('chapter', chapter))
      ..add(DiagnosticsProperty('highlights', highlights))
      ..add(DiagnosticsProperty('loaded', loaded));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChapterHighlights &&
            (identical(other.volume, volume) ||
                const DeepCollectionEquality().equals(other.volume, volume)) &&
            (identical(other.book, book) ||
                const DeepCollectionEquality().equals(other.book, book)) &&
            (identical(other.chapter, chapter) ||
                const DeepCollectionEquality()
                    .equals(other.chapter, chapter)) &&
            (identical(other.highlights, highlights) ||
                const DeepCollectionEquality()
                    .equals(other.highlights, highlights)) &&
            (identical(other.loaded, loaded) ||
                const DeepCollectionEquality().equals(other.loaded, loaded)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(volume) ^
      const DeepCollectionEquality().hash(book) ^
      const DeepCollectionEquality().hash(chapter) ^
      const DeepCollectionEquality().hash(highlights) ^
      const DeepCollectionEquality().hash(loaded);

  @override
  _$ChapterHighlightsCopyWith<_ChapterHighlights> get copyWith =>
      __$ChapterHighlightsCopyWithImpl<_ChapterHighlights>(this, _$identity);
}

abstract class _ChapterHighlights implements ChapterHighlights {
  const factory _ChapterHighlights(
      int volume, int book, int chapter, List<Highlight> highlights,
      {bool loaded}) = _$_ChapterHighlights;

  @override
  int get volume;
  @override
  int get book;
  @override
  int get chapter;
  @override
  List<Highlight> get highlights;
  @override
  bool get loaded;
  @override
  _$ChapterHighlightsCopyWith<_ChapterHighlights> get copyWith;
}

class _$HighlightTearOff {
  const _$HighlightTearOff();

// ignore: unused_element
  _Highlight call(HighlightType highlightType, int color, Reference ref) {
    return _Highlight(
      highlightType,
      color,
      ref,
    );
  }
}

// ignore: unused_element
const $Highlight = _$HighlightTearOff();

mixin _$Highlight {
  HighlightType get highlightType;
  int get color;
  Reference get ref;

  $HighlightCopyWith<Highlight> get copyWith;
}

abstract class $HighlightCopyWith<$Res> {
  factory $HighlightCopyWith(Highlight value, $Res Function(Highlight) then) =
      _$HighlightCopyWithImpl<$Res>;
  $Res call({HighlightType highlightType, int color, Reference ref});
}

class _$HighlightCopyWithImpl<$Res> implements $HighlightCopyWith<$Res> {
  _$HighlightCopyWithImpl(this._value, this._then);

  final Highlight _value;
  // ignore: unused_field
  final $Res Function(Highlight) _then;

  @override
  $Res call({
    Object highlightType = freezed,
    Object color = freezed,
    Object ref = freezed,
  }) {
    return _then(_value.copyWith(
      highlightType: highlightType == freezed
          ? _value.highlightType
          : highlightType as HighlightType,
      color: color == freezed ? _value.color : color as int,
      ref: ref == freezed ? _value.ref : ref as Reference,
    ));
  }
}

abstract class _$HighlightCopyWith<$Res> implements $HighlightCopyWith<$Res> {
  factory _$HighlightCopyWith(
          _Highlight value, $Res Function(_Highlight) then) =
      __$HighlightCopyWithImpl<$Res>;
  @override
  $Res call({HighlightType highlightType, int color, Reference ref});
}

class __$HighlightCopyWithImpl<$Res> extends _$HighlightCopyWithImpl<$Res>
    implements _$HighlightCopyWith<$Res> {
  __$HighlightCopyWithImpl(_Highlight _value, $Res Function(_Highlight) _then)
      : super(_value, (v) => _then(v as _Highlight));

  @override
  _Highlight get _value => super._value as _Highlight;

  @override
  $Res call({
    Object highlightType = freezed,
    Object color = freezed,
    Object ref = freezed,
  }) {
    return _then(_Highlight(
      highlightType == freezed
          ? _value.highlightType
          : highlightType as HighlightType,
      color == freezed ? _value.color : color as int,
      ref == freezed ? _value.ref : ref as Reference,
    ));
  }
}

class _$_Highlight with DiagnosticableTreeMixin implements _Highlight {
  const _$_Highlight(this.highlightType, this.color, this.ref)
      : assert(highlightType != null),
        assert(color != null),
        assert(ref != null);

  @override
  final HighlightType highlightType;
  @override
  final int color;
  @override
  final Reference ref;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Highlight(highlightType: $highlightType, color: $color, ref: $ref)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Highlight'))
      ..add(DiagnosticsProperty('highlightType', highlightType))
      ..add(DiagnosticsProperty('color', color))
      ..add(DiagnosticsProperty('ref', ref));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Highlight &&
            (identical(other.highlightType, highlightType) ||
                const DeepCollectionEquality()
                    .equals(other.highlightType, highlightType)) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)) &&
            (identical(other.ref, ref) ||
                const DeepCollectionEquality().equals(other.ref, ref)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(highlightType) ^
      const DeepCollectionEquality().hash(color) ^
      const DeepCollectionEquality().hash(ref);

  @override
  _$HighlightCopyWith<_Highlight> get copyWith =>
      __$HighlightCopyWithImpl<_Highlight>(this, _$identity);
}

abstract class _Highlight implements Highlight {
  const factory _Highlight(
      HighlightType highlightType, int color, Reference ref) = _$_Highlight;

  @override
  HighlightType get highlightType;
  @override
  int get color;
  @override
  Reference get ref;
  @override
  _$HighlightCopyWith<_Highlight> get copyWith;
}

class _$HighlightEventTearOff {
  const _$HighlightEventTearOff();

// ignore: unused_element
  _UpdateFromDb updateFromDb({@required List<Highlight> hls}) {
    return _UpdateFromDb(
      hls: hls,
    );
  }

// ignore: unused_element
  _Add add(
      {@required HighlightType type,
      @required int color,
      @required Reference ref,
      @required HighlightMode mode}) {
    return _Add(
      type: type,
      color: color,
      ref: ref,
      mode: mode,
    );
  }

// ignore: unused_element
  _Clear clear(Reference ref, HighlightMode mode) {
    return _Clear(
      ref,
      mode,
    );
  }
}

// ignore: unused_element
const $HighlightEvent = _$HighlightEventTearOff();

mixin _$HighlightEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(List<Highlight> hls),
    @required
        Result add(
            HighlightType type, int color, Reference ref, HighlightMode mode),
    @required Result clear(Reference ref, HighlightMode mode),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(List<Highlight> hls),
    Result add(
        HighlightType type, int color, Reference ref, HighlightMode mode),
    Result clear(Reference ref, HighlightMode mode),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result clear(_Clear value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result clear(_Clear value),
    @required Result orElse(),
  });
}

abstract class $HighlightEventCopyWith<$Res> {
  factory $HighlightEventCopyWith(
          HighlightEvent value, $Res Function(HighlightEvent) then) =
      _$HighlightEventCopyWithImpl<$Res>;
}

class _$HighlightEventCopyWithImpl<$Res>
    implements $HighlightEventCopyWith<$Res> {
  _$HighlightEventCopyWithImpl(this._value, this._then);

  final HighlightEvent _value;
  // ignore: unused_field
  final $Res Function(HighlightEvent) _then;
}

abstract class _$UpdateFromDbCopyWith<$Res> {
  factory _$UpdateFromDbCopyWith(
          _UpdateFromDb value, $Res Function(_UpdateFromDb) then) =
      __$UpdateFromDbCopyWithImpl<$Res>;
  $Res call({List<Highlight> hls});
}

class __$UpdateFromDbCopyWithImpl<$Res>
    extends _$HighlightEventCopyWithImpl<$Res>
    implements _$UpdateFromDbCopyWith<$Res> {
  __$UpdateFromDbCopyWithImpl(
      _UpdateFromDb _value, $Res Function(_UpdateFromDb) _then)
      : super(_value, (v) => _then(v as _UpdateFromDb));

  @override
  _UpdateFromDb get _value => super._value as _UpdateFromDb;

  @override
  $Res call({
    Object hls = freezed,
  }) {
    return _then(_UpdateFromDb(
      hls: hls == freezed ? _value.hls : hls as List<Highlight>,
    ));
  }
}

class _$_UpdateFromDb with DiagnosticableTreeMixin implements _UpdateFromDb {
  const _$_UpdateFromDb({@required this.hls}) : assert(hls != null);

  @override
  final List<Highlight> hls;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HighlightEvent.updateFromDb(hls: $hls)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'HighlightEvent.updateFromDb'))
      ..add(DiagnosticsProperty('hls', hls));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _UpdateFromDb &&
            (identical(other.hls, hls) ||
                const DeepCollectionEquality().equals(other.hls, hls)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(hls);

  @override
  _$UpdateFromDbCopyWith<_UpdateFromDb> get copyWith =>
      __$UpdateFromDbCopyWithImpl<_UpdateFromDb>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(List<Highlight> hls),
    @required
        Result add(
            HighlightType type, int color, Reference ref, HighlightMode mode),
    @required Result clear(Reference ref, HighlightMode mode),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(clear != null);
    return updateFromDb(hls);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(List<Highlight> hls),
    Result add(
        HighlightType type, int color, Reference ref, HighlightMode mode),
    Result clear(Reference ref, HighlightMode mode),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateFromDb != null) {
      return updateFromDb(hls);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result clear(_Clear value),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(clear != null);
    return updateFromDb(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result clear(_Clear value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateFromDb != null) {
      return updateFromDb(this);
    }
    return orElse();
  }
}

abstract class _UpdateFromDb implements HighlightEvent {
  const factory _UpdateFromDb({@required List<Highlight> hls}) =
      _$_UpdateFromDb;

  List<Highlight> get hls;
  _$UpdateFromDbCopyWith<_UpdateFromDb> get copyWith;
}

abstract class _$AddCopyWith<$Res> {
  factory _$AddCopyWith(_Add value, $Res Function(_Add) then) =
      __$AddCopyWithImpl<$Res>;
  $Res call({HighlightType type, int color, Reference ref, HighlightMode mode});
}

class __$AddCopyWithImpl<$Res> extends _$HighlightEventCopyWithImpl<$Res>
    implements _$AddCopyWith<$Res> {
  __$AddCopyWithImpl(_Add _value, $Res Function(_Add) _then)
      : super(_value, (v) => _then(v as _Add));

  @override
  _Add get _value => super._value as _Add;

  @override
  $Res call({
    Object type = freezed,
    Object color = freezed,
    Object ref = freezed,
    Object mode = freezed,
  }) {
    return _then(_Add(
      type: type == freezed ? _value.type : type as HighlightType,
      color: color == freezed ? _value.color : color as int,
      ref: ref == freezed ? _value.ref : ref as Reference,
      mode: mode == freezed ? _value.mode : mode as HighlightMode,
    ));
  }
}

class _$_Add with DiagnosticableTreeMixin implements _Add {
  const _$_Add(
      {@required this.type,
      @required this.color,
      @required this.ref,
      @required this.mode})
      : assert(type != null),
        assert(color != null),
        assert(ref != null),
        assert(mode != null);

  @override
  final HighlightType type;
  @override
  final int color;
  @override
  final Reference ref;
  @override
  final HighlightMode mode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HighlightEvent.add(type: $type, color: $color, ref: $ref, mode: $mode)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'HighlightEvent.add'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('color', color))
      ..add(DiagnosticsProperty('ref', ref))
      ..add(DiagnosticsProperty('mode', mode));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Add &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)) &&
            (identical(other.ref, ref) ||
                const DeepCollectionEquality().equals(other.ref, ref)) &&
            (identical(other.mode, mode) ||
                const DeepCollectionEquality().equals(other.mode, mode)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(color) ^
      const DeepCollectionEquality().hash(ref) ^
      const DeepCollectionEquality().hash(mode);

  @override
  _$AddCopyWith<_Add> get copyWith =>
      __$AddCopyWithImpl<_Add>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(List<Highlight> hls),
    @required
        Result add(
            HighlightType type, int color, Reference ref, HighlightMode mode),
    @required Result clear(Reference ref, HighlightMode mode),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(clear != null);
    return add(type, color, ref, mode);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(List<Highlight> hls),
    Result add(
        HighlightType type, int color, Reference ref, HighlightMode mode),
    Result clear(Reference ref, HighlightMode mode),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(type, color, ref, mode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result clear(_Clear value),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(clear != null);
    return add(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result clear(_Clear value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(this);
    }
    return orElse();
  }
}

abstract class _Add implements HighlightEvent {
  const factory _Add(
      {@required HighlightType type,
      @required int color,
      @required Reference ref,
      @required HighlightMode mode}) = _$_Add;

  HighlightType get type;
  int get color;
  Reference get ref;
  HighlightMode get mode;
  _$AddCopyWith<_Add> get copyWith;
}

abstract class _$ClearCopyWith<$Res> {
  factory _$ClearCopyWith(_Clear value, $Res Function(_Clear) then) =
      __$ClearCopyWithImpl<$Res>;
  $Res call({Reference ref, HighlightMode mode});
}

class __$ClearCopyWithImpl<$Res> extends _$HighlightEventCopyWithImpl<$Res>
    implements _$ClearCopyWith<$Res> {
  __$ClearCopyWithImpl(_Clear _value, $Res Function(_Clear) _then)
      : super(_value, (v) => _then(v as _Clear));

  @override
  _Clear get _value => super._value as _Clear;

  @override
  $Res call({
    Object ref = freezed,
    Object mode = freezed,
  }) {
    return _then(_Clear(
      ref == freezed ? _value.ref : ref as Reference,
      mode == freezed ? _value.mode : mode as HighlightMode,
    ));
  }
}

class _$_Clear with DiagnosticableTreeMixin implements _Clear {
  const _$_Clear(this.ref, this.mode)
      : assert(ref != null),
        assert(mode != null);

  @override
  final Reference ref;
  @override
  final HighlightMode mode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HighlightEvent.clear(ref: $ref, mode: $mode)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'HighlightEvent.clear'))
      ..add(DiagnosticsProperty('ref', ref))
      ..add(DiagnosticsProperty('mode', mode));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Clear &&
            (identical(other.ref, ref) ||
                const DeepCollectionEquality().equals(other.ref, ref)) &&
            (identical(other.mode, mode) ||
                const DeepCollectionEquality().equals(other.mode, mode)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(ref) ^
      const DeepCollectionEquality().hash(mode);

  @override
  _$ClearCopyWith<_Clear> get copyWith =>
      __$ClearCopyWithImpl<_Clear>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(List<Highlight> hls),
    @required
        Result add(
            HighlightType type, int color, Reference ref, HighlightMode mode),
    @required Result clear(Reference ref, HighlightMode mode),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(clear != null);
    return clear(ref, mode);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(List<Highlight> hls),
    Result add(
        HighlightType type, int color, Reference ref, HighlightMode mode),
    Result clear(Reference ref, HighlightMode mode),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (clear != null) {
      return clear(ref, mode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result clear(_Clear value),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(clear != null);
    return clear(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result clear(_Clear value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (clear != null) {
      return clear(this);
    }
    return orElse();
  }
}

abstract class _Clear implements HighlightEvent {
  const factory _Clear(Reference ref, HighlightMode mode) = _$_Clear;

  Reference get ref;
  HighlightMode get mode;
  _$ClearCopyWith<_Clear> get copyWith;
}

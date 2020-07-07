// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'highlights_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$ChapterHighlightsTearOff {
  const _$ChapterHighlightsTearOff();

  _ChapterHighlights call(
      int volume, int book, int chapter, List<Highlight> highlights) {
    return _ChapterHighlights(
      volume,
      book,
      chapter,
      highlights,
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

  $ChapterHighlightsCopyWith<ChapterHighlights> get copyWith;
}

abstract class $ChapterHighlightsCopyWith<$Res> {
  factory $ChapterHighlightsCopyWith(
          ChapterHighlights value, $Res Function(ChapterHighlights) then) =
      _$ChapterHighlightsCopyWithImpl<$Res>;
  $Res call({int volume, int book, int chapter, List<Highlight> highlights});
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
  }) {
    return _then(_value.copyWith(
      volume: volume == freezed ? _value.volume : volume as int,
      book: book == freezed ? _value.book : book as int,
      chapter: chapter == freezed ? _value.chapter : chapter as int,
      highlights: highlights == freezed
          ? _value.highlights
          : highlights as List<Highlight>,
    ));
  }
}

abstract class _$ChapterHighlightsCopyWith<$Res>
    implements $ChapterHighlightsCopyWith<$Res> {
  factory _$ChapterHighlightsCopyWith(
          _ChapterHighlights value, $Res Function(_ChapterHighlights) then) =
      __$ChapterHighlightsCopyWithImpl<$Res>;
  @override
  $Res call({int volume, int book, int chapter, List<Highlight> highlights});
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
  }) {
    return _then(_ChapterHighlights(
      volume == freezed ? _value.volume : volume as int,
      book == freezed ? _value.book : book as int,
      chapter == freezed ? _value.chapter : chapter as int,
      highlights == freezed ? _value.highlights : highlights as List<Highlight>,
    ));
  }
}

class _$_ChapterHighlights implements _ChapterHighlights {
  const _$_ChapterHighlights(
      this.volume, this.book, this.chapter, this.highlights)
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
  String toString() {
    return 'ChapterHighlights(volume: $volume, book: $book, chapter: $chapter, highlights: $highlights)';
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
                    .equals(other.highlights, highlights)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(volume) ^
      const DeepCollectionEquality().hash(book) ^
      const DeepCollectionEquality().hash(chapter) ^
      const DeepCollectionEquality().hash(highlights);

  @override
  _$ChapterHighlightsCopyWith<_ChapterHighlights> get copyWith =>
      __$ChapterHighlightsCopyWithImpl<_ChapterHighlights>(this, _$identity);
}

abstract class _ChapterHighlights implements ChapterHighlights {
  const factory _ChapterHighlights(
          int volume, int book, int chapter, List<Highlight> highlights) =
      _$_ChapterHighlights;

  @override
  int get volume;
  @override
  int get book;
  @override
  int get chapter;
  @override
  List<Highlight> get highlights;
  @override
  _$ChapterHighlightsCopyWith<_ChapterHighlights> get copyWith;
}

class _$HighlightTearOff {
  const _$HighlightTearOff();

  _Highlight call(HighlightType highlightType, int color, Reference ref,
      DateTime modified) {
    return _Highlight(
      highlightType,
      color,
      ref,
      modified,
    );
  }
}

// ignore: unused_element
const $Highlight = _$HighlightTearOff();

mixin _$Highlight {
  HighlightType get highlightType;
  int get color;
  Reference get ref;
  DateTime get modified;

  $HighlightCopyWith<Highlight> get copyWith;
}

abstract class $HighlightCopyWith<$Res> {
  factory $HighlightCopyWith(Highlight value, $Res Function(Highlight) then) =
      _$HighlightCopyWithImpl<$Res>;
  $Res call(
      {HighlightType highlightType,
      int color,
      Reference ref,
      DateTime modified});
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
    Object modified = freezed,
  }) {
    return _then(_value.copyWith(
      highlightType: highlightType == freezed
          ? _value.highlightType
          : highlightType as HighlightType,
      color: color == freezed ? _value.color : color as int,
      ref: ref == freezed ? _value.ref : ref as Reference,
      modified: modified == freezed ? _value.modified : modified as DateTime,
    ));
  }
}

abstract class _$HighlightCopyWith<$Res> implements $HighlightCopyWith<$Res> {
  factory _$HighlightCopyWith(
          _Highlight value, $Res Function(_Highlight) then) =
      __$HighlightCopyWithImpl<$Res>;
  @override
  $Res call(
      {HighlightType highlightType,
      int color,
      Reference ref,
      DateTime modified});
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
    Object modified = freezed,
  }) {
    return _then(_Highlight(
      highlightType == freezed
          ? _value.highlightType
          : highlightType as HighlightType,
      color == freezed ? _value.color : color as int,
      ref == freezed ? _value.ref : ref as Reference,
      modified == freezed ? _value.modified : modified as DateTime,
    ));
  }
}

class _$_Highlight implements _Highlight {
  const _$_Highlight(this.highlightType, this.color, this.ref, this.modified)
      : assert(highlightType != null),
        assert(color != null),
        assert(ref != null),
        assert(modified != null);

  @override
  final HighlightType highlightType;
  @override
  final int color;
  @override
  final Reference ref;
  @override
  final DateTime modified;

  @override
  String toString() {
    return 'Highlight(highlightType: $highlightType, color: $color, ref: $ref, modified: $modified)';
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
                const DeepCollectionEquality().equals(other.ref, ref)) &&
            (identical(other.modified, modified) ||
                const DeepCollectionEquality()
                    .equals(other.modified, modified)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(highlightType) ^
      const DeepCollectionEquality().hash(color) ^
      const DeepCollectionEquality().hash(ref) ^
      const DeepCollectionEquality().hash(modified);

  @override
  _$HighlightCopyWith<_Highlight> get copyWith =>
      __$HighlightCopyWithImpl<_Highlight>(this, _$identity);
}

abstract class _Highlight implements Highlight {
  const factory _Highlight(HighlightType highlightType, int color,
      Reference ref, DateTime modified) = _$_Highlight;

  @override
  HighlightType get highlightType;
  @override
  int get color;
  @override
  Reference get ref;
  @override
  DateTime get modified;
  @override
  _$HighlightCopyWith<_Highlight> get copyWith;
}

class _$HighlightsEventTearOff {
  const _$HighlightsEventTearOff();

  _Add add(
      {@required HighlightType type,
      @required int color,
      @required Reference ref}) {
    return _Add(
      type: type,
      color: color,
      ref: ref,
    );
  }

  _Clear clear(Reference ref) {
    return _Clear(
      ref,
    );
  }
}

// ignore: unused_element
const $HighlightsEvent = _$HighlightsEventTearOff();

mixin _$HighlightsEvent {
  Reference get ref;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(HighlightType type, int color, Reference ref),
    @required Result clear(Reference ref),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(HighlightType type, int color, Reference ref),
    Result clear(Reference ref),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result clear(_Clear value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result clear(_Clear value),
    @required Result orElse(),
  });

  $HighlightsEventCopyWith<HighlightsEvent> get copyWith;
}

abstract class $HighlightsEventCopyWith<$Res> {
  factory $HighlightsEventCopyWith(
          HighlightsEvent value, $Res Function(HighlightsEvent) then) =
      _$HighlightsEventCopyWithImpl<$Res>;
  $Res call({Reference ref});
}

class _$HighlightsEventCopyWithImpl<$Res>
    implements $HighlightsEventCopyWith<$Res> {
  _$HighlightsEventCopyWithImpl(this._value, this._then);

  final HighlightsEvent _value;
  // ignore: unused_field
  final $Res Function(HighlightsEvent) _then;

  @override
  $Res call({
    Object ref = freezed,
  }) {
    return _then(_value.copyWith(
      ref: ref == freezed ? _value.ref : ref as Reference,
    ));
  }
}

abstract class _$AddCopyWith<$Res> implements $HighlightsEventCopyWith<$Res> {
  factory _$AddCopyWith(_Add value, $Res Function(_Add) then) =
      __$AddCopyWithImpl<$Res>;
  @override
  $Res call({HighlightType type, int color, Reference ref});
}

class __$AddCopyWithImpl<$Res> extends _$HighlightsEventCopyWithImpl<$Res>
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
  }) {
    return _then(_Add(
      type: type == freezed ? _value.type : type as HighlightType,
      color: color == freezed ? _value.color : color as int,
      ref: ref == freezed ? _value.ref : ref as Reference,
    ));
  }
}

class _$_Add implements _Add {
  const _$_Add({@required this.type, @required this.color, @required this.ref})
      : assert(type != null),
        assert(color != null),
        assert(ref != null);

  @override
  final HighlightType type;
  @override
  final int color;
  @override
  final Reference ref;

  @override
  String toString() {
    return 'HighlightsEvent.add(type: $type, color: $color, ref: $ref)';
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
                const DeepCollectionEquality().equals(other.ref, ref)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(color) ^
      const DeepCollectionEquality().hash(ref);

  @override
  _$AddCopyWith<_Add> get copyWith =>
      __$AddCopyWithImpl<_Add>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(HighlightType type, int color, Reference ref),
    @required Result clear(Reference ref),
  }) {
    assert(add != null);
    assert(clear != null);
    return add(type, color, ref);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(HighlightType type, int color, Reference ref),
    Result clear(Reference ref),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(type, color, ref);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result clear(_Clear value),
  }) {
    assert(add != null);
    assert(clear != null);
    return add(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
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

abstract class _Add implements HighlightsEvent {
  const factory _Add(
      {@required HighlightType type,
      @required int color,
      @required Reference ref}) = _$_Add;

  HighlightType get type;
  int get color;
  @override
  Reference get ref;
  @override
  _$AddCopyWith<_Add> get copyWith;
}

abstract class _$ClearCopyWith<$Res> implements $HighlightsEventCopyWith<$Res> {
  factory _$ClearCopyWith(_Clear value, $Res Function(_Clear) then) =
      __$ClearCopyWithImpl<$Res>;
  @override
  $Res call({Reference ref});
}

class __$ClearCopyWithImpl<$Res> extends _$HighlightsEventCopyWithImpl<$Res>
    implements _$ClearCopyWith<$Res> {
  __$ClearCopyWithImpl(_Clear _value, $Res Function(_Clear) _then)
      : super(_value, (v) => _then(v as _Clear));

  @override
  _Clear get _value => super._value as _Clear;

  @override
  $Res call({
    Object ref = freezed,
  }) {
    return _then(_Clear(
      ref == freezed ? _value.ref : ref as Reference,
    ));
  }
}

class _$_Clear implements _Clear {
  const _$_Clear(this.ref) : assert(ref != null);

  @override
  final Reference ref;

  @override
  String toString() {
    return 'HighlightsEvent.clear(ref: $ref)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Clear &&
            (identical(other.ref, ref) ||
                const DeepCollectionEquality().equals(other.ref, ref)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(ref);

  @override
  _$ClearCopyWith<_Clear> get copyWith =>
      __$ClearCopyWithImpl<_Clear>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(HighlightType type, int color, Reference ref),
    @required Result clear(Reference ref),
  }) {
    assert(add != null);
    assert(clear != null);
    return clear(ref);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(HighlightType type, int color, Reference ref),
    Result clear(Reference ref),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (clear != null) {
      return clear(ref);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result clear(_Clear value),
  }) {
    assert(add != null);
    assert(clear != null);
    return clear(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
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

abstract class _Clear implements HighlightsEvent {
  const factory _Clear(Reference ref) = _$_Clear;

  @override
  Reference get ref;
  @override
  _$ClearCopyWith<_Clear> get copyWith;
}
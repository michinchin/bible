// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'margin_notes_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$MarginNotesEventTearOff {
  const _$MarginNotesEventTearOff();

// ignore: unused_element
  _UpdateFromDb updateFromDb({@required Map<int, MarginNote> marginNotes}) {
    return _UpdateFromDb(
      marginNotes: marginNotes,
    );
  }

// ignore: unused_element
  _Add add({@required String text, @required Reference ref}) {
    return _Add(
      text: text,
      ref: ref,
    );
  }

// ignore: unused_element
  _Delete delete(MarginNote marginNote) {
    return _Delete(
      marginNote,
    );
  }

// ignore: unused_element
  _ChangeVolumeId changeVolumeId(int volumeId) {
    return _ChangeVolumeId(
      volumeId,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $MarginNotesEvent = _$MarginNotesEventTearOff();

/// @nodoc
mixin _$MarginNotesEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(Map<int, MarginNote> marginNotes),
    @required Result add(String text, Reference ref),
    @required Result delete(MarginNote marginNote),
    @required Result changeVolumeId(int volumeId),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(Map<int, MarginNote> marginNotes),
    Result add(String text, Reference ref),
    Result delete(MarginNote marginNote),
    Result changeVolumeId(int volumeId),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result changeVolumeId(_ChangeVolumeId value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result delete(_Delete value),
    Result changeVolumeId(_ChangeVolumeId value),
    @required Result orElse(),
  });
}

/// @nodoc
abstract class $MarginNotesEventCopyWith<$Res> {
  factory $MarginNotesEventCopyWith(
          MarginNotesEvent value, $Res Function(MarginNotesEvent) then) =
      _$MarginNotesEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$MarginNotesEventCopyWithImpl<$Res>
    implements $MarginNotesEventCopyWith<$Res> {
  _$MarginNotesEventCopyWithImpl(this._value, this._then);

  final MarginNotesEvent _value;
  // ignore: unused_field
  final $Res Function(MarginNotesEvent) _then;
}

/// @nodoc
abstract class _$UpdateFromDbCopyWith<$Res> {
  factory _$UpdateFromDbCopyWith(
          _UpdateFromDb value, $Res Function(_UpdateFromDb) then) =
      __$UpdateFromDbCopyWithImpl<$Res>;
  $Res call({Map<int, MarginNote> marginNotes});
}

/// @nodoc
class __$UpdateFromDbCopyWithImpl<$Res>
    extends _$MarginNotesEventCopyWithImpl<$Res>
    implements _$UpdateFromDbCopyWith<$Res> {
  __$UpdateFromDbCopyWithImpl(
      _UpdateFromDb _value, $Res Function(_UpdateFromDb) _then)
      : super(_value, (v) => _then(v as _UpdateFromDb));

  @override
  _UpdateFromDb get _value => super._value as _UpdateFromDb;

  @override
  $Res call({
    Object marginNotes = freezed,
  }) {
    return _then(_UpdateFromDb(
      marginNotes: marginNotes == freezed
          ? _value.marginNotes
          : marginNotes as Map<int, MarginNote>,
    ));
  }
}

/// @nodoc
class _$_UpdateFromDb with DiagnosticableTreeMixin implements _UpdateFromDb {
  const _$_UpdateFromDb({@required this.marginNotes})
      : assert(marginNotes != null);

  @override
  final Map<int, MarginNote> marginNotes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MarginNotesEvent.updateFromDb(marginNotes: $marginNotes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MarginNotesEvent.updateFromDb'))
      ..add(DiagnosticsProperty('marginNotes', marginNotes));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _UpdateFromDb &&
            (identical(other.marginNotes, marginNotes) ||
                const DeepCollectionEquality()
                    .equals(other.marginNotes, marginNotes)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(marginNotes);

  @override
  _$UpdateFromDbCopyWith<_UpdateFromDb> get copyWith =>
      __$UpdateFromDbCopyWithImpl<_UpdateFromDb>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(Map<int, MarginNote> marginNotes),
    @required Result add(String text, Reference ref),
    @required Result delete(MarginNote marginNote),
    @required Result changeVolumeId(int volumeId),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return updateFromDb(marginNotes);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(Map<int, MarginNote> marginNotes),
    Result add(String text, Reference ref),
    Result delete(MarginNote marginNote),
    Result changeVolumeId(int volumeId),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateFromDb != null) {
      return updateFromDb(marginNotes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result changeVolumeId(_ChangeVolumeId value),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return updateFromDb(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result delete(_Delete value),
    Result changeVolumeId(_ChangeVolumeId value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateFromDb != null) {
      return updateFromDb(this);
    }
    return orElse();
  }
}

abstract class _UpdateFromDb implements MarginNotesEvent {
  const factory _UpdateFromDb({@required Map<int, MarginNote> marginNotes}) =
      _$_UpdateFromDb;

  Map<int, MarginNote> get marginNotes;
  _$UpdateFromDbCopyWith<_UpdateFromDb> get copyWith;
}

/// @nodoc
abstract class _$AddCopyWith<$Res> {
  factory _$AddCopyWith(_Add value, $Res Function(_Add) then) =
      __$AddCopyWithImpl<$Res>;
  $Res call({String text, Reference ref});
}

/// @nodoc
class __$AddCopyWithImpl<$Res> extends _$MarginNotesEventCopyWithImpl<$Res>
    implements _$AddCopyWith<$Res> {
  __$AddCopyWithImpl(_Add _value, $Res Function(_Add) _then)
      : super(_value, (v) => _then(v as _Add));

  @override
  _Add get _value => super._value as _Add;

  @override
  $Res call({
    Object text = freezed,
    Object ref = freezed,
  }) {
    return _then(_Add(
      text: text == freezed ? _value.text : text as String,
      ref: ref == freezed ? _value.ref : ref as Reference,
    ));
  }
}

/// @nodoc
class _$_Add with DiagnosticableTreeMixin implements _Add {
  const _$_Add({@required this.text, @required this.ref})
      : assert(text != null),
        assert(ref != null);

  @override
  final String text;
  @override
  final Reference ref;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MarginNotesEvent.add(text: $text, ref: $ref)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MarginNotesEvent.add'))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('ref', ref));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Add &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.ref, ref) ||
                const DeepCollectionEquality().equals(other.ref, ref)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(ref);

  @override
  _$AddCopyWith<_Add> get copyWith =>
      __$AddCopyWithImpl<_Add>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(Map<int, MarginNote> marginNotes),
    @required Result add(String text, Reference ref),
    @required Result delete(MarginNote marginNote),
    @required Result changeVolumeId(int volumeId),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return add(text, ref);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(Map<int, MarginNote> marginNotes),
    Result add(String text, Reference ref),
    Result delete(MarginNote marginNote),
    Result changeVolumeId(int volumeId),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(text, ref);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result changeVolumeId(_ChangeVolumeId value),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return add(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result delete(_Delete value),
    Result changeVolumeId(_ChangeVolumeId value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(this);
    }
    return orElse();
  }
}

abstract class _Add implements MarginNotesEvent {
  const factory _Add({@required String text, @required Reference ref}) = _$_Add;

  String get text;
  Reference get ref;
  _$AddCopyWith<_Add> get copyWith;
}

/// @nodoc
abstract class _$DeleteCopyWith<$Res> {
  factory _$DeleteCopyWith(_Delete value, $Res Function(_Delete) then) =
      __$DeleteCopyWithImpl<$Res>;
  $Res call({MarginNote marginNote});
}

/// @nodoc
class __$DeleteCopyWithImpl<$Res> extends _$MarginNotesEventCopyWithImpl<$Res>
    implements _$DeleteCopyWith<$Res> {
  __$DeleteCopyWithImpl(_Delete _value, $Res Function(_Delete) _then)
      : super(_value, (v) => _then(v as _Delete));

  @override
  _Delete get _value => super._value as _Delete;

  @override
  $Res call({
    Object marginNote = freezed,
  }) {
    return _then(_Delete(
      marginNote == freezed ? _value.marginNote : marginNote as MarginNote,
    ));
  }
}

/// @nodoc
class _$_Delete with DiagnosticableTreeMixin implements _Delete {
  const _$_Delete(this.marginNote) : assert(marginNote != null);

  @override
  final MarginNote marginNote;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MarginNotesEvent.delete(marginNote: $marginNote)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MarginNotesEvent.delete'))
      ..add(DiagnosticsProperty('marginNote', marginNote));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Delete &&
            (identical(other.marginNote, marginNote) ||
                const DeepCollectionEquality()
                    .equals(other.marginNote, marginNote)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(marginNote);

  @override
  _$DeleteCopyWith<_Delete> get copyWith =>
      __$DeleteCopyWithImpl<_Delete>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(Map<int, MarginNote> marginNotes),
    @required Result add(String text, Reference ref),
    @required Result delete(MarginNote marginNote),
    @required Result changeVolumeId(int volumeId),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return delete(marginNote);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(Map<int, MarginNote> marginNotes),
    Result add(String text, Reference ref),
    Result delete(MarginNote marginNote),
    Result changeVolumeId(int volumeId),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (delete != null) {
      return delete(marginNote);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result changeVolumeId(_ChangeVolumeId value),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return delete(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result delete(_Delete value),
    Result changeVolumeId(_ChangeVolumeId value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class _Delete implements MarginNotesEvent {
  const factory _Delete(MarginNote marginNote) = _$_Delete;

  MarginNote get marginNote;
  _$DeleteCopyWith<_Delete> get copyWith;
}

/// @nodoc
abstract class _$ChangeVolumeIdCopyWith<$Res> {
  factory _$ChangeVolumeIdCopyWith(
          _ChangeVolumeId value, $Res Function(_ChangeVolumeId) then) =
      __$ChangeVolumeIdCopyWithImpl<$Res>;
  $Res call({int volumeId});
}

/// @nodoc
class __$ChangeVolumeIdCopyWithImpl<$Res>
    extends _$MarginNotesEventCopyWithImpl<$Res>
    implements _$ChangeVolumeIdCopyWith<$Res> {
  __$ChangeVolumeIdCopyWithImpl(
      _ChangeVolumeId _value, $Res Function(_ChangeVolumeId) _then)
      : super(_value, (v) => _then(v as _ChangeVolumeId));

  @override
  _ChangeVolumeId get _value => super._value as _ChangeVolumeId;

  @override
  $Res call({
    Object volumeId = freezed,
  }) {
    return _then(_ChangeVolumeId(
      volumeId == freezed ? _value.volumeId : volumeId as int,
    ));
  }
}

/// @nodoc
class _$_ChangeVolumeId
    with DiagnosticableTreeMixin
    implements _ChangeVolumeId {
  const _$_ChangeVolumeId(this.volumeId) : assert(volumeId != null);

  @override
  final int volumeId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MarginNotesEvent.changeVolumeId(volumeId: $volumeId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MarginNotesEvent.changeVolumeId'))
      ..add(DiagnosticsProperty('volumeId', volumeId));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeVolumeId &&
            (identical(other.volumeId, volumeId) ||
                const DeepCollectionEquality()
                    .equals(other.volumeId, volumeId)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(volumeId);

  @override
  _$ChangeVolumeIdCopyWith<_ChangeVolumeId> get copyWith =>
      __$ChangeVolumeIdCopyWithImpl<_ChangeVolumeId>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result updateFromDb(Map<int, MarginNote> marginNotes),
    @required Result add(String text, Reference ref),
    @required Result delete(MarginNote marginNote),
    @required Result changeVolumeId(int volumeId),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return changeVolumeId(volumeId);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result updateFromDb(Map<int, MarginNote> marginNotes),
    Result add(String text, Reference ref),
    Result delete(MarginNote marginNote),
    Result changeVolumeId(int volumeId),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeVolumeId != null) {
      return changeVolumeId(volumeId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result updateFromDb(_UpdateFromDb value),
    @required Result add(_Add value),
    @required Result delete(_Delete value),
    @required Result changeVolumeId(_ChangeVolumeId value),
  }) {
    assert(updateFromDb != null);
    assert(add != null);
    assert(delete != null);
    assert(changeVolumeId != null);
    return changeVolumeId(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result updateFromDb(_UpdateFromDb value),
    Result add(_Add value),
    Result delete(_Delete value),
    Result changeVolumeId(_ChangeVolumeId value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeVolumeId != null) {
      return changeVolumeId(this);
    }
    return orElse();
  }
}

abstract class _ChangeVolumeId implements MarginNotesEvent {
  const factory _ChangeVolumeId(int volumeId) = _$_ChangeVolumeId;

  int get volumeId;
  _$ChangeVolumeIdCopyWith<_ChangeVolumeId> get copyWith;
}

/// @nodoc
class _$ChapterMarginNotesTearOff {
  const _$ChapterMarginNotesTearOff();

// ignore: unused_element
  _ChapterMarginNotes call(
      int volumeId, int book, int chapter, Map<int, MarginNote> marginNotes,
      {bool loaded}) {
    return _ChapterMarginNotes(
      volumeId,
      book,
      chapter,
      marginNotes,
      loaded: loaded,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $ChapterMarginNotes = _$ChapterMarginNotesTearOff();

/// @nodoc
mixin _$ChapterMarginNotes {
  int get volumeId;
  int get book;
  int get chapter;
  Map<int, MarginNote> get marginNotes;
  bool get loaded;

  $ChapterMarginNotesCopyWith<ChapterMarginNotes> get copyWith;
}

/// @nodoc
abstract class $ChapterMarginNotesCopyWith<$Res> {
  factory $ChapterMarginNotesCopyWith(
          ChapterMarginNotes value, $Res Function(ChapterMarginNotes) then) =
      _$ChapterMarginNotesCopyWithImpl<$Res>;
  $Res call(
      {int volumeId,
      int book,
      int chapter,
      Map<int, MarginNote> marginNotes,
      bool loaded});
}

/// @nodoc
class _$ChapterMarginNotesCopyWithImpl<$Res>
    implements $ChapterMarginNotesCopyWith<$Res> {
  _$ChapterMarginNotesCopyWithImpl(this._value, this._then);

  final ChapterMarginNotes _value;
  // ignore: unused_field
  final $Res Function(ChapterMarginNotes) _then;

  @override
  $Res call({
    Object volumeId = freezed,
    Object book = freezed,
    Object chapter = freezed,
    Object marginNotes = freezed,
    Object loaded = freezed,
  }) {
    return _then(_value.copyWith(
      volumeId: volumeId == freezed ? _value.volumeId : volumeId as int,
      book: book == freezed ? _value.book : book as int,
      chapter: chapter == freezed ? _value.chapter : chapter as int,
      marginNotes: marginNotes == freezed
          ? _value.marginNotes
          : marginNotes as Map<int, MarginNote>,
      loaded: loaded == freezed ? _value.loaded : loaded as bool,
    ));
  }
}

/// @nodoc
abstract class _$ChapterMarginNotesCopyWith<$Res>
    implements $ChapterMarginNotesCopyWith<$Res> {
  factory _$ChapterMarginNotesCopyWith(
          _ChapterMarginNotes value, $Res Function(_ChapterMarginNotes) then) =
      __$ChapterMarginNotesCopyWithImpl<$Res>;
  @override
  $Res call(
      {int volumeId,
      int book,
      int chapter,
      Map<int, MarginNote> marginNotes,
      bool loaded});
}

/// @nodoc
class __$ChapterMarginNotesCopyWithImpl<$Res>
    extends _$ChapterMarginNotesCopyWithImpl<$Res>
    implements _$ChapterMarginNotesCopyWith<$Res> {
  __$ChapterMarginNotesCopyWithImpl(
      _ChapterMarginNotes _value, $Res Function(_ChapterMarginNotes) _then)
      : super(_value, (v) => _then(v as _ChapterMarginNotes));

  @override
  _ChapterMarginNotes get _value => super._value as _ChapterMarginNotes;

  @override
  $Res call({
    Object volumeId = freezed,
    Object book = freezed,
    Object chapter = freezed,
    Object marginNotes = freezed,
    Object loaded = freezed,
  }) {
    return _then(_ChapterMarginNotes(
      volumeId == freezed ? _value.volumeId : volumeId as int,
      book == freezed ? _value.book : book as int,
      chapter == freezed ? _value.chapter : chapter as int,
      marginNotes == freezed
          ? _value.marginNotes
          : marginNotes as Map<int, MarginNote>,
      loaded: loaded == freezed ? _value.loaded : loaded as bool,
    ));
  }
}

/// @nodoc
class _$_ChapterMarginNotes
    with DiagnosticableTreeMixin
    implements _ChapterMarginNotes {
  const _$_ChapterMarginNotes(
      this.volumeId, this.book, this.chapter, this.marginNotes,
      {this.loaded})
      : assert(volumeId != null),
        assert(book != null),
        assert(chapter != null),
        assert(marginNotes != null);

  @override
  final int volumeId;
  @override
  final int book;
  @override
  final int chapter;
  @override
  final Map<int, MarginNote> marginNotes;
  @override
  final bool loaded;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChapterMarginNotes(volumeId: $volumeId, book: $book, chapter: $chapter, marginNotes: $marginNotes, loaded: $loaded)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChapterMarginNotes'))
      ..add(DiagnosticsProperty('volumeId', volumeId))
      ..add(DiagnosticsProperty('book', book))
      ..add(DiagnosticsProperty('chapter', chapter))
      ..add(DiagnosticsProperty('marginNotes', marginNotes))
      ..add(DiagnosticsProperty('loaded', loaded));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChapterMarginNotes &&
            (identical(other.volumeId, volumeId) ||
                const DeepCollectionEquality()
                    .equals(other.volumeId, volumeId)) &&
            (identical(other.book, book) ||
                const DeepCollectionEquality().equals(other.book, book)) &&
            (identical(other.chapter, chapter) ||
                const DeepCollectionEquality()
                    .equals(other.chapter, chapter)) &&
            (identical(other.marginNotes, marginNotes) ||
                const DeepCollectionEquality()
                    .equals(other.marginNotes, marginNotes)) &&
            (identical(other.loaded, loaded) ||
                const DeepCollectionEquality().equals(other.loaded, loaded)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(volumeId) ^
      const DeepCollectionEquality().hash(book) ^
      const DeepCollectionEquality().hash(chapter) ^
      const DeepCollectionEquality().hash(marginNotes) ^
      const DeepCollectionEquality().hash(loaded);

  @override
  _$ChapterMarginNotesCopyWith<_ChapterMarginNotes> get copyWith =>
      __$ChapterMarginNotesCopyWithImpl<_ChapterMarginNotes>(this, _$identity);
}

abstract class _ChapterMarginNotes implements ChapterMarginNotes {
  const factory _ChapterMarginNotes(
      int volumeId, int book, int chapter, Map<int, MarginNote> marginNotes,
      {bool loaded}) = _$_ChapterMarginNotes;

  @override
  int get volumeId;
  @override
  int get book;
  @override
  int get chapter;
  @override
  Map<int, MarginNote> get marginNotes;
  @override
  bool get loaded;
  @override
  _$ChapterMarginNotesCopyWith<_ChapterMarginNotes> get copyWith;
}

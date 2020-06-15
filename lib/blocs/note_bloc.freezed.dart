// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'note_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
Note _$NoteFromJson(Map<String, dynamic> json) {
  return _Note.fromJson(json);
}

class _$NoteTearOff {
  const _$NoteTearOff();

  _Note call({@required int id, @required NotusDocument doc}) {
    return _Note(
      id: id,
      doc: doc,
    );
  }
}

// ignore: unused_element
const $Note = _$NoteTearOff();

mixin _$Note {
  int get id;
  NotusDocument get doc;

  Map<String, dynamic> toJson();
  $NoteCopyWith<Note> get copyWith;
}

abstract class $NoteCopyWith<$Res> {
  factory $NoteCopyWith(Note value, $Res Function(Note) then) =
      _$NoteCopyWithImpl<$Res>;
  $Res call({int id, NotusDocument doc});
}

class _$NoteCopyWithImpl<$Res> implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._value, this._then);

  final Note _value;
  // ignore: unused_field
  final $Res Function(Note) _then;

  @override
  $Res call({
    Object id = freezed,
    Object doc = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as int,
      doc: doc == freezed ? _value.doc : doc as NotusDocument,
    ));
  }
}

abstract class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) then) =
      __$NoteCopyWithImpl<$Res>;
  @override
  $Res call({int id, NotusDocument doc});
}

class __$NoteCopyWithImpl<$Res> extends _$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(_Note _value, $Res Function(_Note) _then)
      : super(_value, (v) => _then(v as _Note));

  @override
  _Note get _value => super._value as _Note;

  @override
  $Res call({
    Object id = freezed,
    Object doc = freezed,
  }) {
    return _then(_Note(
      id: id == freezed ? _value.id : id as int,
      doc: doc == freezed ? _value.doc : doc as NotusDocument,
    ));
  }
}

@JsonSerializable()
class _$_Note with DiagnosticableTreeMixin implements _Note {
  const _$_Note({@required this.id, @required this.doc})
      : assert(id != null),
        assert(doc != null);

  factory _$_Note.fromJson(Map<String, dynamic> json) =>
      _$_$_NoteFromJson(json);

  @override
  final int id;
  @override
  final NotusDocument doc;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Note(id: $id, doc: $doc)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Note'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('doc', doc));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Note &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.doc, doc) ||
                const DeepCollectionEquality().equals(other.doc, doc)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(doc);

  @override
  _$NoteCopyWith<_Note> get copyWith =>
      __$NoteCopyWithImpl<_Note>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_NoteToJson(this);
  }
}

abstract class _Note implements Note {
  const factory _Note({@required int id, @required NotusDocument doc}) =
      _$_Note;

  factory _Note.fromJson(Map<String, dynamic> json) = _$_Note.fromJson;

  @override
  int get id;
  @override
  NotusDocument get doc;
  @override
  _$NoteCopyWith<_Note> get copyWith;
}

class _$NoteEventTearOff {
  const _$NoteEventTearOff();

  _LoadNote load() {
    return const _LoadNote();
  }

  _SaveNote save({Note note}) {
    return _SaveNote(
      note: note,
    );
  }

  _DeleteNote delete() {
    return const _DeleteNote();
  }
}

// ignore: unused_element
const $NoteEvent = _$NoteEventTearOff();

mixin _$NoteEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result save(Note note),
    @required Result delete(),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result save(Note note),
    Result delete(),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNote value),
    @required Result save(_SaveNote value),
    @required Result delete(_DeleteNote value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNote value),
    Result save(_SaveNote value),
    Result delete(_DeleteNote value),
    @required Result orElse(),
  });
}

abstract class $NoteEventCopyWith<$Res> {
  factory $NoteEventCopyWith(NoteEvent value, $Res Function(NoteEvent) then) =
      _$NoteEventCopyWithImpl<$Res>;
}

class _$NoteEventCopyWithImpl<$Res> implements $NoteEventCopyWith<$Res> {
  _$NoteEventCopyWithImpl(this._value, this._then);

  final NoteEvent _value;
  // ignore: unused_field
  final $Res Function(NoteEvent) _then;
}

abstract class _$LoadNoteCopyWith<$Res> {
  factory _$LoadNoteCopyWith(_LoadNote value, $Res Function(_LoadNote) then) =
      __$LoadNoteCopyWithImpl<$Res>;
}

class __$LoadNoteCopyWithImpl<$Res> extends _$NoteEventCopyWithImpl<$Res>
    implements _$LoadNoteCopyWith<$Res> {
  __$LoadNoteCopyWithImpl(_LoadNote _value, $Res Function(_LoadNote) _then)
      : super(_value, (v) => _then(v as _LoadNote));

  @override
  _LoadNote get _value => super._value as _LoadNote;
}

class _$_LoadNote with DiagnosticableTreeMixin implements _LoadNote {
  const _$_LoadNote();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteEvent.load()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'NoteEvent.load'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _LoadNote);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result save(Note note),
    @required Result delete(),
  }) {
    assert(load != null);
    assert(save != null);
    assert(delete != null);
    return load();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result save(Note note),
    Result delete(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNote value),
    @required Result save(_SaveNote value),
    @required Result delete(_DeleteNote value),
  }) {
    assert(load != null);
    assert(save != null);
    assert(delete != null);
    return load(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNote value),
    Result save(_SaveNote value),
    Result delete(_DeleteNote value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class _LoadNote implements NoteEvent {
  const factory _LoadNote() = _$_LoadNote;
}

abstract class _$SaveNoteCopyWith<$Res> {
  factory _$SaveNoteCopyWith(_SaveNote value, $Res Function(_SaveNote) then) =
      __$SaveNoteCopyWithImpl<$Res>;
  $Res call({Note note});

  $NoteCopyWith<$Res> get note;
}

class __$SaveNoteCopyWithImpl<$Res> extends _$NoteEventCopyWithImpl<$Res>
    implements _$SaveNoteCopyWith<$Res> {
  __$SaveNoteCopyWithImpl(_SaveNote _value, $Res Function(_SaveNote) _then)
      : super(_value, (v) => _then(v as _SaveNote));

  @override
  _SaveNote get _value => super._value as _SaveNote;

  @override
  $Res call({
    Object note = freezed,
  }) {
    return _then(_SaveNote(
      note: note == freezed ? _value.note : note as Note,
    ));
  }

  @override
  $NoteCopyWith<$Res> get note {
    if (_value.note == null) {
      return null;
    }
    return $NoteCopyWith<$Res>(_value.note, (value) {
      return _then(_value.copyWith(note: value));
    });
  }
}

class _$_SaveNote with DiagnosticableTreeMixin implements _SaveNote {
  const _$_SaveNote({this.note});

  @override
  final Note note;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteEvent.save(note: $note)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NoteEvent.save'))
      ..add(DiagnosticsProperty('note', note));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SaveNote &&
            (identical(other.note, note) ||
                const DeepCollectionEquality().equals(other.note, note)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(note);

  @override
  _$SaveNoteCopyWith<_SaveNote> get copyWith =>
      __$SaveNoteCopyWithImpl<_SaveNote>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result save(Note note),
    @required Result delete(),
  }) {
    assert(load != null);
    assert(save != null);
    assert(delete != null);
    return save(note);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result save(Note note),
    Result delete(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (save != null) {
      return save(note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNote value),
    @required Result save(_SaveNote value),
    @required Result delete(_DeleteNote value),
  }) {
    assert(load != null);
    assert(save != null);
    assert(delete != null);
    return save(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNote value),
    Result save(_SaveNote value),
    Result delete(_DeleteNote value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (save != null) {
      return save(this);
    }
    return orElse();
  }
}

abstract class _SaveNote implements NoteEvent {
  const factory _SaveNote({Note note}) = _$_SaveNote;

  Note get note;
  _$SaveNoteCopyWith<_SaveNote> get copyWith;
}

abstract class _$DeleteNoteCopyWith<$Res> {
  factory _$DeleteNoteCopyWith(
          _DeleteNote value, $Res Function(_DeleteNote) then) =
      __$DeleteNoteCopyWithImpl<$Res>;
}

class __$DeleteNoteCopyWithImpl<$Res> extends _$NoteEventCopyWithImpl<$Res>
    implements _$DeleteNoteCopyWith<$Res> {
  __$DeleteNoteCopyWithImpl(
      _DeleteNote _value, $Res Function(_DeleteNote) _then)
      : super(_value, (v) => _then(v as _DeleteNote));

  @override
  _DeleteNote get _value => super._value as _DeleteNote;
}

class _$_DeleteNote with DiagnosticableTreeMixin implements _DeleteNote {
  const _$_DeleteNote();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteEvent.delete()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'NoteEvent.delete'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _DeleteNote);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result save(Note note),
    @required Result delete(),
  }) {
    assert(load != null);
    assert(save != null);
    assert(delete != null);
    return delete();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result save(Note note),
    Result delete(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (delete != null) {
      return delete();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNote value),
    @required Result save(_SaveNote value),
    @required Result delete(_DeleteNote value),
  }) {
    assert(load != null);
    assert(save != null);
    assert(delete != null);
    return delete(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNote value),
    Result save(_SaveNote value),
    Result delete(_DeleteNote value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class _DeleteNote implements NoteEvent {
  const factory _DeleteNote() = _$_DeleteNote;
}

NoteManagerState _$NoteManagerStateFromJson(Map<String, dynamic> json) {
  return _Notes.fromJson(json);
}

class _$NoteManagerStateTearOff {
  const _$NoteManagerStateTearOff();

  _Notes call(List<Note> notes) {
    return _Notes(
      notes,
    );
  }
}

// ignore: unused_element
const $NoteManagerState = _$NoteManagerStateTearOff();

mixin _$NoteManagerState {
  List<Note> get notes;

  Map<String, dynamic> toJson();
  $NoteManagerStateCopyWith<NoteManagerState> get copyWith;
}

abstract class $NoteManagerStateCopyWith<$Res> {
  factory $NoteManagerStateCopyWith(
          NoteManagerState value, $Res Function(NoteManagerState) then) =
      _$NoteManagerStateCopyWithImpl<$Res>;
  $Res call({List<Note> notes});
}

class _$NoteManagerStateCopyWithImpl<$Res>
    implements $NoteManagerStateCopyWith<$Res> {
  _$NoteManagerStateCopyWithImpl(this._value, this._then);

  final NoteManagerState _value;
  // ignore: unused_field
  final $Res Function(NoteManagerState) _then;

  @override
  $Res call({
    Object notes = freezed,
  }) {
    return _then(_value.copyWith(
      notes: notes == freezed ? _value.notes : notes as List<Note>,
    ));
  }
}

abstract class _$NotesCopyWith<$Res>
    implements $NoteManagerStateCopyWith<$Res> {
  factory _$NotesCopyWith(_Notes value, $Res Function(_Notes) then) =
      __$NotesCopyWithImpl<$Res>;
  @override
  $Res call({List<Note> notes});
}

class __$NotesCopyWithImpl<$Res> extends _$NoteManagerStateCopyWithImpl<$Res>
    implements _$NotesCopyWith<$Res> {
  __$NotesCopyWithImpl(_Notes _value, $Res Function(_Notes) _then)
      : super(_value, (v) => _then(v as _Notes));

  @override
  _Notes get _value => super._value as _Notes;

  @override
  $Res call({
    Object notes = freezed,
  }) {
    return _then(_Notes(
      notes == freezed ? _value.notes : notes as List<Note>,
    ));
  }
}

@JsonSerializable()
class _$_Notes with DiagnosticableTreeMixin implements _Notes {
  _$_Notes(this.notes) : assert(notes != null);

  factory _$_Notes.fromJson(Map<String, dynamic> json) =>
      _$_$_NotesFromJson(json);

  @override
  final List<Note> notes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteManagerState(notes: $notes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NoteManagerState'))
      ..add(DiagnosticsProperty('notes', notes));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Notes &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(notes);

  @override
  _$NotesCopyWith<_Notes> get copyWith =>
      __$NotesCopyWithImpl<_Notes>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_NotesToJson(this);
  }
}

abstract class _Notes implements NoteManagerState {
  factory _Notes(List<Note> notes) = _$_Notes;

  factory _Notes.fromJson(Map<String, dynamic> json) = _$_Notes.fromJson;

  @override
  List<Note> get notes;
  @override
  _$NotesCopyWith<_Notes> get copyWith;
}

class _$NoteManagerEventTearOff {
  const _$NoteManagerEventTearOff();

  _LoadNotes load() {
    return const _LoadNotes();
  }

  _AddToNotes addNote(Note note) {
    return _AddToNotes(
      note,
    );
  }

  _UpdateNote updateNote(Note note) {
    return _UpdateNote(
      note,
    );
  }

  _RemoveFromNotes remove({@required int id}) {
    return _RemoveFromNotes(
      id: id,
    );
  }

  _SaveNotes save() {
    return const _SaveNotes();
  }
}

// ignore: unused_element
const $NoteManagerEvent = _$NoteManagerEventTearOff();

mixin _$NoteManagerEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result addNote(Note note),
    @required Result updateNote(Note note),
    @required Result remove(int id),
    @required Result save(),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result addNote(Note note),
    Result updateNote(Note note),
    Result remove(int id),
    Result save(),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotes value),
    @required Result addNote(_AddToNotes value),
    @required Result updateNote(_UpdateNote value),
    @required Result remove(_RemoveFromNotes value),
    @required Result save(_SaveNotes value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotes value),
    Result addNote(_AddToNotes value),
    Result updateNote(_UpdateNote value),
    Result remove(_RemoveFromNotes value),
    Result save(_SaveNotes value),
    @required Result orElse(),
  });
}

abstract class $NoteManagerEventCopyWith<$Res> {
  factory $NoteManagerEventCopyWith(
          NoteManagerEvent value, $Res Function(NoteManagerEvent) then) =
      _$NoteManagerEventCopyWithImpl<$Res>;
}

class _$NoteManagerEventCopyWithImpl<$Res>
    implements $NoteManagerEventCopyWith<$Res> {
  _$NoteManagerEventCopyWithImpl(this._value, this._then);

  final NoteManagerEvent _value;
  // ignore: unused_field
  final $Res Function(NoteManagerEvent) _then;
}

abstract class _$LoadNotesCopyWith<$Res> {
  factory _$LoadNotesCopyWith(
          _LoadNotes value, $Res Function(_LoadNotes) then) =
      __$LoadNotesCopyWithImpl<$Res>;
}

class __$LoadNotesCopyWithImpl<$Res>
    extends _$NoteManagerEventCopyWithImpl<$Res>
    implements _$LoadNotesCopyWith<$Res> {
  __$LoadNotesCopyWithImpl(_LoadNotes _value, $Res Function(_LoadNotes) _then)
      : super(_value, (v) => _then(v as _LoadNotes));

  @override
  _LoadNotes get _value => super._value as _LoadNotes;
}

class _$_LoadNotes with DiagnosticableTreeMixin implements _LoadNotes {
  const _$_LoadNotes();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteManagerEvent.load()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'NoteManagerEvent.load'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _LoadNotes);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result addNote(Note note),
    @required Result updateNote(Note note),
    @required Result remove(int id),
    @required Result save(),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return load();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result addNote(Note note),
    Result updateNote(Note note),
    Result remove(int id),
    Result save(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotes value),
    @required Result addNote(_AddToNotes value),
    @required Result updateNote(_UpdateNote value),
    @required Result remove(_RemoveFromNotes value),
    @required Result save(_SaveNotes value),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return load(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotes value),
    Result addNote(_AddToNotes value),
    Result updateNote(_UpdateNote value),
    Result remove(_RemoveFromNotes value),
    Result save(_SaveNotes value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class _LoadNotes implements NoteManagerEvent {
  const factory _LoadNotes() = _$_LoadNotes;
}

abstract class _$AddToNotesCopyWith<$Res> {
  factory _$AddToNotesCopyWith(
          _AddToNotes value, $Res Function(_AddToNotes) then) =
      __$AddToNotesCopyWithImpl<$Res>;
  $Res call({Note note});

  $NoteCopyWith<$Res> get note;
}

class __$AddToNotesCopyWithImpl<$Res>
    extends _$NoteManagerEventCopyWithImpl<$Res>
    implements _$AddToNotesCopyWith<$Res> {
  __$AddToNotesCopyWithImpl(
      _AddToNotes _value, $Res Function(_AddToNotes) _then)
      : super(_value, (v) => _then(v as _AddToNotes));

  @override
  _AddToNotes get _value => super._value as _AddToNotes;

  @override
  $Res call({
    Object note = freezed,
  }) {
    return _then(_AddToNotes(
      note == freezed ? _value.note : note as Note,
    ));
  }

  @override
  $NoteCopyWith<$Res> get note {
    if (_value.note == null) {
      return null;
    }
    return $NoteCopyWith<$Res>(_value.note, (value) {
      return _then(_value.copyWith(note: value));
    });
  }
}

class _$_AddToNotes with DiagnosticableTreeMixin implements _AddToNotes {
  const _$_AddToNotes(this.note) : assert(note != null);

  @override
  final Note note;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteManagerEvent.addNote(note: $note)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NoteManagerEvent.addNote'))
      ..add(DiagnosticsProperty('note', note));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _AddToNotes &&
            (identical(other.note, note) ||
                const DeepCollectionEquality().equals(other.note, note)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(note);

  @override
  _$AddToNotesCopyWith<_AddToNotes> get copyWith =>
      __$AddToNotesCopyWithImpl<_AddToNotes>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result addNote(Note note),
    @required Result updateNote(Note note),
    @required Result remove(int id),
    @required Result save(),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return addNote(note);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result addNote(Note note),
    Result updateNote(Note note),
    Result remove(int id),
    Result save(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (addNote != null) {
      return addNote(note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotes value),
    @required Result addNote(_AddToNotes value),
    @required Result updateNote(_UpdateNote value),
    @required Result remove(_RemoveFromNotes value),
    @required Result save(_SaveNotes value),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return addNote(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotes value),
    Result addNote(_AddToNotes value),
    Result updateNote(_UpdateNote value),
    Result remove(_RemoveFromNotes value),
    Result save(_SaveNotes value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (addNote != null) {
      return addNote(this);
    }
    return orElse();
  }
}

abstract class _AddToNotes implements NoteManagerEvent {
  const factory _AddToNotes(Note note) = _$_AddToNotes;

  Note get note;
  _$AddToNotesCopyWith<_AddToNotes> get copyWith;
}

abstract class _$UpdateNoteCopyWith<$Res> {
  factory _$UpdateNoteCopyWith(
          _UpdateNote value, $Res Function(_UpdateNote) then) =
      __$UpdateNoteCopyWithImpl<$Res>;
  $Res call({Note note});

  $NoteCopyWith<$Res> get note;
}

class __$UpdateNoteCopyWithImpl<$Res>
    extends _$NoteManagerEventCopyWithImpl<$Res>
    implements _$UpdateNoteCopyWith<$Res> {
  __$UpdateNoteCopyWithImpl(
      _UpdateNote _value, $Res Function(_UpdateNote) _then)
      : super(_value, (v) => _then(v as _UpdateNote));

  @override
  _UpdateNote get _value => super._value as _UpdateNote;

  @override
  $Res call({
    Object note = freezed,
  }) {
    return _then(_UpdateNote(
      note == freezed ? _value.note : note as Note,
    ));
  }

  @override
  $NoteCopyWith<$Res> get note {
    if (_value.note == null) {
      return null;
    }
    return $NoteCopyWith<$Res>(_value.note, (value) {
      return _then(_value.copyWith(note: value));
    });
  }
}

class _$_UpdateNote with DiagnosticableTreeMixin implements _UpdateNote {
  const _$_UpdateNote(this.note) : assert(note != null);

  @override
  final Note note;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteManagerEvent.updateNote(note: $note)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NoteManagerEvent.updateNote'))
      ..add(DiagnosticsProperty('note', note));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _UpdateNote &&
            (identical(other.note, note) ||
                const DeepCollectionEquality().equals(other.note, note)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(note);

  @override
  _$UpdateNoteCopyWith<_UpdateNote> get copyWith =>
      __$UpdateNoteCopyWithImpl<_UpdateNote>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result addNote(Note note),
    @required Result updateNote(Note note),
    @required Result remove(int id),
    @required Result save(),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return updateNote(note);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result addNote(Note note),
    Result updateNote(Note note),
    Result remove(int id),
    Result save(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateNote != null) {
      return updateNote(note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotes value),
    @required Result addNote(_AddToNotes value),
    @required Result updateNote(_UpdateNote value),
    @required Result remove(_RemoveFromNotes value),
    @required Result save(_SaveNotes value),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return updateNote(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotes value),
    Result addNote(_AddToNotes value),
    Result updateNote(_UpdateNote value),
    Result remove(_RemoveFromNotes value),
    Result save(_SaveNotes value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateNote != null) {
      return updateNote(this);
    }
    return orElse();
  }
}

abstract class _UpdateNote implements NoteManagerEvent {
  const factory _UpdateNote(Note note) = _$_UpdateNote;

  Note get note;
  _$UpdateNoteCopyWith<_UpdateNote> get copyWith;
}

abstract class _$RemoveFromNotesCopyWith<$Res> {
  factory _$RemoveFromNotesCopyWith(
          _RemoveFromNotes value, $Res Function(_RemoveFromNotes) then) =
      __$RemoveFromNotesCopyWithImpl<$Res>;
  $Res call({int id});
}

class __$RemoveFromNotesCopyWithImpl<$Res>
    extends _$NoteManagerEventCopyWithImpl<$Res>
    implements _$RemoveFromNotesCopyWith<$Res> {
  __$RemoveFromNotesCopyWithImpl(
      _RemoveFromNotes _value, $Res Function(_RemoveFromNotes) _then)
      : super(_value, (v) => _then(v as _RemoveFromNotes));

  @override
  _RemoveFromNotes get _value => super._value as _RemoveFromNotes;

  @override
  $Res call({
    Object id = freezed,
  }) {
    return _then(_RemoveFromNotes(
      id: id == freezed ? _value.id : id as int,
    ));
  }
}

class _$_RemoveFromNotes
    with DiagnosticableTreeMixin
    implements _RemoveFromNotes {
  const _$_RemoveFromNotes({@required this.id}) : assert(id != null);

  @override
  final int id;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteManagerEvent.remove(id: $id)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NoteManagerEvent.remove'))
      ..add(DiagnosticsProperty('id', id));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _RemoveFromNotes &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(id);

  @override
  _$RemoveFromNotesCopyWith<_RemoveFromNotes> get copyWith =>
      __$RemoveFromNotesCopyWithImpl<_RemoveFromNotes>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result addNote(Note note),
    @required Result updateNote(Note note),
    @required Result remove(int id),
    @required Result save(),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return remove(id);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result addNote(Note note),
    Result updateNote(Note note),
    Result remove(int id),
    Result save(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (remove != null) {
      return remove(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotes value),
    @required Result addNote(_AddToNotes value),
    @required Result updateNote(_UpdateNote value),
    @required Result remove(_RemoveFromNotes value),
    @required Result save(_SaveNotes value),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return remove(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotes value),
    Result addNote(_AddToNotes value),
    Result updateNote(_UpdateNote value),
    Result remove(_RemoveFromNotes value),
    Result save(_SaveNotes value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (remove != null) {
      return remove(this);
    }
    return orElse();
  }
}

abstract class _RemoveFromNotes implements NoteManagerEvent {
  const factory _RemoveFromNotes({@required int id}) = _$_RemoveFromNotes;

  int get id;
  _$RemoveFromNotesCopyWith<_RemoveFromNotes> get copyWith;
}

abstract class _$SaveNotesCopyWith<$Res> {
  factory _$SaveNotesCopyWith(
          _SaveNotes value, $Res Function(_SaveNotes) then) =
      __$SaveNotesCopyWithImpl<$Res>;
}

class __$SaveNotesCopyWithImpl<$Res>
    extends _$NoteManagerEventCopyWithImpl<$Res>
    implements _$SaveNotesCopyWith<$Res> {
  __$SaveNotesCopyWithImpl(_SaveNotes _value, $Res Function(_SaveNotes) _then)
      : super(_value, (v) => _then(v as _SaveNotes));

  @override
  _SaveNotes get _value => super._value as _SaveNotes;
}

class _$_SaveNotes with DiagnosticableTreeMixin implements _SaveNotes {
  const _$_SaveNotes();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteManagerEvent.save()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'NoteManagerEvent.save'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _SaveNotes);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result addNote(Note note),
    @required Result updateNote(Note note),
    @required Result remove(int id),
    @required Result save(),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return save();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result addNote(Note note),
    Result updateNote(Note note),
    Result remove(int id),
    Result save(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (save != null) {
      return save();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotes value),
    @required Result addNote(_AddToNotes value),
    @required Result updateNote(_UpdateNote value),
    @required Result remove(_RemoveFromNotes value),
    @required Result save(_SaveNotes value),
  }) {
    assert(load != null);
    assert(addNote != null);
    assert(updateNote != null);
    assert(remove != null);
    assert(save != null);
    return save(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotes value),
    Result addNote(_AddToNotes value),
    Result updateNote(_UpdateNote value),
    Result remove(_RemoveFromNotes value),
    Result save(_SaveNotes value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (save != null) {
      return save(this);
    }
    return orElse();
  }
}

abstract class _SaveNotes implements NoteManagerEvent {
  const factory _SaveNotes() = _$_SaveNotes;
}

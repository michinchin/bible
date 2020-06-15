import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tec_util/tec_util.dart' as tec;

import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';

part 'note_bloc.freezed.dart';
part 'note_bloc.g.dart';

const notesPref = 'tec_notesPref';

///
/// NoteBloc:
/// manage a single note
///

class NoteBloc extends Bloc<NoteEvent, Note> {
  final int id;

  NoteBloc(this.id) {
    _nListener = NoteManagerBloc.shared.listen(_noteListener);
  }

  StreamSubscription<NoteManagerState> _nListener;

  void _noteListener(NoteManagerState s) {
    final note = s.notes?.firstWhere((n) => n.id == id, orElse: () => null);

    if (note != null) {
      save(note: note);
    }
  }

  @override
  Future<void> close() {
    _nListener.cancel();
    return super.close();
  }

  @override
  Note get initialState {
    final delta = Delta()..insert('\n');
    final doc = NotusDocument.fromDelta(delta);
    return Note(id: id, doc: doc);
  }

  @override
  Stream<Note> mapEventToState(NoteEvent event) async* {
    final newState = event.when(load: _load, save: _save, delete: _delete);
    assert(newState != null);
    if (newState == null) {
      assert(false);
      debugPrint('Note not updated');
      yield state;
    } else {
      debugPrint('Note ${state.id} updated');
      yield newState;
    }
  }

  ///
  /// Events
  ///

  Note _load() {
    final id = state.id;
    final notesEncoded = _grabNotes();
    if (id != null && id < notesEncoded.length) {
      final doc = notesEncoded[id].doc;
      return Note(id: id, doc: doc);
    }
    return state;
  }

  Note _save(Note note) {
    final id = note?.id ?? state.id;
    final doc = note?.doc ?? state.doc;
    final oldNotes = _grabNotes();
    final modNotes = List<Note>.from(oldNotes);

    if (id != null && id < modNotes.length) {
      modNotes[id] = modNotes[id].copyWith(doc: doc);
    } else {
      modNotes.add(Note(id: id, doc: doc));
    }
    tec.Prefs.shared.setStringList(
        notesPref, modNotes.map((n) => jsonEncode(n.doc)).toList());

    final newState = state.copyWith(doc: doc);
    NoteManagerBloc.shared.updateNote(newState);
    return newState;
  }

  Note _delete() {
    NoteManagerBloc.shared.remove(id);
    return state;
  }

  ///
  /// Private Functions
  ///

  List<Note> _grabNotes() => NoteManagerBloc.shared.state.notes ?? [];

  ///
  /// Helpers
  ///

  void load() => add(const NoteEvent.load());
  void save({Note note}) => add(NoteEvent.save(note: note));
  void delete() => add(const NoteEvent.delete());
}

@freezed
abstract class Note with _$Note {
  const factory Note({@required int id, @required NotusDocument doc}) = _Note;

  /// fromJson
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}

@freezed
abstract class NoteEvent with _$NoteEvent {
  const factory NoteEvent.load() = _LoadNote;
  const factory NoteEvent.save({Note note}) = _SaveNote;
  const factory NoteEvent.delete() = _DeleteNote;
}

///
/// Note Manager Bloc:
/// manages all the notes saved
///

class NoteManagerBloc extends Bloc<NoteManagerEvent, NoteManagerState> {
  static final shared = NoteManagerBloc._shared();
  factory NoteManagerBloc() => shared ?? NoteManagerBloc();
  NoteManagerBloc._shared();

  @override
  NoteManagerState get initialState => NoteManagerState([]);

  @override
  Future<void> close() {
    shared.close();
    return super.close();
  }

  @override
  Stream<NoteManagerState> mapEventToState(NoteManagerEvent event) async* {
    final newState = event.when(
        load: _load,
        addNote: _addNote,
        updateNote: _updateNote,
        remove: _remove,
        save: _save);
    assert(newState != null);
    if (newState != null) {
      yield newState;
    } else {
      yield state;
    }
  }

  NoteManagerState _addNote(Note note) {
    final noteList = List<Note>.from(state.notes)..add(note);
    return state.copyWith(notes: noteList);
  }

  NoteManagerState _updateNote(Note note) {
    final noteList = List<Note>.from(state.notes);
    final idx = noteList.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      noteList[idx] = note;
    } else {
      noteList.add(note);
    }
    return state.copyWith(notes: noteList);
  }

  NoteManagerState _load() {
    final notes = _grabNotesFromPrefs();
    final noteList = <Note>[];
    for (var i = 0; i < notes.length; i++) {
      final content = notes[i];
      final doc = NotusDocument.fromJson(tec.as<List>(jsonDecode(content)));
      noteList.add(Note(id: i, doc: doc));
    }
    return state.copyWith(notes: noteList);
  }

  NoteManagerState _remove(int id) {
    final noteList = List<Note>.from(state.notes)
      ..removeWhere((n) => n.id == id);
    for (var i = 0; i < noteList.length; i++) {
      noteList[i] = noteList[i].copyWith(id: i);
    }
    return state.copyWith(notes: noteList);
  }

  NoteManagerState _save() {
    final noteList = List<Note>.from(state.notes);
    final jsonNotes =
        List<String>.from(noteList.map((n) => jsonEncode(n.doc)).toList());
    tec.Prefs.shared.setStringList(notesPref, jsonNotes);
    return state;
  }

  List<String> _grabNotesFromPrefs() =>
      tec.Prefs.shared.getStringList(notesPref) ?? [];

  void load() => add(const NoteManagerEvent.load());
  void addNote(Note note) => add(NoteManagerEvent.addNote(note));
  void remove(int id) => add(NoteManagerEvent.remove(id: id));
  void save() => add(const NoteManagerEvent.save());
  void updateNote(Note note) => add(NoteManagerEvent.updateNote(note));
}

@freezed
abstract class NoteManagerState with _$NoteManagerState {
  factory NoteManagerState(List<Note> notes) = _Notes;

  // fromJson
  factory NoteManagerState.fromJson(Map<String, dynamic> json) =>
      _$NoteManagerStateFromJson(json);
}

@freezed
abstract class NoteManagerEvent with _$NoteManagerEvent {
  const factory NoteManagerEvent.load() = _LoadNotes;
  const factory NoteManagerEvent.addNote(Note note) = _AddToNotes;
  const factory NoteManagerEvent.updateNote(Note note) = _UpdateNote;
  const factory NoteManagerEvent.remove({@required int id}) = _RemoveFromNotes;
  const factory NoteManagerEvent.save() = _SaveNotes;
}

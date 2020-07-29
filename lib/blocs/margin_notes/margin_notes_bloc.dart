import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/app_settings.dart';
import 'margin_note.dart';

part 'margin_notes_bloc.freezed.dart';

@freezed
abstract class MarginNotesEvent with _$MarginNotesEvent {
  const factory MarginNotesEvent.updateFromDb({@required Map<int, MarginNote> marginNotes}) =
      _UpdateFromDb;
  const factory MarginNotesEvent.add({@required String text, @required Reference ref}) = _Add;
  const factory MarginNotesEvent.delete(MarginNote marginNote) = _Delete;
}

@freezed
abstract class ChapterMarginNotes with _$ChapterMarginNotes {
  const factory ChapterMarginNotes(
          int volume, int book, int chapter, Map<int, MarginNote> marginNotes, {bool loaded}) =
      _ChapterMarginNotes;
}

extension ChapterMarginNotesExt on ChapterMarginNotes {
  bool hasMarginNoteForVerse(int verse) {
    return marginNotes.containsKey(verse);
  }

  MarginNote marginNoteForVerse(int verse) {
    return marginNotes[verse];
  }
}

class ChapterMarginNotesBloc extends tec.SafeBloc<MarginNotesEvent, ChapterMarginNotes> {
  final int volume;
  final int book;
  final int chapter;
  final bool loaded;
  StreamSubscription<UserDbChange> _userDbChangeSubscription;

  ChapterMarginNotesBloc(
      {@required this.volume, @required this.book, @required this.chapter, this.loaded = false}) {
    _initUserContent();

    // Start listening for changes to the db.
    _userDbChangeSubscription =
        AppSettings.shared.userAccount.userDbChangeStream.listen(_userDbChangeListener);
  }

  @override
  Future<void> close() {
    _userDbChangeSubscription?.cancel();
    _userDbChangeSubscription = null;
    return super.close();
  }

  void _userDbChangeListener(UserDbChange change) {
    var reload = false;

    if (change != null && change.includesItemType(UserItemType.marginNote)) {
      if (change.type == UserDbChangeType.itemAdded &&
          change.after?.volumeId == volume &&
          change.after?.book == book &&
          change.after?.chapter == chapter) {
        reload = true;
      } else if (change.type == UserDbChangeType.itemDeleted &&
          change.before?.volumeId == volume &&
          change.before?.book == book &&
          change.before?.chapter == chapter) {
        reload = true;
      } else if (change.type == UserDbChangeType.multipleChanges) {
        reload = true;
      }
    }

    if (reload) {
      // margin notes for this chapter changed, reload...
      debugPrint('new margin notes for chapter $chapter');
      _initUserContent();
    }
  }

  @override
  ChapterMarginNotes get initialState =>
      ChapterMarginNotes(volume, book, chapter, <int, MarginNote>{}, loaded: false);

  @override
  Stream<ChapterMarginNotes> mapEventToState(MarginNotesEvent event) async* {
    final newState = event.when(add: _add, delete: _delete, updateFromDb: _updateFromDb);
    yield newState;
  }

  ChapterMarginNotes _add(String text, Reference ref) {
    final newMap = Map<int, MarginNote>.from(state.marginNotes);
    final marginNote =
        MarginNote(volume: volume, book: book, chapter: chapter, verse: ref.verse, text: text);
    newMap[ref.verse] = marginNote;
    return ChapterMarginNotes(volume, book, chapter, newMap, loaded: true);
  }

  Future<void> _deleteMarginNote(MarginNote marginNote) async {
    await AppSettings.shared.userAccount.userDb.deleteItem(marginNote);
  }

  ChapterMarginNotes _delete(MarginNote marginNote) {
    final deleteMarginNote = state.marginNotes.remove(marginNote);
    _deleteMarginNote(deleteMarginNote);
    return ChapterMarginNotes(volume, book, chapter, Map.from(state.marginNotes), loaded: true);
  }

  ChapterMarginNotes _updateFromDb(Map<int, MarginNote> marginNotes) {
    return ChapterMarginNotes(volume, book, chapter, marginNotes, loaded: true);
  }

  Future<void> _initUserContent() async {
    final uc = await AppSettings.shared.userAccount.userDb
        .getItemsWithVBC(volume, book, chapter, ofTypes: [UserItemType.marginNote]);

    final marginNotes = <int, MarginNote>{};

    for (final ui in uc) {
      marginNotes[ui.verse] = MarginNote.from(ui);
    }

    add(MarginNotesEvent.updateFromDb(marginNotes: marginNotes));
  }
}

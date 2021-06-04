import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart';

import '../../models/app_settings.dart';
import 'margin_note.dart';

class ChapterMarginNotes extends Equatable {
  final int volumeId;
  final int book;
  final int chapter;
  final Map<int, MarginNote> marginNotes;
  final bool loaded;

  const ChapterMarginNotes(this.volumeId, this.book, this.chapter, this.marginNotes,
      {this.loaded = false});

  @override
  List<Object> get props => [volumeId, book, chapter, loaded, marginNotes];

  bool hasMarginNoteForVerse(int verse) {
    return marginNotes.containsKey(verse);
  }

  MarginNote marginNoteForVerse(int verse) {
    return marginNotes[verse];
  }
}

class ChapterMarginNotesBloc extends Cubit<ChapterMarginNotes> {
  ChapterMarginNotesBloc({
    @required int volumeId,
    @required int book,
    @required int chapter,
  }) : super(ChapterMarginNotes(volumeId, book, chapter, const <int, MarginNote>{})) {
    _initUserContent();

    // Start listening for changes to the db.
    _userDbChangeSubscription =
        AppSettings.shared.userAccount.userDbChangeStream.listen(_userDbChangeListener);
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _userDbChangeSubscription?.cancel();
    _userDbChangeSubscription = null;
    return super.close();
  }

  StreamSubscription<UserDbChange> _userDbChangeSubscription;
  bool _isClosed = false;

  void _userDbChangeListener(UserDbChange change) {
    var reload = false;

    if (change != null && change.includesItemType(UserItemType.marginNote)) {
      if (change.type == UserDbChangeType.itemAdded &&
          change.after?.volumeId == state.volumeId &&
          change.after?.book == state.book &&
          change.after?.chapter == state.chapter) {
        reload = true;
      } else if (change.type == UserDbChangeType.itemDeleted &&
          change.before?.volumeId == state.volumeId &&
          change.before?.book == state.book &&
          change.before?.chapter == state.chapter) {
        reload = true;
      } else if (change.type == UserDbChangeType.multipleChanges) {
        reload = true;
      }
    }

    if (reload) {
      // margin notes for this chapter changed, reload...
      dmPrint('new margin notes for chapter ${state.chapter}');
      _initUserContent();
    }
  }

  Future<void> _initUserContent() async {
    final userItems = await AppSettings.shared.userAccount.userDb.getItemsWithVBC(
        state.volumeId, state.book, state.chapter,
        ofTypes: [UserItemType.marginNote]);

    // If this bloc was closed during the async await, just return.
    if (_isClosed) return;

    final marginNotes = <int, MarginNote>{
      for (final ui in userItems) ui.verse: MarginNote.from(ui)
    };
    emit(ChapterMarginNotes(state.volumeId, state.book, state.chapter, marginNotes, loaded: true));
  }

  void add(String text, int verse) {
    assert(text != null && text.isNotEmpty && verse != null);
    final newMap = Map<int, MarginNote>.from(state.marginNotes);
    final marginNote = MarginNote(
        volume: state.volumeId, book: state.book, chapter: state.chapter, verse: verse, text: text);
    newMap[verse] = marginNote;
    emit(ChapterMarginNotes(state.volumeId, state.book, state.chapter, newMap, loaded: true));
  }

  void delete(MarginNote marginNote) {
    final newMap = Map<int, MarginNote>.from(state.marginNotes);
    final deletedMarginNote = newMap.remove(marginNote?.verse);
    if (deletedMarginNote != null) {
      AppSettings.shared.userAccount.userDb.deleteItem(marginNote);
      emit(ChapterMarginNotes(
          state.volumeId, state.book, state.chapter, Map.from(state.marginNotes),
          loaded: true));
    }
  }

  void changeVolumeId(int volumeId) {
    _initUserContent();
    emit(ChapterMarginNotes(volumeId, state.book, state.chapter, const {}));
  }
}

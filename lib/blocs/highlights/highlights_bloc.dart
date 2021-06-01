import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/app_settings.dart';
import '../../models/color_utils.dart';
import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

class ChapterHighlights extends Equatable {
  final int volumeId;
  final int book;
  final int chapter;
  final List<Highlight> highlights;
  final bool loaded;

  const ChapterHighlights(this.volumeId, this.book, this.chapter, this.highlights,
      {this.loaded = false});

  Highlight highlightForVerse(int verse, {int andWord}) {
    for (final highlight in highlights.reversed) {
      if (highlight.ref.includesVerse(verse, andWord: andWord)) return highlight;
    }
    return null;
  }

  @override
  List<Object> get props => [volumeId, book, chapter, loaded, highlights];

  Iterable<Highlight> highlightsForVerse(
    int verse, {
    int startWord = Reference.minWord,
    int endWord = Reference.maxWord,
  }) {
    assert(startWord != null && endWord != null);

    // We keep the list sorted by each highlight's start word for the current verse.
    final hls = <Highlight>[];

    for (final hl in highlights) {
      if (startWord > endWord) break;

      final start = hl.ref.startWordForVerse(verse);
      if (start == null || start > endWord) continue;
      if (start < startWord) {
        final end = hl.ref.endWordForVerse(verse);
        if (end < startWord) continue;
      }

      // Insert the highlight in sorted order.
      hls.insert(
          lowerBound<Highlight>(hls, hl,
              compare: (a, b) =>
                  a.ref.startWordForVerse(verse).compareTo(b.ref.startWordForVerse(verse))),
          hl);
    }

    return hls;
  }
}

class Highlight extends Equatable {
  final HighlightType highlightType;
  final int color;
  final Reference ref;

  const Highlight(this.highlightType, this.color, this.ref);

  Highlight copyWith({HighlightType highlightType, int color, Reference ref}) => Highlight(
        highlightType ?? this.highlightType,
        color ?? this.color,
        ref ?? this.ref,
      );

  factory Highlight.from(UserItem ui) {
    final ref = Reference(
      volume: ui.volumeId,
      book: ui.book,
      chapter: ui.chapter,
      verse: ui.verse,
      word: ui.wordBegin,
      endWord: (ui.wordEnd <= 0) ? Reference.maxWord : ui.wordEnd,
    );

    final highlightType =
        (ui.color == 5 || (ui.color >> 24 > 0)) ? HighlightType.underline : HighlightType.highlight;

    final color =
        (ui.color <= 5) ? defaultColorIntForIndex(ui.color) : 0xFF000000 | (ui.color & 0xFFFFFF);

    return Highlight(
      highlightType,
      color,
      ref,
    );
  }

  @override
  List<Object> get props => [highlightType, ref, color];
}

enum HighlightMode { trial, save }

class ChapterHighlightsBloc extends Cubit<ChapterHighlights> {
  ChapterHighlightsBloc({
    @required int volumeId,
    @required int book,
    @required int chapter,
  }) : super(ChapterHighlights(volumeId, book, chapter, const [], loaded: false)) {
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

    if (change != null && change.includesItemType(UserItemType.highlight)) {
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
      dmPrint('new hls for chapter ${state.chapter}');
      _initUserContent();
    }
  }

  Future<void> _initUserContent() async {
    final userItems = await AppSettings.shared.userAccount.userDb.getItemsWithVBC(
        state.volumeId, state.book, state.chapter,
        ofTypes: [UserItemType.highlight]);

    // If this bloc was closed during the async await, just return.
    if (_isClosed) return;

    // Sort the highlight user items by modified date, oldest to most recent.
    userItems.sort((a, b) => a?.modified?.compareTo(b.modified) ?? 1);

    // Map the user item list to a Highlight list.
    final hls = userItems.map((e) => Highlight.from(e)).toList();

    // _printHighlights(hls, withTitle: 'HIGHLIGHTS IMPORTED FROM DB:');

    var newList = hls;

    // This will make sure there are no overlapping highlights.
    if (hls.isNotEmpty) {
      newList = state.highlights;
      for (final hl in hls) {
        newList = newList.copySubtracting(hl.ref)..add(hl);
      }
    }

    emit(ChapterHighlights(state.volumeId, state.book, state.chapter, newList, loaded: true));
  }

  void add(HighlightType type, int color, Reference ref, HighlightMode mode) {
    assert(type != HighlightType.clear);
    final newList = state.highlights.copySubtracting(ref)..add(Highlight(type, color, ref));
    if (mode == HighlightMode.save) {
      // _printHighlights(state.highlights, withTitle: 'before:');
      // _printHighlights(newList, withTitle: 'after:');
      _saveHighlightsToDb(ref.verses.toList(), newList, state.volumeId, state.book, state.chapter);
    }
    emit(ChapterHighlights(state.volumeId, state.book, state.chapter, newList, loaded: true));
  }

  void clear(Reference ref, HighlightMode mode) {
    final newList = state.highlights.copySubtracting(ref);
    if (mode == HighlightMode.trial) {
      // need to reset the hls...
      _initUserContent();
    } else {
      // _printHighlights(state.highlights, withTitle: 'before:');
      // _printHighlights(newList, withTitle: 'after:');
      _saveHighlightsToDb(ref.verses.toList(), newList, state.volumeId, state.book, state.chapter);
    }
    emit(ChapterHighlights(state.volumeId, state.book, state.chapter, newList, loaded: true));
  }

  void changeVolumeId(int volumeId) {
    emit(ChapterHighlights(volumeId, state.book, state.chapter, const [], loaded: false));
    _initUserContent();
  }
}

Future<void> _saveHighlightsToDb(
    List<int> verses, List<Highlight> hls, int volumeId, int book, int chapter) async {
  final userItems = await AppSettings.shared.userAccount.userDb
      .getItemsWithVBC(volumeId, book, chapter, ofTypes: [UserItemType.highlight]);

  // remove any existing hls in this reference range...
  for (final ui in userItems) {
    if (verses.contains(ui.verse)) {
      // dmPrint('Removing highlight from DB: ${Highlight.from(ui).ref}');
      await AppSettings.shared.userAccount.userDb.deleteItem(ui);
    }
  }

  // add any hls still in this reference range...
  for (final hl in hls) {
    for (final v in hl.ref.verses) {
      if (verses.contains(v)) {
        final wordBegin = hl.ref.startWordForVerse(v);

        // create a new UserItem for this hl
        final ui = UserItem(
          type: UserItemType.highlight.index,
          volumeId: volumeId,
          book: book,
          chapter: chapter,
          color: (hl.color & 0xFFFFFF) +
              ((hl.highlightType == HighlightType.underline) ? 0x1000000 : 0),
          verse: v,
          verseEnd: v,
          // Since `wordBegin == 1` means the same thing as `wordBegin == 0`, and `wordBegin == 0`
          // is handled more efficiently, always turn a 1 into a 0.
          wordBegin: wordBegin == 1 ? 0 : wordBegin,
          wordEnd: hl.ref.endWordForVerse(v),
          created: dbIntFromDateTime(DateTime.now()),
        );

        await AppSettings.shared.userAccount.userDb.saveItem(ui);
        // dmPrint('Added highlight to DB: ${hl.ref}');
      }
    }
  }
}

extension HighlightsBlocExtOnListOfHighlight on List<Highlight> {
  List<Highlight> copySubtracting(Reference ref) {
    return expand<Highlight>(
      (highlight) =>
          highlight.ref.subtracting(ref).map<Highlight>((e) => highlight.copyWith(ref: e)),
    ).toList();
  }
}

// ignore: unused_element
void _printHighlights(List<Highlight> hls, {String withTitle}) {
  if (kDebugMode) {
    dmPrint('');
    dmPrint('-----------------------------------------------------');
    if (withTitle?.isNotEmpty ?? false) dmPrint(withTitle);
    dmPrint('');
    for (final hl in hls) {
      dmPrint(hl.ref);
    }
    dmPrint('');
    dmPrint('-----------------------------------------------------\n');
    dmPrint('');
  }
}

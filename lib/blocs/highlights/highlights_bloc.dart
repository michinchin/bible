import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/app_settings.dart';
import '../../models/color_utils.dart';
import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

part 'highlights_bloc.freezed.dart';

@freezed
abstract class ChapterHighlights with _$ChapterHighlights {
  const factory ChapterHighlights(int volumeId, int book, int chapter, List<Highlight> highlights,
      {bool loaded}) = _ChapterHighlights;
}

extension ChapterHighlightsExt on ChapterHighlights {
  Highlight highlightForVerse(int verse, {int andWord}) {
    for (final highlight in highlights.reversed) {
      if (highlight.ref.includesVerse(verse, andWord: andWord)) return highlight;
    }
    return null;
  }

  Iterable<Highlight> highlightsForVerse(int verse,
      {int startWord = Reference.minWord, int endWord = Reference.maxWord}) {
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

@freezed
abstract class Highlight with _$Highlight {
  const factory Highlight(
    HighlightType highlightType,
    int color,
    Reference ref,
  ) = _Highlight;

  factory Highlight.from(UserItem ui) {
    final ref = Reference(
      volume: ui.volumeId,
      book: ui.book,
      chapter: ui.chapter,
      verse: ui.verse,
      word: ui.wordBegin,
      endWord: (ui.wordEnd <= Reference.minWord) ? Reference.maxWord : ui.wordEnd,
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
}

enum HighlightMode { trial, save }

@freezed
abstract class HighlightEvent with _$HighlightEvent {
  const factory HighlightEvent.updateFromDb({@required List<Highlight> hls}) = _UpdateFromDb;
  const factory HighlightEvent.add(
      {@required HighlightType type,
      @required int color,
      @required Reference ref,
      @required HighlightMode mode}) = _Add;
  const factory HighlightEvent.clear(Reference ref, HighlightMode mode) = _Clear;
  const factory HighlightEvent.changeVolumeId(int volumeId) = _ChangeVolumeId;
}

class ChapterHighlightsBloc extends Bloc<HighlightEvent, ChapterHighlights> {
  int volumeId;
  final int book;
  final int chapter;
  final bool loaded;
  StreamSubscription<UserDbChange> _userDbChangeSubscription;

  ChapterHighlightsBloc({
    @required this.volumeId,
    @required this.book,
    @required this.chapter,
    this.loaded = false,
  }) : super(ChapterHighlights(volumeId, book, chapter, [], loaded: false)) {
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

    if (change != null && change.includesItemType(UserItemType.highlight)) {
      if (change.type == UserDbChangeType.itemAdded &&
          change.after?.volumeId == volumeId &&
          change.after?.book == book &&
          change.after?.chapter == chapter) {
        reload = true;
      } else if (change.type == UserDbChangeType.itemDeleted &&
          change.before?.volumeId == volumeId &&
          change.before?.book == book &&
          change.before?.chapter == chapter) {
        reload = true;
      } else if (change.type == UserDbChangeType.multipleChanges) {
        reload = true;
      }
    }

    if (reload) {
      // margin notes for this chapter changed, reload...
      dmPrint('new hls for chapter $chapter');
      _initUserContent();
    }
  }

  Future<void> _initUserContent() async {
    final uc = await AppSettings.shared.userAccount.userDb
        .getItemsWithVBC(volumeId, book, chapter, ofTypes: [UserItemType.highlight]);

    if (uc.isNotEmpty) {
      // We keep the highlights sorted by modified date with most recent at the bottom.
      uc.sort((a, b) => a?.modified?.compareTo(b.modified) ?? 1);
    }

    final hls = <Highlight>[];

    for (final ui in uc) {
      hls.add(Highlight.from(ui));
    }

    // _printHighlights(hls, withTitle: 'HIGHLIGHTS IMPORTED FROM DB:');

    add(HighlightEvent.updateFromDb(hls: hls));
  }

  Future<void> _saveHighlightsToDb(List<int> verses, List<Highlight> hls) async {
    final uc = await AppSettings.shared.userAccount.userDb
        .getItemsWithVBC(volumeId, book, chapter, ofTypes: [UserItemType.highlight]);

    // remove any existing hls in this reference range...
    for (final ui in uc) {
      if (verses.contains(ui.verse)) {
        await AppSettings.shared.userAccount.userDb.deleteItem(ui);
      }
    }

    // add any hls still in this reference range...
    for (final hl in hls) {
      for (final v in hl.ref.verses) {
        if (verses.contains(v)) {
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
            wordBegin: hl.ref.startWordForVerse(v),
            wordEnd: hl.ref.endWordForVerse(v),
            created: dbIntFromDateTime(DateTime.now()),
          );

          await AppSettings.shared.userAccount.userDb.saveItem(ui);
        }
      }
    }
  }

  @override
  Stream<ChapterHighlights> mapEventToState(HighlightEvent event) async* {
    final newState = event.when(
        add: _add, clear: _clear, updateFromDb: _updateFromDb, changeVolumeId: _changeVolumeId);
    yield newState;
  }

  ChapterHighlights _updateFromDb(List<Highlight> hls) {
    var newList = hls;

    if (hls.isNotEmpty) {
      // Stopwatch stopwatch;
      // if (kDebugMode) {
      //   stopwatch = Stopwatch()..start();
      // }

      newList = state.highlights;
      for (final hl in hls) {
        newList = newList.copySubtracting(hl.ref)..add(hl);
      }

      // if (kDebugMode) {
      //   dmPrint('Cleaning up the highlights took ${stopwatch.elapsed}');
      // }

      // _printHighlights(newList, withTitle: 'CLEANED UP HIGHLIGHTS:');
    }

    return ChapterHighlights(volumeId, book, chapter, newList, loaded: true);
  }

  ChapterHighlights _add(HighlightType type, int color, Reference ref, HighlightMode mode) {
    assert(type != HighlightType.clear);
    final newList = state.highlights.copySubtracting(ref)..add(Highlight(type, color, ref));
    if (mode == HighlightMode.save) {
      _saveHighlightsToDb(ref.verses.toList(), newList);
    }
    return ChapterHighlights(volumeId, book, chapter, newList, loaded: true);
  }

  ChapterHighlights _clear(Reference ref, HighlightMode mode) {
    final newList = state.highlights.copySubtracting(ref);
    if (mode == HighlightMode.trial) {
      // need to reset the hls...
      _initUserContent();
    } else {
      _saveHighlightsToDb(ref.verses.toList(), newList);
    }
    return ChapterHighlights(volumeId, book, chapter, newList, loaded: true);
  }

  ChapterHighlights _changeVolumeId(int volumeId) {
    this.volumeId = volumeId;
    _initUserContent();
    return ChapterHighlights(volumeId, book, chapter, [], loaded: false);
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

//void _printHighlights(List<Highlight> hls, {String withTitle}) {
//  if (kDebugMode) {
//    dmPrint('');
//    dmPrint('-----------------------------------------------------');
//    if (withTitle?.isNotEmpty ?? false) dmPrint(withTitle);
//    dmPrint('');
//    for (final hl in hls) {
//      dmPrint(hl.ref);
//    }
//    dmPrint('');
//    dmPrint('-----------------------------------------------------\n');
//    dmPrint('');
//  }
//}

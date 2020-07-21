import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/app_settings.dart';
import '../../models/color_utils.dart';
import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

part 'highlights_bloc.freezed.dart';

@freezed
abstract class ChapterHighlights with _$ChapterHighlights {
  const factory ChapterHighlights(int volume, int book, int chapter, List<Highlight> highlights,
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

@freezed
abstract class HighlightsEvent with _$HighlightsEvent {
  const factory HighlightsEvent.updateFromDb({@required List<Highlight> hls}) = _UpdateFromDb;

  const factory HighlightsEvent.add(
      {@required HighlightType type, @required int color, @required Reference ref}) = _Add;

  const factory HighlightsEvent.clear(Reference ref) = _Clear;
}

class ChapterHighlightsBloc extends Bloc<HighlightsEvent, ChapterHighlights> {
  final int volume;
  final int book;
  final int chapter;
  final bool loaded;

  ChapterHighlightsBloc(
      {@required this.volume, @required this.book, @required this.chapter, this.loaded = false}) {
    _initUserContent();
  }

  Future<void> _initUserContent() async {
    final uc = await AppSettings.shared.userAccount.userDb
        .getItemsWithVBC(volume, book, chapter, ofTypes: [UserItemType.highlight]);

    if (uc.isNotEmpty) {
      // We keep the highlights sorted by modified date with most recent at the bottom.
      uc.sort((a, b) => a?.modified?.compareTo(b.modified) ?? 1);
    }

    final hls = <Highlight>[];

    for (final ui in uc) {
      hls.add(Highlight.from(ui));
    }

    // _printHighlights(hls, withTitle: 'HIGHLIGHTS IMPORTED FROM DB:');

    add(HighlightsEvent.updateFromDb(hls: hls));
  }

  Future<void> _saveHighlightsToDb(List<int> verses, List<Highlight> hls) async {
    final uc = await AppSettings.shared.userAccount.userDb
        .getItemsWithVBC(volume, book, chapter, ofTypes: [UserItemType.highlight]);

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
            volumeId: volume,
            book: book,
            chapter: chapter,
            color: (hl.color & 0xFFFFFF) +
                ((hl.highlightType == HighlightType.underline) ? 0x1000000 : 0),
            verse: v,
            verseEnd: v,
            wordBegin: hl.ref.startWordForVerse(v),
            wordEnd: hl.ref.endWordForVerse(v),
            created: tec.dbIntFromDateTime(DateTime.now()),
          );

          await AppSettings.shared.userAccount.userDb.saveItem(ui);
        }
      }
    }
  }

  @override
  ChapterHighlights get initialState => ChapterHighlights(volume, book, chapter, [], loaded: false);

  @override
  Stream<ChapterHighlights> mapEventToState(HighlightsEvent event) async* {
    final newState = event.when(add: _add, clear: _clear, updateFromDb: _updateFromDb);
    // tec.dmPrint('Updated to $newState');
    yield newState;
  }

  ChapterHighlights _updateFromDb(List<Highlight> hls) {
    var newList = hls;

    if (hls.isNotEmpty) {
      Stopwatch stopwatch;
      if (kDebugMode) {
        stopwatch = Stopwatch()..start();
      }

      newList = state.highlights;
      for (final hl in hls) {
        newList = newList.copySubtracting(hl.ref)..add(hl);
      }

      if (kDebugMode) {
        tec.dmPrint('Cleaning up the highlights took ${stopwatch.elapsed}');
      }

      _printHighlights(newList, withTitle: 'CLEANED UP HIGHLIGHTS:');
    }

    return ChapterHighlights(volume, book, chapter, newList, loaded: true);
  }

  ChapterHighlights _add(HighlightType type, int color, Reference ref) {
    assert(type != HighlightType.clear);
    final newList = state.highlights.copySubtracting(ref)..add(Highlight(type, color, ref));
    _saveHighlightsToDb(ref.verses.toList(), newList);
    return ChapterHighlights(volume, book, chapter, newList, loaded: true);
  }

  ChapterHighlights _clear(Reference ref) {
    final newList = state.highlights.copySubtracting(ref);
    _saveHighlightsToDb(ref.verses.toList(), newList);
    return ChapterHighlights(volume, book, chapter, newList, loaded: true);
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

void _printHighlights(List<Highlight> hls, {String withTitle}) {
  if (kDebugMode) {
    tec.dmPrint('');
    tec.dmPrint('-----------------------------------------------------');
    if (withTitle?.isNotEmpty ?? false) tec.dmPrint(withTitle);
    tec.dmPrint('');
    for (final hl in hls) {
      tec.dmPrint(hl.ref);
    }
    tec.dmPrint('');
    tec.dmPrint('-----------------------------------------------------\n');
    tec.dmPrint('');
  }
}

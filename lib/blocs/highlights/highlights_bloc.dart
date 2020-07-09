import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/app_settings.dart';
import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

part 'highlights_bloc.freezed.dart';

@freezed
abstract class ChapterHighlights with _$ChapterHighlights {
  const factory ChapterHighlights(int volume, int book, int chapter, List<Highlight> highlights) =
      _ChapterHighlights;
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
    DateTime modified,
  ) = _Highlight;
}

@freezed
abstract class HighlightsEvent with _$HighlightsEvent {
  const factory HighlightsEvent.updateFromDb(
      {@required List<Highlight> hls}) = _UpdateFromDb;
  const factory HighlightsEvent.add(
      {@required HighlightType type, @required int color, @required Reference ref}) = _Add;
  const factory HighlightsEvent.clear(Reference ref) = _Clear;
}

class ChapterHighlightsBloc extends Bloc<HighlightsEvent, ChapterHighlights> {
  final int volume;
  final int book;
  final int chapter;

  ChapterHighlightsBloc({@required this.volume, @required this.book, @required this.chapter}) {
    _initUserContent();
  }

  Future<void> _initUserContent() async {
    final uc = await AppSettings.shared.userAccount.userDb
        .getItemsWithVBC(volume, book, chapter, ofTypes: [UserItemType.highlight]);

    final hls = <Highlight>[];

    for (final ui in uc) {
      var word = Reference.minWord, endWord = Reference.maxWord;

      // is this a parital hl?
      if (ui.wordBegin != word || ui.wordEnd != Reference.maxWord) {
        word = ui.wordBegin;
        endWord = ui.wordEnd;

        // catch old hl bugs where end was set to 0
        if (endWord <= Reference.minWord) {
          endWord = Reference.maxWord;
        }
      }

      final ref = Reference(
          volume: volume,
          book: book,
          chapter: chapter,
          verse: ui.verse,
          word: word,
          endWord: endWord,
      );

      final highlightType =
          (ui.color == 5 || ui.color > 1000) ? HighlightType.underline : HighlightType.highlight;

      hls.add(Highlight(
        highlightType,
        tec.intFromColorId(ui.color, darkMode: tec.Prefs.shared.getBool('isDarkTheme')),
        ref,
        ui.modifiedDT,
      ));
    }

    if (hls.isNotEmpty) {
      add(HighlightsEvent.updateFromDb(hls: hls));
    }
  }

  @override
  ChapterHighlights get initialState => ChapterHighlights(volume, book, chapter, []);

  @override
  Stream<ChapterHighlights> mapEventToState(HighlightsEvent event) async* {
    final newState = event.when(add: _add, clear: _clear, updateFromDb: _updateFromDb);
    // tec.dmPrint('Updated to $newState');
    yield newState;
  }

  ChapterHighlights _updateFromDb(List<Highlight> hls) {
    return ChapterHighlights(volume, book, chapter, hls);
  }

  ChapterHighlights _add(HighlightType type, int color, Reference ref) {
    assert(type != HighlightType.clear);
    final newList = state.highlights.copySubtracting(ref)
      ..add(Highlight(type, color, ref, DateTime.now()));
    return ChapterHighlights(volume, book, chapter, newList);
  }

  ChapterHighlights _clear(Reference ref) {
    final newList = state.highlights.copySubtracting(ref);
    return ChapterHighlights(volume, book, chapter, newList);
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

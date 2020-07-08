import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
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
  Highlight highlightForVerse(int verse) {
    for (final highlight in highlights.reversed) {
      if (highlight.ref.verse == verse) return highlight;
    }
    return null;
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
      final ref = Reference(volume: volume, book: book, chapter: chapter, verse: ui.verse);
      Highlight hl;

      if (ui.color == 5) {
        hl = Highlight(
          HighlightType.underline,
          tec.colorFromColorId(ui.color).value,
          ref,
          ui.modifiedDT,
        );
      } else {
        hl = Highlight(
          HighlightType.highlight,
          tec.colorFromColorId(ui.color).value,
          ref,
          ui.modifiedDT,
        );
      }

      hls.add(hl);
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
    tec.dmPrint('Updated to $newState');
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

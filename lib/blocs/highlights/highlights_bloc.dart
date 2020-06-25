import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

part 'highlights_bloc.freezed.dart';

@freezed
abstract class ChapterHighlights with _$ChapterHighlights {
  factory ChapterHighlights(int volume, int chapter, List<Highlight> highlights) =
      _ChapterHighlights;
}

@freezed
abstract class Highlight with _$Highlight {
  factory Highlight(
    HighlightType highlightType,
    int color,
    Reference ref,
    DateTime modified,
  ) = _Highlight;
}

@freezed
abstract class HighlightsEvent with _$HighlightsEvent {
  const factory HighlightsEvent.add(
      {@required HighlightType type, @required int color, @required Reference ref}) = _Add;
  const factory HighlightsEvent.clear(Reference ref) = _Clear;
}

class ChapterHighlightsBloc extends Bloc<HighlightsEvent, ChapterHighlights> {
  final int volume;
  final int chapter;

  ChapterHighlightsBloc({@required this.volume, @required this.chapter});

  @override
  ChapterHighlights get initialState => ChapterHighlights(volume, chapter, []);

  @override
  Stream<ChapterHighlights> mapEventToState(HighlightsEvent event) async* {
    final newState = event.when(add: _add, clear: _clear);
    tec.dmPrint('Updated to $newState');
    yield newState;
  }

  ChapterHighlights _add(HighlightType type, int color, Reference ref) {
    assert(type != HighlightType.clear);
    final newList = List.of(state.highlights)..add(Highlight(type, color, ref, DateTime.now()));
    return ChapterHighlights(volume, chapter, newList);
  }

  ChapterHighlights _clear(Reference ref) {
    return ChapterHighlights(volume, chapter, []);
  }
}

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

part 'selection_bloc.freezed.dart';

@freezed
abstract class SelectionState with _$SelectionState {
  const factory SelectionState(
      {@Default(false) bool isTextSelected,
      @Default(<int>{}) Set<int> selectedVerses}) = _SelectionState;
}

class SelectionBloc extends Bloc<SelectionState, SelectionState> {
  @override
  SelectionState get initialState =>
      const SelectionState(isTextSelected: false, selectedVerses: <int>{});

  @override
  Stream<SelectionState> mapEventToState(SelectionState event) async* {
    tec.dmPrint('$event');
    yield event;
  }

  void addVerse(int verse) {
    final verses = Set<int>.from(state.selectedVerses);
    if (!verses.remove(verse)) verses.add(verse);
    add(state.copyWith(isTextSelected: verses.isNotEmpty, selectedVerses: verses));
  }

  void clearVerses() => add(state.copyWith(isTextSelected: false, selectedVerses: {}));
}

@freezed
abstract class SelectionStyle with _$SelectionStyle {
  const factory SelectionStyle({
    HighlightType type,
    int color,
    @Default(false) bool isTrialMode,
    DateTime modified,
  }) = _SelectionStyle;
}

class SelectionStyleBloc extends Bloc<SelectionStyle, SelectionStyle> {
  @override
  SelectionStyle get initialState => const SelectionStyle();

  @override
  Stream<SelectionStyle> mapEventToState(SelectionStyle event) async* {
    final newState = event.modified != null ? event : event.copyWith(modified: DateTime.now());
    tec.dmPrint('$newState');
    yield newState;
  }
}

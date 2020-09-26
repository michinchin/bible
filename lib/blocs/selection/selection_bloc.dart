import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

part 'selection_bloc.freezed.dart';

@freezed
abstract class SelectionState with _$SelectionState {
  const factory SelectionState({
    bool isTextSelected,
    List<int> viewsWithSelections,
  }) = _SelectionState;
}

class SelectionBloc extends Bloc<SelectionState, SelectionState> {
  SelectionBloc() : super(const SelectionState(isTextSelected: false));

  @override
  Stream<SelectionState> mapEventToState(SelectionState event) async* {
    // tec.dmPrint('$event');
    yield event;
  }
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
  SelectionStyleBloc() : super(const SelectionStyle());

  @override
  Stream<SelectionStyle> mapEventToState(SelectionStyle event) async* {
    final newState = event.modified != null ? event : event.copyWith(modified: DateTime.now());
    // tec.dmPrint('$newState');
    yield newState;
  }
}

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
    // dmPrint('$event');
    yield event;
  }
}

@freezed
abstract class SelectionCmd with _$SelectionCmd {
  const factory SelectionCmd.noOp() = _NoOp;
  const factory SelectionCmd.clearStyle() = _ClearStyle;
  const factory SelectionCmd.setStyle(HighlightType type, int color) = _SetStyle;
  const factory SelectionCmd.tryStyle(HighlightType type, int color) = _TryStyle;
  const factory SelectionCmd.cancelTrial() = _CancelTrial;
  const factory SelectionCmd.deselectAll() = _DeselectAll;
}

class SelectionCmdBloc extends Cubit<SelectionCmd> {
  SelectionCmdBloc() : super(const SelectionCmd.noOp());

  void add(SelectionCmd cmd) {
    assert(cmd != null);
    emit(const SelectionCmd.noOp());
    emit(cmd);
  }
}

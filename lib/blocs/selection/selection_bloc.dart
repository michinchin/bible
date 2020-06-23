import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selection_bloc.freezed.dart';

enum SelectionType { highlight, underline }

@freezed
abstract class SelectionState with _$SelectionState {
  factory SelectionState({
    bool hasSelection,
    SelectionType type,
    int color,
  }) = _SelectionState;
}

class SelectionBloc extends Bloc<SelectionState, SelectionState> {
  @override
  SelectionState get initialState => SelectionState(hasSelection: false);

  @override
  Stream<SelectionState> mapEventToState(SelectionState event) async* {
    yield event;
  }
}

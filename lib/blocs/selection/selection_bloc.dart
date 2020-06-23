import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

part 'selection_bloc.freezed.dart';

enum HighlightType { clear, highlight, underline }

@freezed
abstract class SelectionState with _$SelectionState {
  factory SelectionState({
    bool isTextSelected,
    HighlightType highlightType,
    int color,
  }) = _SelectionState;
}

@freezed
abstract class SelectionEvent with _$SelectionEvent {
  const factory SelectionEvent.highlight({@required HighlightType type, int color}) = _Highlight;
  // ignore: avoid_positional_boolean_parameters
  const factory SelectionEvent.updateIsTextSelected(bool isTextSelected) = _UpdateIsTextSelected;
}

class SelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  @override
  SelectionState get initialState => SelectionState(isTextSelected: false);

  @override
  Stream<SelectionState> mapEventToState(SelectionEvent event) async* {
    final newState = event.when(highlight: (type, color) {
      return SelectionState(highlightType: type, color: color);
    }, updateIsTextSelected: (isTextSelected) {
      return SelectionState(isTextSelected: isTextSelected);
    });
    tec.dmPrint('SelectionBloc state updated to $newState');
    yield newState;
  }
}

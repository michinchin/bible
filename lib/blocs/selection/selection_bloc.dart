import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/shared_types.dart';

export '../../models/shared_types.dart' show HighlightType;

class SelectionState extends Equatable {
  final bool isTextSelected;
  final List<int> viewsWithSelections;

  const SelectionState({this.isTextSelected = false, this.viewsWithSelections = const []});

  @override
  List<Object> get props => [isTextSelected, viewsWithSelections];
}

class SelectionBloc extends Cubit<SelectionState> {
  SelectionBloc() : super(const SelectionState(isTextSelected: false));

  void updateWith(SelectionState newState) {
    emit(newState);
  }
}

enum SelectionCmdType { noOp, clearStyle, setStyle, tryStyle, cancelTrial, deselectAll }

class SelectionCmd extends Equatable {
  final SelectionCmdType cmdType;
  final HighlightType highlightType;
  final int color;

  const SelectionCmd(this.cmdType, {this.highlightType, this.color});

  @override
  List<Object> get props => [cmdType, highlightType, color];

  factory SelectionCmd.noOp() => const SelectionCmd(SelectionCmdType.noOp);
  factory SelectionCmd.clearStyle() => const SelectionCmd(SelectionCmdType.clearStyle);
  factory SelectionCmd.setStyle(HighlightType type, int color) =>
      SelectionCmd(SelectionCmdType.setStyle, highlightType: type, color: color);
  factory SelectionCmd.tryStyle(HighlightType type, int color) =>
      SelectionCmd(SelectionCmdType.tryStyle, highlightType: type, color: color);
  factory SelectionCmd.cancelTrial() => const SelectionCmd(SelectionCmdType.cancelTrial);
  factory SelectionCmd.deselectAll() => const SelectionCmd(SelectionCmdType.deselectAll);
}

class SelectionCmdBloc extends Cubit<SelectionCmd> {
  SelectionCmdBloc() : super(SelectionCmd.noOp());

  void add(SelectionCmd cmd) {
    assert(cmd != null);
    emit(SelectionCmd.noOp());
    emit(cmd);
  }
}

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_util/tec_util.dart' as tec;

part 'sheet_manager_bloc.freezed.dart';

enum SheetType { main, selection }

@freezed
abstract class SheetManagerState with _$SheetManagerState {
  const factory SheetManagerState(
      {@required SheetType type}) = _SheetState;
}

@freezed
abstract class SheetEvent with _$SheetEvent {
  const factory SheetEvent.changeType(SheetType type) = _ChangeType;
}

class SheetManagerBloc extends Bloc<SheetEvent, SheetManagerState> {
  SheetManagerBloc() : super(const SheetManagerState(type: SheetType.main));
  bool _correctHiddenValue = false;

  @override
  Stream<SheetManagerState> mapEventToState(SheetEvent event) async* {
    final newState = event.when(
        changeType: _changeType);
    tec.dmPrint('Sheet Update: to $newState');
    yield newState;
  }

  SheetManagerState _changeType(SheetType type) => state.copyWith(type: type);

  void changeType(SheetType type) => add(SheetEvent.changeType(type));

  void collapse(BuildContext context) {
    if (!_correctHiddenValue && state.type == SheetType.main) {
      _correctHiddenValue = true;
      SheetController.of(context).hide();
    }
  }

  void restore(BuildContext context) {
    // Only change the state if it actually needs to change.

    if (state.type != SheetType.main) {
      // update the type
      changeType(SheetType.main);
    }

    if (_correctHiddenValue) {
      _correctHiddenValue = false;
      _show(SheetController.of(context));
    }
  }

  void _show(SheetController sheetController) {
    if (_correctHiddenValue) {
      // async issue - trying to do a delayed show - but it's supposed to be hidden
      // ignore
      return;
    }

    // the sheet is supposed to visible now
    if (sheetController.state == null || sheetController.state.isHidden) {
      // the sheet thinks it's actually hidden - ok to show now
      sheetController.show();
    }
    else {
      // there was a quick change... need to wait for the async 'hidden' to finish
      Future.delayed(const Duration(milliseconds: 150), () {
        _show(sheetController);
      });
    }
  }
}

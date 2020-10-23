import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_util/tec_util.dart' as tec;

part 'sheet_manager_bloc.freezed.dart';

enum SheetType { main, selection, windows }

enum SheetSize { mini, medium, full }

@freezed
abstract class SheetManagerState with _$SheetManagerState {
  const factory SheetManagerState(
      {@required SheetType type, @required SheetSize size, int viewUid}) = _SheetState;
}

@freezed
abstract class SheetEvent with _$SheetEvent {
  const factory SheetEvent.changeSize(SheetSize size) = _ChangeSize;
  const factory SheetEvent.changeType(SheetType type) = _ChangeType;
  const factory SheetEvent.changeView(int uid) = _ChangeView;
  const factory SheetEvent.changeTypeSize(SheetType type, SheetSize size) = _ChangeTypeSize;
}

class SheetManagerBloc extends Bloc<SheetEvent, SheetManagerState> {
  SheetManagerBloc() : super(const SheetManagerState(type: SheetType.main, size: SheetSize.mini));
  bool _correctHiddenValue;

  @override
  Stream<SheetManagerState> mapEventToState(SheetEvent event) async* {
    final newState = event.when(
        changeSize: _changeSize,
        changeType: _changeType,
        changeView: _changeView,
        changeTypeSize: _changeTypeSize);
    tec.dmPrint('Sheet Update: to $newState');
    yield newState;
  }

  SheetManagerState _changeSize(SheetSize size) => state.copyWith(size: size);
  SheetManagerState _changeType(SheetType type) => state.copyWith(type: type);
  SheetManagerState _changeView(int uid) => state.copyWith(viewUid: uid);
  SheetManagerState _changeTypeSize(SheetType type, SheetSize size) =>
      state.copyWith(size: size, type: type);

  void changeType(SheetType type) => add(SheetEvent.changeType(type));
  void changeSize(SheetSize size) => add(SheetEvent.changeSize(size));
  void changeTypeSize(SheetType type, SheetSize size) => add(SheetEvent.changeTypeSize(type, size));
  void setUid(int uid) => add(SheetEvent.changeView(uid));

  void collapse(BuildContext context) {
    _correctHiddenValue = true;
    SheetController.of(context).hide();
  }

  void restore(BuildContext context) {
    // Only change the state if it actually needs to change.

    if (state.type != SheetType.main && state.size != SheetSize.mini) {
      // update both type and size
      changeTypeSize(SheetType.main, SheetSize.mini);
    } else if (state.type != SheetType.main) {
      // update the type
      changeType(SheetType.main);
    } else if (state.size != SheetSize.mini) {
      // update the size
      changeSize(SheetSize.mini);
    }

    _correctHiddenValue = false;
    _show(SheetController.of(context));
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

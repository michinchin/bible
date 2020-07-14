import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

part 'sheet_manager_bloc.freezed.dart';

enum SheetType { collapsed, main, selection, windows }

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
}

class SheetManagerBloc extends Bloc<SheetEvent, SheetManagerState> {
  @override
  SheetManagerState get initialState =>
      const SheetManagerState(type: SheetType.main, size: SheetSize.mini);

  @override
  Stream<SheetManagerState> mapEventToState(SheetEvent event) async* {
    final newState =
        event.when(changeSize: _changeSize, changeType: _changeType, changeView: _changeView);
    tec.dmPrint('Sheet Update: to $newState');
    yield newState;
  }

  SheetManagerState _changeSize(SheetSize size) => state.copyWith(size: size);

  SheetManagerState _changeType(SheetType type) => state.copyWith(type: type);
  SheetManagerState _changeView(int uid) => state.copyWith(viewUid: uid);

  void changeType(SheetType type) => add(SheetEvent.changeType(type));
  void changeSize(SheetSize size) => add(SheetEvent.changeSize(size));
  void setUid(int uid) => add(SheetEvent.changeView(uid));
  void toDefaultView() {
    changeType(SheetType.main);
    changeSize(SheetSize.mini);
  }
}

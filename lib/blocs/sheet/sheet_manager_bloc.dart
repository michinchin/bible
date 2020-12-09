import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum SheetType { main, selection, hidden }

class SheetManagerState extends Equatable {
  final SheetType type;
  const SheetManagerState(this.type);

  @override
  List<Object> get props => [type];
}

enum SheetEvent { main, selection, restore, collapse }

class SheetManagerBloc extends Bloc<SheetEvent, SheetManagerState> {
  SheetManagerBloc() : super(const SheetManagerState(SheetType.main));

  @override
  Stream<SheetManagerState> mapEventToState(SheetEvent event) async* {
    SheetManagerState newState;

    switch (event) {
      case SheetEvent.main:
        newState = const SheetManagerState(SheetType.main);
        break;
      case SheetEvent.selection:
        newState = const SheetManagerState(SheetType.selection);
        break;
      case SheetEvent.collapse:
        if (state.type == SheetType.selection) {
          // don't allow collapse when in selection mode...
          newState = state;
        } else {
          newState = const SheetManagerState(SheetType.hidden);
        }
        break;
      case SheetEvent.restore:
        if (state.type == SheetType.selection) {
          // don't allow restore when in selection mode...
          newState = state;
        } else {
          newState = const SheetManagerState(SheetType.main);
        }
        break;
    }
    tec.dmPrint('Sheet Update: to ${newState.type}');
    yield newState;
  }
}

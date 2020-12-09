import 'package:bloc/bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum SheetType { main, selection, hidden }

class SheetManagerState {
  final SheetType type;
  SheetManagerState(this.type);
}

enum SheetEvent { main, selection, restore, collapse }

class SheetManagerBloc extends Bloc<SheetEvent, SheetManagerState> {
  SheetManagerBloc() : super(SheetManagerState(SheetType.main));

  @override
  Stream<SheetManagerState> mapEventToState(SheetEvent event) async* {
    SheetManagerState newState;

    switch (event) {
      case SheetEvent.main:
        newState = SheetManagerState(SheetType.main);
        break;
      case SheetEvent.selection:
        newState = SheetManagerState(SheetType.selection);
        break;
      case SheetEvent.collapse:
        if (state.type == SheetType.selection) {
          // don't allow collapse when in selection mode...
          newState = state;
        } else {
          newState = SheetManagerState(SheetType.hidden);
        }
        break;
      case SheetEvent.restore:
        if (state.type == SheetType.selection) {
          // don't allow restore when in selection mode...
          newState = state;
        } else {
          newState = SheetManagerState(SheetType.main);
        }
        break;
    }
    tec.dmPrint('Sheet Update: to ${newState.type}');
    yield newState;
  }
}

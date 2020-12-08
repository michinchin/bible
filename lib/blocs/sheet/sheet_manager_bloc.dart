import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum SheetType { main, selection, hidden }

class SheetManagerState extends Equatable {
  final SheetType type;
  final SheetType previousType;

  const SheetManagerState(this.type, this.previousType);

  @override
  List<Object> get props => [type, previousType];
}

enum SheetEvent { main, selection, restore, collapse }

class SheetManagerBloc extends Bloc<SheetEvent, SheetManagerState> {
  SheetManagerBloc() : super(const SheetManagerState(SheetType.main, SheetType.hidden));

  @override
  Stream<SheetManagerState> mapEventToState(SheetEvent event) async* {
    SheetManagerState newState;

    switch (event) {
      case SheetEvent.main:
        newState = SheetManagerState(SheetType.main, state.type);
        break;
      case SheetEvent.selection:
        newState = SheetManagerState(SheetType.selection, state.type);
        break;
      case SheetEvent.collapse:
        if (state.type == SheetType.selection) {
          // don't allow collapse when in selection mode...
          newState = state;
        } else {
          newState = SheetManagerState(SheetType.hidden, state.type);
        }
        break;
      case SheetEvent.restore:
        if (state.type == SheetType.selection) {
          // don't allow restore when in selection mode...
          newState = state;
        } else {
          newState = SheetManagerState(SheetType.main, state.type);
        }
        break;
    }
    tec.dmPrint('Sheet Update: to ${newState.type}');
    yield newState;
  }
}

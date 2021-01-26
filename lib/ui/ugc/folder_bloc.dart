import 'package:equatable/equatable.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;

class FolderState extends Equatable {
  final String name;
  final UserItem parent;

  const FolderState({this.name, this.parent});

  @override
  List<Object> get props => [name, parent.id];
}

class FolderUpdate {
  final FolderState state;
  FolderUpdate(this.state);
}

class FolderBloc extends tec.SafeBloc<FolderUpdate, FolderState> {
  FolderBloc(FolderState initialState) : super(initialState);

  @override
  Stream<FolderState> mapEventToState(FolderUpdate event) async* {
    yield event.state;
  }
}

import 'package:tec_volumes/tec_volumes.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nav_bloc.freezed.dart';

@freezed
abstract class NavEvent with _$NavEvent {
  const factory NavEvent.changeIndex({int index}) = _ChangeIndex;
  const factory NavEvent.setBookChapterVerse({BookChapterVerse bcv}) = _SetBCV;
}

@freezed
abstract class NavState with _$NavState {
  const factory NavState({int tabIndex, BookChapterVerse bcv}) = _NavState;
}

class NavBloc extends Bloc<NavEvent, NavState> {
  final BookChapterVerse initialRef;
  NavBloc(this.initialRef);

  @override
  NavState get initialState =>
      NavState(bcv: initialRef ?? BookChapterVerse.fromHref('50/1/1'), tabIndex: 0);

  @override
  Stream<NavState> mapEventToState(NavEvent event) async* {
    final newState = event.when(changeIndex: _changeIndex, setBookChapterVerse: _setBCV);
    // tec.dmPrint('$newState');
    yield newState;
  }

  NavState _changeIndex(int index) {
    return state.copyWith(tabIndex: index);
  }

  NavState _setBCV(BookChapterVerse bcv) {
    return state.copyWith(bcv: bcv);
  }
}

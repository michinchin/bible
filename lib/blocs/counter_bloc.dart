import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

part 'counter_bloc.freezed.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  @override
  CounterState get initialState =>
      CounterState.initial(tec.Prefs.shared.getInt('counter', defaultValue: 0));

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    final value = event.when(
      increment: () => state.value + 1,
      decrement: () => state.value - 1,
    );
    await tec.Prefs.shared.setInt('counter', value);
    yield CounterState.current(value);
  }

  void increment() => add(const CounterEvent.increment());
  void decrement() => add(const CounterEvent.decrement());
}

@freezed
abstract class CounterEvent with _$CounterEvent {
  const factory CounterEvent.increment() = _Increment;
  const factory CounterEvent.decrement() = _Decrement;
}

@freezed
abstract class CounterState with _$CounterState {
  const factory CounterState.initial([@Default(0) int value]) = _Initial;
  const factory CounterState.current(int value) = _Current;
}

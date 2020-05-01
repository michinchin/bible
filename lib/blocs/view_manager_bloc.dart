import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

part 'view_manager_bloc.freezed.dart';
part 'view_manager_bloc.g.dart';

const String _key = 'viewManagerState';

class ViewManagerBloc extends Bloc<ViewManagerEvent, ViewManagerState> {
  final tec.KeyValueStore _kvStore;

  ViewManagerBloc({@required tec.KeyValueStore kvStore})
      : assert(kvStore != null),
        _kvStore = kvStore;

  @override
  ViewManagerState get initialState {
    final jsonStr = _kvStore.getString(_key);
    if (tec.isNotNullOrEmpty(jsonStr)) {
      final json = tec.parseJsonSync(jsonStr);
      if (json != null) return ViewManagerState.fromJson(json);
    }
    return ViewManagerState([]);
  }

  @override
  Stream<ViewManagerState> mapEventToState(ViewManagerEvent event) async* {
    final value = event.when(add: _add, remove: _remove, move: _move);
    assert(value != null);
    if (value == null) {
      assert(false);
      yield state;
    } else {
      if (value != state) {
        final strValue = tec.toJsonString(value);
        await _kvStore.setString(_key, strValue);
      }
      yield value;
    }
  }

  ViewManagerState _add(ViewType type, int position, String data) {
    final view = ViewState(type: type, data: data);
    final newViews = List<ViewState>.from(state.views); // shallow copy
    newViews.insert(position ?? newViews.length, view);
    return ViewManagerState(newViews);
  }

  ViewManagerState _remove(int position) {
    assert(position != null);
    final newViews = List<ViewState>.from(state.views) // shallow copy
      ..removeAt(position);
    return ViewManagerState(newViews);
  }

  ViewManagerState _move(int from, int to) {
    if (from == to) return state;
    final newViews = List<ViewState>.from(state.views) // shallow copy
      ..move(from: from, to: to);
    return ViewManagerState(newViews);
  }
}

//typedef ViewBuilder = Widget Function(BuildContext context);

/*
mixin Viewable {
  //static Size get minSize => const Size(300, 300);
  double get preferredWidth; // `null` indicates no preferredWidth
  double get preferredHeight; // `null` indicates no preferredWidth

} */

@freezed
abstract class ViewManagerEvent with _$ViewManagerEvent {
  const factory ViewManagerEvent.add(
      {@required ViewType type, int position, String data}) = _Add;
  const factory ViewManagerEvent.remove(int position) = _Remove;
  const factory ViewManagerEvent.move({int fromPosition, int toPosition}) =
      _Move;
  // const factory ViewManagerEvent.setWidth({int position, double width}) =
  //     _SetWidth;
}

@freezed
abstract class ViewManagerState with _$ViewManagerState {
  factory ViewManagerState(List<ViewState> views) = _Views;

  /// fromJson
  factory ViewManagerState.fromJson(Map<String, dynamic> json) =>
      _$ViewManagerStateFromJson(json);
}

@freezed
abstract class ViewState with _$ViewState {
  factory ViewState({ViewType type, double preferredWidth, String data}) =
      _ViewState;

  /// fromJson
  factory ViewState.fromJson(Map<String, dynamic> json) =>
      _$ViewStateFromJson(json);
}

enum ViewType { test }

///
/// Some helpful List extensions
///
extension _ExtList on List {
  bool isInRange(num i) => i >= 0 && i < length;

  void move({@required int from, @required int to}) {
    assert(from != null && isInRange(from) && to != null && isInRange(to));
    final dynamic temp = this[from];
    if (from < to) {
      for (var i = from; i < to;) {
        this[i] = this[++i];
      }
      this[to] = temp;
    } else if (from > to) {
      for (var i = from; i > to;) {
        this[i] = this[--i];
      }
      this[to] = temp;
    }
  }
}

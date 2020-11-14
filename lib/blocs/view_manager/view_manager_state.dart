import 'package:freezed_annotation/freezed_annotation.dart';

import 'view_manager_bloc.dart';
import 'view_state.dart';

part 'view_manager_state.freezed.dart';
part 'view_manager_state.g.dart';

@freezed
abstract class ViewManagerState with _$ViewManagerState {
  factory ViewManagerState(List<ViewState> views, int maximizedViewUid, int nextUid) = _Views;
  factory ViewManagerState.fromJson(Map<String, dynamic> json) => _$ViewManagerStateFromJson(json);
}

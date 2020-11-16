import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_state.freezed.dart';
part 'view_state.g.dart';

@freezed
abstract class ViewState with _$ViewState {
  factory ViewState({int uid, String type, double preferredWidth, double preferredHeight}) =
      _ViewState;
  factory ViewState.fromJson(Map<String, dynamic> json) => _$ViewStateFromJson(json);
}

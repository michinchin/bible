import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_manager_event.freezed.dart';

@freezed
abstract class ViewManagerEvent with _$ViewManagerEvent {
  const factory ViewManagerEvent.add({@required String type, int position, String data}) = _Add;
  const factory ViewManagerEvent.remove(int uid) = _Remove;
  const factory ViewManagerEvent.maximize(int uid) = _Maximize;
  const factory ViewManagerEvent.restore() = _Restore;
  const factory ViewManagerEvent.move({int fromPosition, int toPosition}) = _Move;
  const factory ViewManagerEvent.setWidth({int position, double width}) = _SetWidth;
  const factory ViewManagerEvent.setHeight({int position, double height}) = _SetHeight;
}

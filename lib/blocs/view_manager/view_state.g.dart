// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, avoid_single_cascade_in_expression_statements, avoid_positional_boolean_parameters, avoid_as

part of 'view_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ViewState _$_$_ViewStateFromJson(Map<String, dynamic> json) {
  return _$_ViewState(
    uid: json['uid'] as int,
    type: json['type'] as String,
    preferredWidth: (json['preferredWidth'] as num)?.toDouble(),
    preferredHeight: (json['preferredHeight'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$_$_ViewStateToJson(_$_ViewState instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'type': instance.type,
      'preferredWidth': instance.preferredWidth,
      'preferredHeight': instance.preferredHeight,
    };

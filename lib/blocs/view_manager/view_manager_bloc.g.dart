// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, avoid_single_cascade_in_expression_statements, avoid_positional_boolean_parameters

part of 'view_manager_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ViewState _$_$_ViewStateFromJson(Map<String, dynamic> json) {
  return _$_ViewState(
    uid: json['uid'] as int,
    type: json['type'] as String,
    preferredWidth: (json['preferredWidth'] as num)?.toDouble(),
    preferredHeight: (json['preferredHeight'] as num)?.toDouble(),
    data: json['data'] as String,
  );
}

Map<String, dynamic> _$_$_ViewStateToJson(_$_ViewState instance) => <String, dynamic>{
      'uid': instance.uid,
      'type': instance.type,
      'preferredWidth': instance.preferredWidth,
      'preferredHeight': instance.preferredHeight,
      'data': instance.data,
    };

_$_Views _$_$_ViewsFromJson(Map<String, dynamic> json) {
  return _$_Views(
    (json['views'] as List)
        ?.map((dynamic e) => e == null ? null : ViewState.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['maximizedViewUid'] as int,
    json['nextUid'] as int,
  );
}

Map<String, dynamic> _$_$_ViewsToJson(_$_Views instance) => <String, dynamic>{
      'views': instance.views,
      'maximizedViewUid': instance.maximizedViewUid,
      'nextUid': instance.nextUid,
    };

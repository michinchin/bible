// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, avoid_single_cascade_in_expression_statements, avoid_positional_boolean_parameters, avoid_as

part of 'view_manager_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Views _$_$_ViewsFromJson(Map<String, dynamic> json) {
  return _$_Views(
    (json['views'] as List)
        ?.map((dynamic e) =>
            e == null ? null : ViewState.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['maximizedViewUid'] as int,
    json['nextUid'] as int,
  );
}

Map<String, dynamic> _$_$_ViewsToJson(_$_Views instance) => <String, dynamic>{
      'views': instance.views?.map((e) => e?.toJson())?.toList(),
      'maximizedViewUid': instance.maximizedViewUid,
      'nextUid': instance.nextUid,
    };

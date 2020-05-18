// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names

part of 'view_manager_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ViewState _$_$_ViewStateFromJson(Map<String, dynamic> json) {
  return _$_ViewState(
    type: _$enumDecodeNullable(_$ViewTypeEnumMap, json['type']),
    preferredWidth: (json['preferredWidth'] as num)?.toDouble(),
    preferredHeight: (json['preferredHeight'] as num)?.toDouble(),
    data: json['data'] as String,
  );
}

Map<String, dynamic> _$_$_ViewStateToJson(_$_ViewState instance) =>
    <String, dynamic>{
      'type': _$ViewTypeEnumMap[instance.type],
      'preferredWidth': instance.preferredWidth,
      'preferredHeight': instance.preferredHeight,
      'data': instance.data,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ViewTypeEnumMap = {
  ViewType.bible: 'bible',
};

_$_Views _$_$_ViewsFromJson(Map<String, dynamic> json) {
  return _$_Views(
    (json['views'] as List)
        ?.map((dynamic e) =>
            e == null ? null : ViewState.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$_$_ViewsToJson(_$_Views instance) => <String, dynamic>{
      'views': instance.views,
    };

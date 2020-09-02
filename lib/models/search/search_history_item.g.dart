// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, avoid_single_cascade_in_expression_statements, avoid_positional_boolean_parameters, avoid_as

part of 'search_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SearchHistoryItem _$_$_SearchHistoryItemFromJson(Map<String, dynamic> json) {
  return _$_SearchHistoryItem(
    search: json['search'] as String,
    volumesFiltered: json['volumesFiltered'] as String,
    booksFiltered: json['booksFiltered'] as String,
    index: json['index'] as int,
    modified: json['modified'] == null
        ? null
        : DateTime.parse(json['modified'] as String),
  );
}

Map<String, dynamic> _$_$_SearchHistoryItemToJson(
        _$_SearchHistoryItem instance) =>
    <String, dynamic>{
      'search': instance.search,
      'volumesFiltered': instance.volumesFiltered,
      'booksFiltered': instance.booksFiltered,
      'index': instance.index,
      'modified': instance.modified?.toIso8601String(),
    };

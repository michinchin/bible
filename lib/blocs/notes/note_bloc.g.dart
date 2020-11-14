// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, avoid_single_cascade_in_expression_statements, avoid_positional_boolean_parameters, avoid_as

part of 'note_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Note _$_$_NoteFromJson(Map<String, dynamic> json) {
  return _$_Note(
    id: json['id'] as int,
    doc: json['doc'] == null
        ? null
        : NotusDocument.fromJson(json['doc'] as List),
  );
}

Map<String, dynamic> _$_$_NoteToJson(_$_Note instance) => <String, dynamic>{
      'id': instance.id,
      'doc': instance.doc?.toJson(),
    };

_$_Notes _$_$_NotesFromJson(Map<String, dynamic> json) {
  return _$_Notes(
    (json['notes'] as List)
        ?.map(
            (dynamic e) => e == null ? null : Note.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$_$_NotesToJson(_$_Notes instance) => <String, dynamic>{
      'notes': instance.notes?.map((e) => e?.toJson())?.toList(),
    };

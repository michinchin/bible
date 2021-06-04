import 'package:tec_util/tec_util.dart';

class Verse {
  final String title;
  final int id;
  final String abbreviation;
  final String verseContent;

  Verse({
    this.title,
    this.id,
    this.abbreviation,
    this.verseContent,
  });

  factory Verse.fromJson(Map<String, dynamic> json, String ref) {
    return Verse(
      title: ref,
      id: as<int>(json['id']),
      abbreviation: as<String>(json['a']),
      verseContent: as<String>(json['text']),
    );
  }
}

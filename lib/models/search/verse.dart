import 'package:tec_util/tec_util.dart' as tec;

class Verse {
  final String title;
  final int id;
  final String a;
  final String verseContent;

  Verse({
    this.title,
    this.id,
    this.a,
    this.verseContent,
  });

  factory Verse.fromJson(Map<String, dynamic> json, String ref) {
    return Verse(
      title: ref,
      id: tec.as<int>(json['id']),
      a: tec.as<String>(json['a']),
      verseContent: tec.as<String>(json['text']),
    );
  }
}

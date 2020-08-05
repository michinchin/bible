import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

class BibleChapterState {
  final int bibleId;
  final BookChapterVerse bcv;
  final int page;
  String title;

  BibleChapterState(this.bibleId, this.bcv, this.page, {String title}) {
    if (title == null) {
      final bible = VolumesRepository.shared.bibleWithId(bibleId);
      this.title = bible.titleWithHref('${bcv.book}/${bcv.chapter}');
    } else {
      this.title = title;
    }
  }

  static BookChapterVerse initialBCV() {
    return const BookChapterVerse(50, 1, 1);
  }

  factory BibleChapterState.initial() {
    return BibleChapterState(51, initialBCV(), 0);
  }

  factory BibleChapterState.fromJson(Object o) {
    BookChapterVerse bcv;
    int page, bibleId;
    String title;

    final json = (o is String) ? tec.parseJsonSync(o) : o;
    if (json is Map<String, dynamic>) {
      bibleId = tec.as<int>(json['vid']);
      bcv = BookChapterVerse.fromJson(json['bcv']);
      page = tec.as<int>(json['page']);
    }

    return BibleChapterState(bibleId, bcv, page);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'vid': bibleId, 'bcv': bcv, 'page': page, 'title': title};
  }

  @override
  String toString() {
    return tec.toJsonString(toJson());
  }
}
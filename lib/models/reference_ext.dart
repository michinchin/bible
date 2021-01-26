import 'package:tec_volumes/tec_volumes.dart';

extension BibleExtOnReference on Reference {
  String label() {
    var bible = VolumesRepository.shared.bibleWithId(volume);

    if (bible is Bible && bible.abbreviation != null) {
      return '${bible.nameOfBook(book)} $chapter:${versesToString()} ${bible.abbreviation}';
    }

    // add study content abbreviations
    bible = VolumesRepository.shared.bibleWithId(9);
    final studyContent = VolumesRepository.shared.volumeWithId(volume);
    final abbreviation = studyContent?.abbreviation ?? '';
    return '${bible.nameOfBook(book)} $chapter:${versesToString()} $abbreviation'.trim();
  }
}

import 'dart:ui';

import 'package:tec_util/tec_util.dart';

// ignore: avoid_classes_with_only_static_members
class Const {
  static const tecartaBlue = Color(0xff4a7dee);

  static const appNameForUA = 'Tecarta Bible';

  static const viewTypeVolume = 'BibleChapter';
  static const viewTypeNotes = 'NotesView';
  static const viewTypeMarginNote = 'MarginNoteView';

  //------------------------------------------
  // Ad info:

  // native ads
  static final prefNativeAdId = platformIs(Platform.android)
      ? 'ca-app-pub-5279916355700267/7465311659'
      : platformIs(Platform.iOS)
          ? 'ca-app-pub-5279916355700267/1130609577'
          : null;

  //------------------------------------------
  // Preference key names:

  // Font
  static const prefContentTextScaleFactor = 'contentTextScaleFactor';
  static const prefContentFontName = 'contentFontName';

  // Highlighting
  static const prefSelectionSheetFullSize = 'selectionSheetFullSize';

  // Links
  static const tecartaBibleLink = 'https://tecartabible.com/';

  // Notifications
  static const prefFirstTimeOpen = 'firstTimeOpen';
  static const prefNotifications = 'notifications';
  static const prefNotificationUpdate = 'notificationUpdate';

  // Onboarding
  static const prefShowOnboarding = 'showOnboaring';

  //------------------------------------------

  // Bible
  static const defaultBible = 9;
  static const base64Map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

  static const extraBookNames = {
    'ge': 1,
    'gen': 1,
    'genesis': 1,
    'exodus': 2,
    'ex': 2,
    'exo': 2,
    'exod': 2,
    'leviticus': 3,
    'lev': 3,
    'numbers': 4,
    'nu': 4,
    'num': 4,
    'deuteronomy': 5,
    'deut': 5,
    'dt': 5,
    'joshua': 6,
    'jos': 6,
    'josh': 6,
    'judges': 7,
    'jdg': 7,
    'judg': 7,
    'ruth': 8,
    'ru': 8,
    '1 samuel': 9,
    '1samuel': 9,
    '1sa': 9,
    '1 sa': 9,
    '1 sam': 9,
    '2 samuel': 10,
    '2samuel': 10,
    '2sa': 10,
    '2 sa': 10,
    '2 sam': 10,
    '1 kings': 11,
    '1kings': 11,
    '1ki': 11,
    '1 kgs': 11,
    '1 ki': 11,
    '1 kin': 11,
    '2 kings': 12,
    '2kings': 12,
    '2 ki': 12,
    '2 kin': 12,
    '2 kgs': 12,
    '2ki': 12,
    '1 chronicles': 13,
    '1chronicles': 13,
    '1ch': 13,
    '1 ch': 13,
    '1 chron': 13,
    '1 chr': 13,
    '2 chronicles': 14,
    '2chronicles': 14,
    '2ch': 14,
    '2 ch': 14,
    '2 chron': 14,
    '2 chr': 14,
    'ezra': 15,
    'ezr': 15,
    'nehemiah': 16,
    'ne': 16,
    'neh': 16,
    'esther': 19,
    'est': 19,
    'esth': 19,
    'job': 22,
    'psalms': 23,
    'psalm': 23,
    'ps': 23,
    'proverbs': 24,
    'pr': 24,
    'prov': 24,
    'ecclesiastes': 25,
    'ecc': 25,
    'eccl': 25,
    'song of solomon': 26,
    'song_of_solomon': 26,
    'song': 26,
    'ss': 26,
    'is': 29,
    'isaiah': 29,
    'isa': 29,
    'jeremiah': 30,
    'jer': 30,
    'lamentations': 31,
    'la': 31,
    'lam': 31,
    'ezekiel': 33,
    'eze': 33,
    'ezek': 33,
    'daniel': 34,
    'da': 34,
    'dan': 34,
    'hosea': 35,
    'hos': 35,
    'joel': 36,
    'amos': 37,
    'am': 37,
    'obadiah': 38,
    'ob': 38,
    'oba': 38,
    'obad': 38,
    'jonah': 39,
    'jon': 39,
    'jnh': 39,
    'micah': 40,
    'mic': 40,
    'nahum': 41,
    'na': 41,
    'nah': 41,
    'habakkuk': 42,
    'hab': 42,
    'zephaniah': 43,
    'zep': 43,
    'zeph': 43,
    'haggai': 44,
    'hag': 44,
    'ha': 44,
    'zechariah': 45,
    'zec': 45,
    'zech': 45,
    'malachi': 46,
    'mal': 46,
    'matthew': 47,
    'matt': 47,
    'mt': 47,
    'mark': 48,
    'mk': 48,
    'luke': 49,
    'lk': 49,
    'john': 50,
    'jn': 50,
    'acts': 51,
    'ac': 51,
    'romans': 52,
    'ro': 52,
    'rom': 52,
    '1 corinthians': 53,
    '1corinthians': 53,
    '1co': 53,
    '1 co': 53,
    '1 cor': 53,
    '2 corinthians': 54,
    '2corinthians': 54,
    '2co': 54,
    '2 co': 54,
    '2 cor': 54,
    'galatians': 55,
    'gal': 55,
    'ephesians': 56,
    'eph': 56,
    'philippians': 57,
    'php': 57,
    'phil': 57,
    'colossians': 58,
    'col': 58,
    '1 thessalonians': 59,
    '1thessalonians': 59,
    '1th': 59,
    '1thes': 59,
    '1 thes': 59,
    '1 thess': 59,
    '1 th': 59,
    '2 thessalonians': 60,
    '2thessalonians': 60,
    '2 th': 60,
    '2 thes': 60,
    '2 thess': 60,
    '2th': 60,
    '2thes': 60,
    '1 timothy': 61,
    '1 ti': 61,
    '1 tim': 61,
    '1timothy': 61,
    '1ti': 61,
    '2 timothy': 62,
    '2 ti': 62,
    '2 tim': 62,
    '2timothy': 62,
    '2ti': 62,
    'titus': 63,
    'tit': 63,
    'philemon': 64,
    'phm': 64,
    'philem': 64,
    'hebrews': 65,
    'heb': 65,
    'james': 66,
    'jas': 66,
    '1 peter': 67,
    '1peter': 67,
    '1pe': 67,
    '1 pe': 67,
    '1 pet': 67,
    '2 peter': 68,
    '2peter': 68,
    '2 pe': 68,
    '2 pet': 68,
    '2pe': 68,
    '1 john': 69,
    '1jhn': 69,
    '1john': 69,
    '1jn': 69,
    '2 john': 70,
    '2john': 70,
    '2jhn': 70,
    '2jn': 70,
    '3 john': 71,
    '3john': 71,
    '3jn': 71,
    'jude': 72,
    'revelation': 73,
    'rev': 73,
  };
}

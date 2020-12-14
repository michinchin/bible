import 'dart:collection';

import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import 'verse_tag.dart';

const _debugMode = false; // kDebugMode

///
/// [ChapterBuildHelper]
///
/// Note, a new [ChapterBuildHelper] should be created for each `TechHtml` widget build,
/// the same helper cannot be used for multiple widget builds.
///
class ChapterBuildHelper {
  final int volume;
  final List<String> versesToShow;

  ChapterBuildHelper(this.volume, this.versesToShow);

  TecHtmlTagElementFunc get tagHtmlElement => _tagHtmlElement;

  var _currentVerse = 0;
  var _currentWord = 0;
  int _currentEndVerse;
  var _isInVerse = false;
  var _isInNonVerseElement = false;
  var _nonVerseElementLevel = 0;
  var _wasInVerse = false;

  var _isInFootnote = false;
  var _footnoteElementLevel = 0;

  var _isInXref = false;
  var _xrefElementLevel = 0;

  String _href;

  ///
  /// Returns the VerseTag for the given HTML element.
  ///
  Object _tagHtmlElement(
    String name,
    LinkedHashMap<dynamic, String> attrs,
    String text,
    int level,
    bool isVisible,
  ) {
    if (_isInNonVerseElement && level <= _nonVerseElementLevel) {
      _isInNonVerseElement = false;
      _isInVerse = _wasInVerse;
    }

    // If in an xref, has it ended?
    if (_isInXref && level <= _xrefElementLevel) {
      _isInXref = false;
      _href = null;
    }

    // If in a footnote, has it ended?
    if (_isInFootnote && level <= _footnoteElementLevel) {
      _isInFootnote = false;
      _href = null;
    }

    // Is this the start of an xref or footnote?
    if (!_isInXref && attrs.className.contains('xref')) {
      _isInXref = true;
      _xrefElementLevel = level;
      _href = attrs['href'];
    } else if (!_isInFootnote && attrs.className.contains('FOOTNO')) {
      _isInFootnote = true;
      _footnoteElementLevel = level;
      _href = attrs['href'];
    }

    if (!_isInNonVerseElement) {
      final id = attrs.id;
      if (tec.isNotNullOrEmpty(id) &&
          name == 'div' &&
          (attrs.className == 'v' || attrs.className.startsWith('v '))) {
        final verse = int.tryParse(id);
        if (verse != null) {
          if (verse <= _currentVerse && isBibleId(volume)) {
            tec.dmPrint('ERROR: new verse # ($id) is <= previous verse # ($_currentVerse)');
            assert(false);
          }

          _isInVerse = true;
          _currentVerse = verse;
          _currentWord = 0;
          _currentEndVerse = int.tryParse(attrs['end'] ?? '');

          if (verse == 1 && isBibleId(volume)) {
            _currentWord++; // The old app has a chapter number, which is counted as a word.
          }
        }
      } else if (id == 'copyright' ||
          attrs['v'] == '0' ||
          _isSectionElement(name, attrs, level, isVisible)) {
        _wasInVerse = _isInVerse;
        _isInVerse = false;
        _isInNonVerseElement = true;
        _nonVerseElementLevel = level;
      }
    }

    var word = _currentWord;

    if (text?.isNotEmpty ?? false) {
      final wordCount = tec.countOfWordsInString(text);
      // tec.dmPrint('$wordCount words for text: $text');
      if (wordCount > 0) {
        word = _currentWord;
        _currentWord += wordCount;
        if (_debugMode) {
          if (wordCount == 1) {
            tec.dmPrint('verse: $_currentVerse, word $word: [$text]');
          } else {
            tec.dmPrint('verse: $_currentVerse, words $word-${word + wordCount - 1}: [$text]');
          }
        }
      }
    }

    return VerseTag(
      verse: _currentVerse,
      word: word,
      endVerse: _currentEndVerse,
      isInVerse: _isInVerse,
      isInXref: _isInXref,
      isInFootnote: _isInFootnote,
      href: _href,
    );
  }

  ///
  /// Returns null if `versesToShow` is empty, otherwise returns a func that
  /// returns `true` iff the visibility should be toggled for the given element.
  ///
  TecHtmlCheckElementFunc get toggleVisibility => (versesToShow?.isEmpty ?? true)
      ? null
      : (name, attrs, level, isVisible) {
          final id = attrs.id;
          if (tec.isNotNullOrEmpty(id) &&
              name == 'div' &&
              (attrs.className == 'v' || attrs.className.startsWith('v '))) {
            final toggle = (!isVisible && versesToShow.contains(id)) ||
                (isVisible && !versesToShow.contains(id));
            if (isVisible || toggle) {
              final v = int.tryParse(id);
              _skipSectionTitle = (v != null && !versesToShow.contains((v + 1).toString()));
            }
            return toggle;
          }
          return false;
        };

  ///
  /// Returns null if `versesToShow` is empty, otherwise returns a func that
  /// returns true iff the given element should be skipped.
  ///
  TecHtmlCheckElementFunc get shouldSkip => (versesToShow?.isEmpty ?? true)
      ? null
      : (name, attrs, level, isVisible) {
          return (isVisible &&
              _skipSectionTitle &&
              _isSectionElement(name, attrs, level, isVisible));
        };

  //
  // PRIVATE STUFF
  //

  var _skipSectionTitle = false;

  /// Returns a func that returns `true` iff the given element is a section element.
  TecHtmlCheckElementFunc get _isSectionElement => useZondervanCssWithVolume(volume)
      ? (name, attrs, level, isVisible) {
          return name == 'div' && (attrs.className == 'SUBA' || attrs.className == 'PARREF');
        }
      : (name, attrs, level, isVisible) {
          return name == 'h5';
        };
}

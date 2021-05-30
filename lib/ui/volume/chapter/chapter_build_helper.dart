import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../common/tec_overflow_box.dart';
import '../../learn/learn.dart';
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
  final BookChapterVerse ref;
  final List<String> versesToShow;
  final double textScaleFactor;
  final Map<int, Map<int, ResourceIntro>> studyCallouts;

  ChapterBuildHelper(
      this.volume, this.ref, this.studyCallouts, this.versesToShow, this.textScaleFactor) {
    _studyCalloutVerses = studyCallouts.keys.toList()..sort();
  }

  TecHtmlTagElementFunc get tagHtmlElement => _tagHtmlElement;

  var _currentVerse = 0;
  var _currentWord = 0;
  var _currentEndVerse = 0;
  var _isInVerse = false;
  var _isInNonVerseElement = false;
  var _nonVerseElementLevel = 0;
  var _wasInVerse = false;

  var _isInFootnote = false;
  var _footnoteElementLevel = 0;

  var _isInXref = false;
  var _xrefElementLevel = 0;

  String _href;

  // Study callout related:
  List<int> _studyCalloutVerses;
  var _studyCalloutVerseIndex = 0;
  var _usesParagraphs = false;

  ///
  /// Returns the VerseTag for the given HTML element.
  ///
  Object _tagHtmlElement(
    String name,
    LinkedHashMap<Object, String> attrs,
    String text,
    int level,
    bool isVisible,
  ) {
    bool classNameContains(String str) => attrs.className.contains(str);
    bool classNameStartsWith(String str) => attrs.className.startsWith(str);
    bool classNameEquals(String str) => attrs.className == str;

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
    if (!_isInXref && classNameContains('xref')) {
      _isInXref = true;
      _xrefElementLevel = level;
      _href = attrs['href'];
    } else if (!_isInFootnote && classNameContains('FOOTNO')) {
      _isInFootnote = true;
      _footnoteElementLevel = level;
      _href = attrs['href'];
    }

    if (!_isInNonVerseElement) {
      final id = attrs.id;
      if (isNotNullOrEmpty(id) &&
          name == 'div' &&
          (classNameEquals('v') || classNameStartsWith('v '))) {
        final verse = int.tryParse(id);
        if (verse != null) {
          if (verse <= _currentVerse && isBibleId(volume)) {
            dmPrint('ERROR: new verse # ($id) is <= previous verse # ($_currentVerse)');
            assert(false);
          }

          _isInVerse = true;
          _currentVerse = verse;
          _currentWord = 0;
          _currentEndVerse = int.tryParse(attrs['end'] ?? '') ?? verse;

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
      final wordCount = countOfWordsInString(text);
      // dmPrint('$wordCount words for text: $text');
      if (wordCount > 0) {
        word = _currentWord;
        _currentWord += wordCount;
        if (_debugMode) {
          if (wordCount == 1) {
            dmPrint('verse: $_currentVerse, word $word: [$text]');
          } else {
            dmPrint('verse: $_currentVerse, words $word-${word + wordCount - 1}: [$text]');
          }
        }
      }
    }

    // If this HTML element is a chapter number, return a chapter number widget.
    if (classNameEquals('cno') || classNameEquals('C')) {
      final fontSize = 63.0 * textScaleFactor;
      final height = fontSize;
      return Transform.translate(
        offset: Offset(0, TecPlatform.isIOS ? 0 : -(fontSize * 0.05).roundToDouble()),
        child: TecOverflowBox(
          minHeight: height,
          maxHeight: height,
          child: Container(
            padding: EdgeInsets.only(right: textScaleFactor * 8.0),
            child: Text(
              ref.chapter.toString(),
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: fontSize, fontFamily: 'Palatino'),
            ),
          ),
        ),
      );
    }

    final tag = VerseTag(
      verse: _currentVerse,
      word: word,
      endVerse: _currentEndVerse,
      isInVerse: _isInVerse,
      isInXref: _isInXref,
      isInFootnote: _isInFootnote,
      href: _href,
    );

    _usesParagraphs = _usesParagraphs || classNameEquals('poetry') || classNameEquals('para');

    // Insert a study callout?
    if (isBibleId(volume) &&
        _studyCalloutVerseIndex < _studyCalloutVerses.length &&
        _studyCalloutVerses[_studyCalloutVerseIndex] < _currentEndVerse &&
        (!_usesParagraphs ||
            name == 'h5' ||
            classNameEquals('poetry') ||
            classNameEquals('para'))) {
      final studyCalloutVerse = _studyCalloutVerses[_studyCalloutVerseIndex];
      _studyCalloutVerseIndex++;
      final callouts = studyCallouts[studyCalloutVerse];
      final studyVolumeId = callouts.keys.first;
      return [
        // const SizedBox(height: 10),
        _StudyCallout(
            textScaleFactor: textScaleFactor,
            book: ref.book,
            chapter: ref.chapter,
            verse: studyCalloutVerse,
            studyVolumeId: studyVolumeId,
            resourceIntro: callouts[studyVolumeId]),
        const SizedBox(height: 14),
        tag,
      ];
    }

    return tag;
  }

  ///
  /// Returns null if `versesToShow` is empty, otherwise returns a func that
  /// returns `true` iff the visibility should be toggled for the given element.
  ///
  TecHtmlCheckElementFunc get toggleVisibility => (versesToShow?.isEmpty ?? true)
      ? null
      : (name, attrs, level, isVisible) {
          final id = attrs.id;
          if (isNotNullOrEmpty(id) &&
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

class _StudyCallout extends StatelessWidget {
  final int book;
  final int chapter;
  final int verse;
  final int studyVolumeId;
  final ResourceIntro resourceIntro;
  final double textScaleFactor;

  const _StudyCallout({
    Key key,
    @required this.book,
    @required this.chapter,
    @required this.verse,
    @required this.studyVolumeId,
    @required this.resourceIntro,
    @required this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget text(String text) => Text(
          text ?? ' \n \n ',
          maxLines: 3,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: textScaleFactor,
          style: const TextStyle(color: Colors.orange, fontSize: 16),
        );

    return _Callout(
        child: text(resourceIntro.intro),
        onTap: () => showLearnWithReferences(
            [Reference(book: book, chapter: chapter, verse: verse)], context,
            volumeId: studyVolumeId));
  }
}

class _Callout extends StatelessWidget {
  final Widget child;
  final void Function() onTap;

  const _Callout({Key key, this.onTap, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: Color(0xffe0e0e0),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 12),
              const Icon(
                Icons.menu_book_outlined,
                size: 18,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

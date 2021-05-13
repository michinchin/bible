import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../common/common.dart';
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

  ChapterBuildHelper(this.volume, this.ref, this.versesToShow, this.textScaleFactor) {
    _studyCalloutVerse = ref.verse + 2 - _minVersesBetweenStudyCallouts;
  }

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

  // Study callout related:
  static const _minVersesBetweenStudyCallouts = 5;
  static const _studyCalloutMax = 1;
  var _studyCalloutCount = 0;
  var _studyCalloutVerse = 0;
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
            child: Text(ref.chapter.toString(),
                style: TextStyle(fontSize: fontSize, fontFamily: 'Palatino')),
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

    // Experimental: Insert a study content callout...
    if (isBibleId(volume) &&
        _studyCalloutCount < _studyCalloutMax &&
        _currentVerse >= _studyCalloutVerse + _minVersesBetweenStudyCallouts &&
        (!_usesParagraphs ||
            name == 'h5' ||
            classNameEquals('poetry') ||
            classNameEquals('para'))) {
      _studyCalloutCount++;
      _studyCalloutVerse = _currentVerse;
      return [
        // const SizedBox(height: 10),
        _Intro(
            textScaleFactor: textScaleFactor,
            book: ref.book,
            chapter: ref.chapter,
            verse: _studyCalloutVerse,
            volumes: const [1017]),
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

class _Intro extends StatelessWidget {
  final int book;
  final int chapter;
  final int verse;
  final List<int> volumes;
  final double textScaleFactor;

  const _Intro({Key key, this.book, this.chapter, this.verse, this.volumes, this.textScaleFactor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget text(String text) => Text(
          text ?? ' \n \n ',
          maxLines: 3,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.orange, fontSize: 16 * textScaleFactor),
        );

    return TecFutureBuilder<ErrorOrValue<Map<int, ResourceIntro>>>(
      futureBuilder: () => _IntroCache.shared.valueForKey(
          '$book $chapter $verse',
          (key) => VolumesRepository.shared.resourceIntros(
              reference: Reference(book: book, chapter: chapter, verse: verse), volumes: volumes)),
      builder: (context, result, error) {
        final finalError = error ?? result?.error;
        final intros = result?.value;
        if (intros == null || intros.isEmpty) {
          if (finalError != null || intros != null) {
            dmPrint(finalError != null
                ? 'ERROR getting study intros: $finalError'
                : 'No study intros for $chapter:$verse');
            return const SizedBox();
          }
          return _Callout(
            child: Stack(
              children: [
                text(null),
                Positioned.fill(
                    child: Center(
                  child:
                      finalError == null ? const LoadingIndicator() : Text(finalError.toString()),
                )),
              ],
            ),
          );
        } else {
          return _Callout(
              child: text(intros[intros.keys.first].intro),
              onTap: () => showLearnWithReferences(
                  [Reference(book: book, chapter: chapter, verse: verse)], context,
                  volumeId: 1017));
        }
      },
    );
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

class _IntroCache extends LruMemoryCache<ErrorOrValue<Map<int, ResourceIntro>>> {
  static final _IntroCache shared = _IntroCache(maxItems: 6);

  _IntroCache({int maxItems, Duration defaultExpiresIn})
      : super(maxItems: maxItems, defaultExpiresIn: defaultExpiresIn);
}

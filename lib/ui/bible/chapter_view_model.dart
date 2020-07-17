import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/color_utils.dart';

const _debugMode = false; // kDebugMode

///
/// BibleChapterViewModel
///
class BibleChapterViewModel {
  final int viewUid;
  final int volume;
  final int book;
  final int chapter;
  final List<String> Function() versesToShow;
  final ChapterHighlights Function() highlights;
  final TecSelectableController selectionController;
  final void Function(VoidCallback fn) refreshFunc;

  ///
  /// Returns a new [BibleChapterViewModel].
  ///
  /// Note, the [versesToShow] and [highlights] parameters are functions that will be called as
  /// needed to get the current value of the indicated property, since the property value can
  /// change between widget rebuilds.
  ///
  BibleChapterViewModel({
    @required this.viewUid,
    @required this.volume,
    @required this.book,
    @required this.chapter,
    @required this.versesToShow,
    @required this.highlights,
    @required this.selectionController,
    @required this.refreshFunc,
  }) : assert(volume != null &&
            book != null &&
            chapter != null &&
            versesToShow != null &&
            highlights != null &&
            selectionController != null &&
            refreshFunc != null);

  // ignore: use_to_and_as_if_applicable
  TecHtmlBuildHelper tecHtmlBuildHelper() => TecHtmlBuildHelper(this);

  // maintain a list of keys for footnotes, margin notes
  final widgetKeys = <String, GlobalKey>{};
  TapUpDetails tapUpDetails;

  // only call widgetHitTest from onTap (and set tapUpDetails in onTapUp)
  bool _widgetHitTest(double padding) {
    if (tapUpDetails != null && _selectedVerses.isEmpty) {
      final x = tapUpDetails.globalPosition.dx;
      final y = tapUpDetails.globalPosition.dy;

      // clear current details
      tapUpDetails = null;

      for (final key in widgetKeys.keys) {
        final renderBox = widgetKeys[key].currentContext?.findRenderObject();
        if (renderBox is RenderBox) {
          final position = renderBox.localToGlobal(Offset.zero);

          if (y < position.dy) {
            // don't bother checking rest of chapter... tap is above those...
            break;
          }

          final hit = x >= (position.dx - padding) &&
              x <= (position.dx + renderBox.size.width + padding) &&
              y >= (position.dy - padding) &&
              y <= (position.dy + renderBox.size.height + padding);

          if (hit) {
            if (widgetKeys[key].currentWidget is GestureDetector) {
              (widgetKeys[key].currentWidget as GestureDetector).onTap();
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  InlineSpan _footnoteSpan(BuildContext context, TextStyle style, _VerseTag tag, Key key) {
    // Example returning a WidgetSpan:
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    final iconWidth = (style.fontSize ?? 16.0) / 1.2;

    return TaggableWidgetSpan(
      alignment: PlaceholderAlignment.top,
      child: AbsorbPointer(
        absorbing: _selectedVerses.isNotEmpty,
        child: GestureDetector(
          key: key,
          child: Stack(children: <Widget>[
            Container(
              width: iconWidth,
              // use app settings height to determine correct line height
              height: AppSettings.shared.contentTextScaleFactor.value * 14.0,
              decoration: BoxDecoration(color: backgroundColor),
            ),
            SvgPicture.asset('assets/footnote.svg',
                width: iconWidth,
                height: iconWidth,
                color: Theme.of(context).accentColor,
                semanticsLabel: 'Footnote')
          ]),
          onTap: () {
            tecShowSimpleAlertDialog<void>(context: context, content: tag.href);
          },
        ),
      ),
      style: style,
      tag: tag,
    );
  }

  // Example returning a TextSpan:
  // return TaggableTextSpan(
  //   text: '* ',
  //   style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).accentColor),
  //   tag: tag,
  //   recognizer: TapGestureRecognizer()
  //     ..onTap = () {
  //       tecShowSimpleAlertDialog<void>(context: context, content: 'Footnote ${tag.href}');
  //     },
  // );

  ///
  /// Returns a TextSpan (or WidgetSpan) for the given HTML text node.
  ///
  InlineSpan spanForText(
    BuildContext context,
    String text,
    TextStyle style,
    Object tag,
    TextStyle selectedTextStyle, {
    bool isDarkTheme,
  }) {
    final tapPadding = MediaQuery.of(context).devicePixelRatio * 2.5;

    if (tag is _VerseTag && tag.isInFootnote && text != ' ') {
      // assign a unique key for this footnote
      // this can (is) called multiple times per footnote - just create one key
      if (!widgetKeys.containsKey('${tag.verse}-${tag.word}')) {
        widgetKeys['${tag.verse}-${tag.word}'] = GlobalKey();
      }

      return _footnoteSpan(context, style, tag, widgetKeys['${tag.verse}-${tag.word}']);
    }

    if (tag is _VerseTag) {
      final recognizer = tag.verse == null ? null : TapGestureRecognizer();
      recognizer?.onTapUp = (details) => tapUpDetails = details;
      recognizer?.onTap = () {
        if (!_widgetHitTest(tapPadding)) {
          _toggleSelectionForVerse(context, tag.verse);
        }
      };

      // If not in trial mode, and this whole verse is selected, just
      // return a span with the selected text style.
      if (!_isSelectionTrialMode && _selectedVerses.contains(tag.verse)) {
        return TaggableTextSpan(
            text: text,
            style: tag.isInVerse ? _merge(style, selectedTextStyle) : style,
            tag: tag,
            recognizer: recognizer);
      } else if (tag.verse != null) {
        final v = tag.verse;
        var currentWord = tag.word;
        final endWord = math.max(currentWord, currentWord + tec.countOfWordsInString(text) - 1);
        var remainingText = text;

        ///
        /// Local func that returns a new span from the `remainingText` up
        /// to and including the given [word], with the given [style]. And
        /// also updates `currentWord` and `remainingText` appropriately.
        ///
        InlineSpan _spanToWord(int word, TextStyle style) {
          final wordCount = (word - currentWord) + 1;
          final endIndex = remainingText.indexAtEndOfWord(wordCount);
          if (endIndex > 0 && endIndex <= remainingText.length) {
            final span = TaggableTextSpan(
                text: remainingText.substring(0, endIndex),
                style: style,
                tag: tag.copyWith(word: currentWord),
                recognizer: recognizer);
            remainingText = remainingText.substring(endIndex);
            currentWord += wordCount;
            return span;
          } else {
            tec.dmPrint('ERROR in _spanToWord! tag: $tag, word: $word, '
                'wordCount: $wordCount, endIndex: $endIndex, currentWord: $currentWord, '
                'remainingText: "$remainingText", text: "$text"');
            assert(false);
            return const TextSpan(text: 'FAILED!');
          }
        }

        // We're building a list of one or more spans...
        final spans = <InlineSpan>[];

        // Iterate through all the highlights for the words in the tag...
        for (final highlight
            in highlights().highlightsForVerse(v, startWord: tag.word, endWord: endWord)) {
          final hlStartWord = highlight.ref.startWordForVerse(v);
          final hlEndWord = highlight.ref.endWordForVerse(v);

          // If there are one or more words before the highlight, add them with the default style.
          if (currentWord < hlStartWord) {
            spans.add(_spanToWord(hlStartWord - 1, style));
          }

          var hlStyle = style;
          if (tag.isInVerse ||
              highlight.ref.word != Reference.minWord ||
              highlight.ref.endWord != Reference.maxWord) {
            final color = Color(highlight.color ?? 0xfff8f888);
            if (highlight.highlightType == HighlightType.underline) {
              hlStyle = _merge(
                  style,
                  TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: textColorWith(color, isDarkMode: isDarkTheme),
                      decorationThickness: 2));
            } else {
              hlStyle = _merge(
                  style,
                  isDarkTheme
                      ? TextStyle(color: textColorWith(color, isDarkMode: isDarkTheme))
                      : TextStyle(
                          backgroundColor: highlightColorWith(color, isDarkMode: isDarkTheme)));
            }
          }

          // Add the highlight words with the highlight style.
          spans.add(_spanToWord(hlEndWord, hlStyle));
        }

        // If there is still text left, add it with the default style.
        if (remainingText.isNotEmpty) {
          spans.add(TaggableTextSpan(
              text: remainingText,
              style: style,
              tag: tag.copyWith(word: currentWord),
              recognizer: recognizer));
        }

        return spans.length == 1 ? spans.first : TextSpan(children: spans, recognizer: recognizer);
      }
    }

    return TextSpan(text: text, style: style);
  }

  //-------------------------------------------------------------------------
  // Selection related:

  /// Returns `true` iff verses or words are selected.
  bool get hasSelection => hasVersesSelected || hasWordRangeSelected;

  /// Returns `true` iff one or more verses is selected.
  bool get hasVersesSelected => _selectedVerses.isNotEmpty;

  /// Returns `true` iff a word range is selected.
  bool get hasWordRangeSelected => _selectionStart != null;

  bool get isSelectionTrialMode => _isSelectionTrialMode;

  /// Call to clear all selections, if any.
  void clearAllSelections(BuildContext context) {
    selectionController.deselectAll();
    _clearAllSelectedVerses(context);
  }

  ///
  /// Handles the `TecSelectableController` `onSelectionChanged` callback.
  ///
  void onSelectionChanged(BuildContext context) {
    // If any words are selected, clear selected verses, if any.
    final isTextSelected = selectionController.isTextSelected;
    if (isTextSelected) _clearAllSelectedVerses(context);

    // Update _selectionStart and _selectionEnd.
    final start = selectionController.selectionStart;
    final end = selectionController.selectionEnd;
    if (start != null && end != null) {
      _selectionStart = start.tag is _VerseTag ? start : null;
      _selectionEnd = end.tag is _VerseTag ? end : null;
      if (_selectionStart == null || _selectionEnd == null) {
        _selectionStart = _selectionEnd = null;
        tec.dmPrint('ERROR, EITHER START OR END HAS INVALID TAG!');
        tec.dmPrint('START: $_selectionStart');
        tec.dmPrint('END:   $_selectionEnd');
        assert(false);
      } else {
        // tec.dmPrint('START: $_selectionStart');
        // tec.dmPrint('END:   $_selectionEnd');
      }
    } else {
      _selectionStart = _selectionEnd = null;
      // tec.dmPrint('No words selected.');
    }

    // Notify the view manager, if there is one.
    context
        .bloc<ViewManagerBloc>()
        ?.notifyOfSelectionsInViewWithUid(viewUid, context, hasSelections: hasSelection);
  }

  ///
  /// Handles selection style changed events.
  ///
  void selectionStyleChanged(
      BuildContext context, SelectionStyle selectionStyle, int volume, int book, int chapter) {
    final bloc = context.bloc<ChapterHighlightsBloc>(); // ignore: close_sinks

    if (bloc == null || !hasSelection) return;
    _isSelectionTrialMode = selectionStyle.isTrialMode;

    final ref = _selectedVerses.isNotEmpty
        ? _referenceWithVerses(_selectedVerses, volume: volume, book: book, chapter: chapter)
        : Reference(
            volume: volume,
            book: book,
            chapter: chapter,
            verse: _selectionStart.verse,
            word: _selectionStart.word,
            endVerse: _selectionEnd.verse,
            endWord: math.max(_selectionStart.word, _selectionEnd.word - 1));

    if (!_isSelectionTrialMode) {
      clearAllSelections(context);
    } else if (hasWordRangeSelected) {
      refreshFunc(() {});
    }

    if (selectionStyle.type == HighlightType.clear) {
      bloc.add(HighlightsEvent.clear(ref));
    } else {
      bloc.add(
          HighlightsEvent.add(type: selectionStyle.type, color: selectionStyle.color, ref: ref));
    }
  }

  //
  // PRIVATE STUFF
  //

  var _isSelectionTrialMode = false;

  TaggedText _selectionStart;
  TaggedText _selectionEnd;

  final _selectedVerses = <int>{};

  void _toggleSelectionForVerse(BuildContext context, int verse) {
    assert(verse != null);
    _updateSelectedVersesInBlock(() {
      if (!_selectedVerses.remove(verse)) _selectedVerses.add(verse);
    }, context);
  }

  void _clearAllSelectedVerses(BuildContext context) {
    if (_selectedVerses.isEmpty) return;
    _updateSelectedVersesInBlock(_selectedVerses.clear, context);
  }

  void _updateSelectedVersesInBlock(void Function() block, BuildContext context) {
    final wasTextSelected = _selectedVerses.isNotEmpty;
    refreshFunc(block);
    tec.dmPrint('selected verses: $_selectedVerses');
    final isTextSelected = _selectedVerses.isNotEmpty;
    if (wasTextSelected != isTextSelected) {
      context
          .bloc<ViewManagerBloc>()
          ?.notifyOfSelectionsInViewWithUid(viewUid, context, hasSelections: hasSelection);
    }
  }
}

///
/// [TecHtmlBuildHelper]
///
/// Note, a new [TecHtmlBuildHelper] should be created for each `TechHtml` widget build,
/// the same helper cannot be used for multiple widget builds.
///
class TecHtmlBuildHelper {
  final BibleChapterViewModel viewModel;

  TecHtmlBuildHelper(this.viewModel);

  TecHtmlTagElementFunc get tagHtmlElement => _tagHtmlElement;

  var _currentVerse = 1;
  var _currentWord = 0;
  var _isInVerse = false;
  var _isInNonVerseElement = false;
  var _nonVerseElementLevel = 0;
  var _wasInVerse = false;

  var _isInFootnote = false;
  var _isInXref = false;
  var _xrefElementLevel = 0;

  String _href;

  ///
  /// Returns the _VerseTag for the given HTML element.
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
      _isInFootnote = false;
      _href = null;
    }

    if (_isInXref && level <= _xrefElementLevel) {
      _isInXref = false;
      _href = null;
    } else if (!_isInXref && attrs.className.contains('xref')) {
      _isInXref = true;
      _xrefElementLevel = level;
      _href = attrs['href'];
    }

    if (!_isInNonVerseElement) {
      final id = attrs.id;
      if (tec.isNotNullOrEmpty(id) &&
          name == 'div' &&
          (attrs.className == 'v' || attrs.className.startsWith('v '))) {
        final verse = int.tryParse(id);
        if (verse != null) {
          _isInVerse = true;
          if (verse > _currentVerse) {
            _currentVerse = verse;
            _currentWord = 0;
          } else if (verse == 1) {
            _currentWord++; // The old app has a chapter number, which is counted as a word.
          } else {
            tec.dmPrint('ERROR: new verse # ($id) is <= previous verse # ($_currentVerse)');
            assert(false);
          }
        }
      } else if (id == 'copyright' ||
          attrs['v'] == '0' ||
          _isSectionElement(name, attrs, level, isVisible)) {
        _wasInVerse = _isInVerse;
        _isInVerse = false;
        _isInNonVerseElement = true;
        _nonVerseElementLevel = level;

        if (attrs.className.contains('FOOTNO')) {
          _isInFootnote = true;
          _href = attrs['href'];
        }
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

    return _VerseTag(
      verse: _currentVerse,
      word: word,
      isInVerse: _isInVerse,
      isInXref: _isInXref,
      isInFootnote: _isInFootnote,
      href: _href,
    );
  }

  ///
  /// Returns null if viewModel.versesToShow() is empty, otherwise returns a func that
  /// returns `true` iff the visibility should be toggled for the given element.
  ///
  TecHtmlCheckElementFunc get toggleVisibility => viewModel.versesToShow().isEmpty
      ? null
      : (name, attrs, level, isVisible) {
          final id = attrs.id;
          if (tec.isNotNullOrEmpty(id) &&
              name == 'div' &&
              (attrs.className == 'v' || attrs.className.startsWith('v '))) {
            final toggle = (!isVisible && viewModel.versesToShow().contains(id)) ||
                (isVisible && !viewModel.versesToShow().contains(id));
            if (isVisible || toggle) {
              final v = int.tryParse(id);
              _skipSectionTitle =
                  (v != null && !viewModel.versesToShow().contains((v + 1).toString()));
            }
            return toggle;
          }
          return false;
        };

  ///
  /// Returns null if viewModel.versesToShow() is empty, otherwise returns a func that
  /// returns true iff the given element should be skipped.
  ///
  TecHtmlCheckElementFunc get shouldSkip => viewModel.versesToShow().isEmpty
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
  TecHtmlCheckElementFunc get _isSectionElement => useZondervanCss(viewModel.volume)
      ? (name, attrs, level, isVisible) {
          return name == 'div' && (attrs.className == 'SUBA' || attrs.className == 'PARREF');
        }
      : (name, attrs, level, isVisible) {
          return name == 'h5';
        };
}

//
// UTILITY FUNCTIONS
//

///
/// Returns `true` if the Zondervan CSS should be used for the given [volume].
///
bool useZondervanCss(int volume) => (volume == 32);

//
// PRIVATE STUFF
//

///
/// Returns the merged result of two [TextStyle]s, and either, or both, can be `null`.
///
TextStyle _merge(TextStyle s1, TextStyle s2) => s1 == null ? s2 : s2 == null ? s1 : s1.merge(s2);

///
/// Returns a new [Reference] from the given set of [verses] and other optional parameters.
///
Reference _referenceWithVerses(
  Set<int> verses, {
  int volume,
  int book,
  int chapter,
  DateTime modified,
}) {
  if (verses?.isEmpty ?? true) return null;
  final sorted = List.of(verses)..sort();
  final first = sorted.first;
  final last = sorted.last;
  final excluded = sorted.missingValues();
  return Reference(
      volume: volume,
      book: book,
      chapter: chapter,
      verse: first,
      endVerse: last,
      excluded: excluded.isEmpty ? null : excluded.toSet(),
      modified: modified);
}

extension ChapterViewModelExtOnIterableInt on Iterable<int> {
  ///
  /// With a sorted list of ints, returns the ints that are missing from the list.
  ///
  Iterable<int> missingValues() {
    int prevValue;
    return expand((e) {
      // Save the current value of `prevValue` for use in the generator block. This must be done
      // because `Iterable<int>.generate` generates its elements dynamically, which means that
      // its generator function is not called now, it is called later, when, and if, needed. So,
      // if we used `prevValue` in the generator block, it would be using the future value
      // of `prevValue`, not the current value, which would make the block return the wrong value.
      final bakedPrevValue = prevValue;
      final values = Iterable<int>.generate(
        e - (prevValue ?? e) - 1,
        (i) => i + bakedPrevValue + 1,
      );
      prevValue = e;
      return values;
    });
  }
}

///
/// [_VerseTag]
///
/// Used to tag an HTML text node with the [verse] it is in, the [word] index
/// of the first word in the text node, and a boolean indicating whether or not
/// the associated text node is part of the actual verse text (as apposed to
/// being the verse number, a footnote, a section title, or other text marked
/// with v="0").
///
@immutable
class _VerseTag {
  final int verse;
  final int word;
  final bool isInVerse;
  final bool isInXref;
  final bool isInFootnote;
  final String href;

  const _VerseTag({
    @required this.verse,
    @required this.word,
    this.isInVerse = false,
    this.isInXref = false,
    this.isInFootnote = false,
    this.href,
  }) : assert(verse != null &&
            word != null &&
            isInVerse != null &&
            isInXref != null &&
            isInFootnote != null);

  _VerseTag copyWith({
    int verse,
    int word,
    bool isInVerse,
    bool isInXref,
    bool isInFootnote,
    String href,
  }) =>
      _VerseTag(
        verse: verse ?? this.verse,
        word: word ?? this.word,
        isInVerse: isInVerse ?? this.isInVerse,
        isInXref: isInXref ?? this.isInXref,
        isInFootnote: isInFootnote ?? this.isInFootnote,
        href: href ?? this.href,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _VerseTag &&
          runtimeType == other.runtimeType &&
          verse == other.verse &&
          word == other.word &&
          isInVerse == other.isInVerse;

  @override
  int get hashCode => verse.hashCode ^ word.hashCode ^ isInVerse.hashCode;

  @override
  String toString() {
    return ('{ "v": $verse, "w": $word, "inV": $isInVerse }');
  }
}

extension on TaggedText {
  int get verse => (tag is _VerseTag) ? (tag as _VerseTag).verse : null;

  int get word {
    final t = tag;
    if (t is _VerseTag) {
      final words = text?.countOfWords(toIndex: index) ?? 0;
      return t.word + words;
    }
    return null; // ignore: avoid_returning_null
  }
}

extension ChapterViewModelExtOnString on String {
  ///
  /// Returns the count of words in the string. If [toIndex] if provided, returns the count of
  /// words up to, but not including, that index.
  ///
  /// Note, if [toIndex] is provided, and [toIndex] is in the middle of a word, that word is
  /// not counted. For example, if the string is 'cat dog', and [toIndex] is 0, 1, or 2, the
  /// function returns 0. If [toIndex] is 3, 4, 5, or 6, the function returns 1. If [toIndex]
  /// is 7 or null, the function returns 2.
  ///
  int countOfWords({int toIndex}) {
    var count = 0;
    var isInWord = false;
    var i = 0;
    final units = codeUnits;
    for (final codeUnit in units) {
      final isWhitespace = tec.isWhitespace(codeUnit);
      if (isInWord) {
        if (isWhitespace) {
          isInWord = false;
          count++;
        }
      } else if (!isWhitespace) {
        isInWord = true;
      }
      if (toIndex != null && i >= toIndex) break;
      i++;
    }
    if (isInWord && i >= units.length) count++;
    return count;
  }

  ///
  /// Returns the index at the end of the given word.
  ///
  int indexAtEndOfWord(int word) {
    if (word == null || word <= 0) return 0;
    var wordCount = 0;
    var isInWord = false;
    var i = 0;
    final units = codeUnits;
    for (final codeUnit in units) {
      final isWhitespace = tec.isWhitespace(codeUnit);
      if (isInWord) {
        if (isWhitespace) {
          isInWord = false;
          if (word == wordCount) return i;
        }
      } else if (!isWhitespace) {
        wordCount++;
        isInWord = true;
      }
      i++;
    }
    return i;
  }
}
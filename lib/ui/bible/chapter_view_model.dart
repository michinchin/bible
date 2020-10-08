import 'dart:collection';
import 'dart:math' as math;

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/content_settings.dart';
import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/margin_notes/margin_notes_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/color_utils.dart';
import '../note/margin_note_view.dart';

const _debugMode = false; // kDebugMode

///
/// ChapterViewModel
///
class ChapterViewModel {
  final int viewUid;
  final int volume;
  final int book;
  final int chapter;
  final List<String> Function() versesToShow;
  final ChapterHighlights Function() highlights;
  final ChapterMarginNotes Function() marginNotes;
  final TecSelectableController selectionController;
  final void Function(VoidCallback fn) refreshFunc;

  ///
  /// Returns a new [ChapterViewModel].
  ///
  /// Note, the [versesToShow] and [highlights] parameters are functions that will be called as
  /// needed to get the current value of the indicated property, since the property value can
  /// change between widget rebuilds.
  ///
  ChapterViewModel({
    @required this.viewUid,
    @required this.volume,
    @required this.book,
    @required this.chapter,
    @required this.versesToShow,
    @required this.highlights,
    @required this.marginNotes,
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

  // Maintain a list of keys for footnotes, margin notes, ...
  final _widgetKeys = <String, GlobalKey>{};

  var _marginNoteVerse = 0;
  String _currentFootnoteHref;

  Color _backgroundColor(bool isDarkTheme) {
    return isDarkTheme ? Colors.black : Colors.white;
  }

  Stopwatch _tapDownStopwatch;
  Object _tapDownTag;
  TapUpDetails _tapUpDetails;

  void _onTappedSpanWithTag(BuildContext context, Object tag) {
    if (tag is _VerseTag) {
      var handledTap = false;

      // Was it a long press on an xref?
      if (!handledTap &&
          tag.isInXref &&
          tec.isNotNullOrEmpty(tag.href) &&
          _tapDownStopwatch.elapsed.inMilliseconds > 500 &&
          _tapDownTag is _VerseTag &&
          (_tapDownTag as _VerseTag).href == tag.href) {
        handledTap = true;
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (builder) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              content: TecHtml('<p>${tag.href}</p>', baseUrl: '', selectable: false),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          },
        );
      }

      // Was the tap near a margin note or footnote widget?
      // Note, `_tapUpDetails` is set in the `onTapUp` handler.
      if (!handledTap && !hasSelection && _tapUpDetails != null) {
        final x = _tapUpDetails.globalPosition.dx;
        final y = _tapUpDetails.globalPosition.dy;

        final padding = MediaQuery.of(context).devicePixelRatio * 2.5;

        for (final key in _widgetKeys.keys) {
          final renderBox = _widgetKeys[key].currentContext?.findRenderObject();
          if (renderBox is RenderBox) {
            final position = renderBox.localToGlobal(Offset.zero);

            // If the tap is above widget, don't bother checking the rest of the widgets.
            if (y < position.dy) break;

            final hit = x >= (position.dx - padding) &&
                x <= (position.dx + renderBox.size.width + padding) &&
                y >= (position.dy - padding) &&
                y <= (position.dy + renderBox.size.height + padding);

            if (hit) {
              if (_widgetKeys[key].currentWidget is GestureDetector) {
                // this is a widget hit - execute the tap...
                (_widgetKeys[key].currentWidget as GestureDetector).onTap();
                handledTap = true;
                break;
              }
            }
          }
        }
      }

      // If the tap hasn't been handled yet and this is a bible, toggle verse selection.
      if (!handledTap && volume < 1000) _toggleSelectionForVerse(context, tag.verse);
    }

    _tapDownStopwatch?.stop();
    _tapDownStopwatch = null;
    _tapDownTag = null;
    _tapUpDetails = null;
  }

  InlineSpan _marginNoteSpan(
      BuildContext context, TextStyle style, _VerseTag tag, Key key, bool isDarkTheme) {
    final color = isDarkTheme ? const Color(0xFFFAFAFA) : const Color(0xFFA1090E);
    final iconWidth = (style.fontSize ?? 16.0) / 1.2;
    final widgetWidth = iconWidth;

    void _onPress() {
      if (hasSelection) {
        TecToast.show(context, 'Clear selection to view margin note');
        // not sure if I want to force this...
        // _toggleSelectionForVerse(context, tag.verse);
      } else {
        final vmBloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
        final position = vmBloc?.indexOfView(viewUid) ?? -1;
        final mn = marginNotes().marginNoteForVerse(tag.verse);
        vmBloc?.add(ViewManagerEvent.add(
            type: marginNoteViewType,
            data: tec.toJsonString(mn.stateJson()),
            position: position == -1 ? null : position + 1));
      }
    }

    return TaggableWidgetSpan(
      alignment: PlaceholderAlignment.middle,
      childWidth: widgetWidth,
      child: Transform.translate(
        offset: Offset(-iconWidth / 4.5, 0),
        child: GestureDetector(
          key: key,
          child: Container(
            width: widgetWidth,
            // use app settings height to determine correct line height
            height: context.bloc<ContentSettingsBloc>().state.textScaleFactor * 18.0,
            decoration: BoxDecoration(color: _backgroundColor(isDarkTheme)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: kIsWeb
                    ? Icon(
                        FeatherIcons.fileText,
                        size: iconWidth,
                        color: color,
                        semanticLabel: 'Margin Note',
                      )
                    : SvgPicture.asset('assets/marginNote.svg',
                        width: iconWidth,
                        height: iconWidth,
                        color: color,
                        semanticsLabel: 'Margin Note'),
              ),
            ),
          ),
          onTap: _onPress,
          onLongPress: _onPress,
        ),
      ),
    );
  }

  InlineSpan _footnoteSpan(
      BuildContext context, TextStyle style, _VerseTag tag, Key key, bool isDarkTheme) {
    final iconWidth = (style.fontSize ?? 16.0) * 0.6;
    final containerWidth = iconWidth + 4.0; // small right padding

    Future<void> _onPress() async {
      final bible = VolumesRepository.shared.bibleWithId(volume);
      final footnoteHtml =
          await bible.footnoteHtmlWith(book, chapter, int.parse(tag.href.split('_').last));
      if (tec.isNotNullOrEmpty(footnoteHtml.value)) {
        if (hasSelection) {
          TecToast.show(context, 'Clear selection to view footnote');
          // not sure if I want to force this...
          // _toggleSelectionForVerse(context, tag.verse);
        } else {
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (builder) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(0),
                content: TecHtml(footnoteHtml.value, baseUrl: '', selectable: false),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              );
            },
          );
        }
      } else if (tec.isNullOrEmpty(footnoteHtml.error)) {
        tec.dmPrint('ERROR: ${footnoteHtml?.error}');
      }
    }

    return TaggableWidgetSpan(
      alignment: PlaceholderAlignment.top,
      childWidth: containerWidth,
      child: GestureDetector(
        key: key,
        child: Container(
          width: containerWidth,
          // use app settings height to determine correct line height
          height: context.bloc<ContentSettingsBloc>().state.textScaleFactor * 18.0,
          decoration: BoxDecoration(color: _backgroundColor(isDarkTheme)),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: kIsWeb
                    ? Icon(
                        Icons.ac_unit,
                        size: iconWidth,
                        color: Theme.of(context).accentColor,
                        semanticLabel: 'Footnote',
                      )
                    : SvgPicture.asset('assets/footnote.svg',
                        width: iconWidth,
                        height: iconWidth,
                        color: Theme.of(context).accentColor,
                        semanticsLabel: 'Footnote')),
          ),
        ),
        onTap: _onPress,
        onLongPress: _onPress,
      ),
    );
  }

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
    if (tag is _VerseTag && tag.isInFootnote) {
      if (tag.href != _currentFootnoteHref) {
        _currentFootnoteHref = tag.href;

        // Assign a unique key for this footnote.
        final key = '${tag.verse}-${tag.word}';
        _widgetKeys[key] ??= GlobalKey();
        return _footnoteSpan(context, style, tag, _widgetKeys[key], isDarkTheme);
      }

      return null;
    }

    if (tag is _VerseTag) {
      final recognizer = tag.verse == null ? null : TapGestureRecognizer();
      if (recognizer != null) {
        recognizer
          ..onTapDown = (details) {
            _tapDownStopwatch = Stopwatch()..start();
            _tapDownTag = tag;
          }
          ..onTapUp = (details) {
            _tapUpDetails = details;
          }
          ..onTap = () => _onTappedSpanWithTag(context, tag);
      }

      // We're building a list of one or more spans...
      final spans = <InlineSpan>[];

      // Margin note icons are placed before the first "inVerse" span of a verse...
      if (tag.verse != null && _marginNoteVerse != tag.verse && tag.isInVerse) {
        _marginNoteVerse = tag.verse;

        if (marginNotes().hasMarginNoteForVerse(_marginNoteVerse)) {
          // Assign a unique key for this margin note.
          final key = 'mn${tag.verse}';
          _widgetKeys[key] ??= GlobalKey();
          spans.add(_marginNoteSpan(context, style, tag, _widgetKeys[key], isDarkTheme));
        }
      }

      var textStyle = style;

      // If in xref, add xref styling to the span:
      if (tag.isInXref) {
        textStyle = textStyle.merge(TextStyle(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: textStyle.color ?? Colors.blueAccent));
      }

      // If not in trial mode, and this whole verse is selected, just
      // return a span with the selected text style.
      if (!_isSelectionTrialMode && _selectedVerses.contains(tag.verse)) {
        final textSpan = TaggableTextSpan(
            text: text,
            style: tag.isInVerse ? _merge(textStyle, selectedTextStyle) : textStyle,
            tag: tag,
            recognizer: recognizer);
        if (spans.isEmpty) {
          return textSpan;
        } else {
          spans.add(textSpan);
          return TextSpan(children: spans, recognizer: recognizer);
        }
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
        InlineSpan _spanToWord(int word, TextStyle textStyle) {
          final wordCount = (word - currentWord) + 1;
          final endIndex = remainingText.indexAtEndOfWord(wordCount);
          if (endIndex > 0 && endIndex <= remainingText.length) {
            final span = TaggableTextSpan(
                text: remainingText.substring(0, endIndex),
                style: textStyle,
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

        // Iterate through all the highlights for the words in the tag...
        for (final highlight
            in highlights().highlightsForVerse(v, startWord: tag.word, endWord: endWord)) {
          final hlStartWord = highlight.ref.startWordForVerse(v);
          final hlEndWord = highlight.ref.endWordForVerse(v);

          // If there are one or more words before the highlight, add them with the default style.
          if (currentWord < hlStartWord) {
            spans.add(_spanToWord(hlStartWord - 1, textStyle));
          }

          var hlStyle = textStyle;
          if (tag.isInVerse ||
              highlight.ref.word != Reference.minWord ||
              highlight.ref.endWord != Reference.maxWord) {
            final color = Color(highlight.color ?? 0xfff8f888);
            if (highlight.highlightType == HighlightType.underline) {
              hlStyle = _merge(
                  hlStyle,
                  TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: textColorWith(color, isDarkMode: isDarkTheme),
                      decorationThickness: 2));
            } else {
              hlStyle = _merge(
                  hlStyle,
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
              style: textStyle,
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

  void notifyOfSelections(BuildContext context) {
    // Notify the view manager, if there is one.
    context.bloc<ViewManagerBloc>()?.notifyOfSelectionsInView(viewUid, _selectionReference, context,
        hasSelections: hasSelection);
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

    notifyOfSelections(context);
  }

  /// Returns the current selection reference, or null if nothing is selected.
  Reference get _selectionReference => _selectedVerses.isNotEmpty
      ? _referenceWithVerses(_selectedVerses, volume: volume, book: book, chapter: chapter)
      : hasWordRangeSelected
          ? Reference(
              volume: volume,
              book: book,
              chapter: chapter,
              verse: _selectionStart.verse,
              word: _selectionStart.word,
              endVerse: _selectionEnd.verse,
              endWord: math.max(_selectionStart.word, _selectionEnd.word - 1))
          : null;

  ///
  /// Handles selection style changed events.
  ///
  void selectionStyleChanged(
      BuildContext context, SelectionStyle selectionStyle, int volume, int book, int chapter) {
    final bloc = context.bloc<ChapterHighlightsBloc>(); // ignore: close_sinks

    if (bloc == null || !hasSelection) return;
    final mode = (selectionStyle.isTrialMode) ? HighlightMode.trial : HighlightMode.save;

    // when color picker exists with "cancel(clear)" - style is in preview mode, but trial is over
    _isSelectionTrialMode =
        selectionStyle.isTrialMode && selectionStyle.type != HighlightType.clear;

    final ref = _selectionReference;

    if (!_isSelectionTrialMode) {
      clearAllSelections(context);
    } else if (hasWordRangeSelected) {
      refreshFunc(() {});
    }

    if (selectionStyle.type == HighlightType.clear) {
      bloc.add(HighlightEvent.clear(ref, mode));
    } else {
      bloc.add(HighlightEvent.add(
        type: selectionStyle.type,
        color: selectionStyle.color,
        ref: ref,
        mode: mode,
      ));
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
    TecAutoScroll.stopAutoscroll();
    _updateSelectedVersesInBlock(() {
      if (!_selectedVerses.remove(verse)) _selectedVerses.add(verse);
    }, context);
  }

  void _clearAllSelectedVerses(BuildContext context) {
    TecAutoScroll.stopAutoscroll();
    if (_selectedVerses.isEmpty) return;
    _updateSelectedVersesInBlock(_selectedVerses.clear, context);
  }

  void _updateSelectedVersesInBlock(void Function() block, BuildContext context) {
    TecAutoScroll.stopAutoscroll();
    refreshFunc(block);
    tec.dmPrint('selected verses: $_selectedVerses');
    notifyOfSelections(context);
  }
}

///
/// [TecHtmlBuildHelper]
///
/// Note, a new [TecHtmlBuildHelper] should be created for each `TechHtml` widget build,
/// the same helper cannot be used for multiple widget builds.
///
class TecHtmlBuildHelper {
  final ChapterViewModel viewModel;

  TecHtmlBuildHelper(this.viewModel);

  TecHtmlTagElementFunc get tagHtmlElement => _tagHtmlElement;

  var _currentVerse = 1;
  var _currentWord = 0;
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
    }

    // NOTE: footnotes and xrefs should NOT be nested

    // if we are in an xref - do we need to end it?
    if (_isInXref && level <= _xrefElementLevel) {
      _isInXref = false;
      _href = null;
    }

    // if we are in a footnote - do we need to end it?
    else if (_isInFootnote && level <= _footnoteElementLevel) {
      _isInFootnote = false;
      _href = null;
    }

    // do we need to start an xref or footnote
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
  TecHtmlCheckElementFunc get _isSectionElement => useZondervanCssWithVolume(viewModel.volume)
      ? (name, attrs, level, isVisible) {
          return name == 'div' && (attrs.className == 'SUBA' || attrs.className == 'PARREF');
        }
      : (name, attrs, level, isVisible) {
          return name == 'h5';
        };
}

//
// PRIVATE STUFF
//

///
/// Returns the merged result of two [TextStyle]s, and either, or both, can be `null`.
///
TextStyle _merge(TextStyle s1, TextStyle s2) => s1 == null
    ? s2
    : s2 == null
        ? s1
        : s1.merge(s2);

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

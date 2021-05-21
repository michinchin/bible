import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:float_column/float_column.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_selectable/tec_selectable.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../../blocs/highlights/highlights_bloc.dart';
import '../../../blocs/margin_notes/margin_notes_bloc.dart';
import '../../../blocs/selection/selection_bloc.dart';
import '../../../models/app_settings.dart';
import '../../../models/color_utils.dart';
import '../../../models/const.dart';
import '../../../models/string_utils.dart';
import '../../common/common.dart';
import 'chapter_selection.dart';
import 'verse_tag.dart';

const _despanifyChapterHtml = false;
const _superscriptVerseNumbers = true; // kDebugMode;

const _footnote = '\u2060\ue900';
const _footnoteStyle = TextStyle(fontFamily: 'tec_icons', color: Colors.blue, height: 1);

const _marginNote = '\ue901';
const _marginNoteLightStyle =
    TextStyle(fontFamily: 'tec_icons', color: Color(0xFFA1090E), height: 1);
const _marginNoteDarkStyle =
    TextStyle(fontFamily: 'tec_icons', color: Color(0xFFFAFAFA), height: 1);

const _space = '\u0020'; // regular space
const _nbsp = '\u00A0'; // non-breaking space

///
/// ChapterViewModel
///
class ChapterViewModel {
  final GlobalKey globalKey;
  final int viewUid;
  final int volume;
  final int book;
  final int chapter;
  final ChapterHighlights Function() highlights;
  final ChapterMarginNotes Function() marginNotes;
  final ChapterSelection selection;

  ///
  /// Returns a new [ChapterViewModel].
  ///
  /// Note, the [highlights] and [marginNotes] parameters are functions that will be called
  /// as needed to get the current value, since the value can change between widget rebuilds.
  ///
  ChapterViewModel({
    @required this.globalKey,
    @required this.viewUid,
    @required this.volume,
    @required this.book,
    @required this.chapter,
    @required this.highlights,
    @required this.marginNotes,
    @required this.selection,
  }) : assert(volume != null && book != null && chapter != null && highlights != null);

  ///
  /// Returns a TextSpan, WidgetSpan, or `null` for the given HTML text node.
  /// If `null` is returned, the text node will be ignored.
  ///
  InlineSpan spanForText(
    BuildContext context,
    String text,
    TextStyle style,
    Object tag,
    TextStyle selectedTextStyle, {
    @required bool isDarkTheme,
  }) {
    if (tag is VerseTag) {
      // Note, `v` will be `null` if not in a verse.
      final v = tag.verse;

      // If it is the verse number span, superscript it.
      if (_superscriptVerseNumbers && v != null && !tag.isInVerse && text.startsWithDigit) {
        final vStr = v.toString();
        final l = vStr.length;
        if (text.startsWith(vStr) &&
            (text.length == vStr.length || !text.substring(l, l + 1).startsWithDigit)) {
          return TaggableTextSpan(tag: tag, text: text.superscripted(), style: style);
        }
      }

      // If it's a footnote, just return the special footnote span.
      if (tag.isInFootnote) {
        if (tag.href != _currentFootnoteHref) {
          _currentFootnoteHref = tag.href;
          return TaggableTextSpan(tag: tag, text: _footnote, style: _footnoteStyle);
        }
        return null; // Don't display the footnote letter.
      }

      // The rest of the function builds a list of zero or more spans.
      final spans = <InlineSpan>[];

      // If the verse has a margin note, add the special margin note span.
      if (v != null &&
          v != _marginNoteVerse &&
          tag.isInVerse &&
          text.isNotEmpty &&
          text != _space &&
          text != _nbsp) {
        _marginNoteVerse = v;
        if (marginNotes().hasMarginNoteForVerse(_marginNoteVerse)) {
          spans.add(TaggableTextSpan(
              tag: tag.copyWith(isInMarginNote: true),
              text: '$_marginNote$_nbsp',
              style: style.merge(isDarkTheme ? _marginNoteDarkStyle : _marginNoteLightStyle)));
        }
      }

      final recognizer = _recognizerWith(context, tag);
      var textStyle = style;
      var remainingText = text;

      // If in xref, add xref styling to the span:
      if (tag.isInXref && isNotNullOrEmpty(tag.href)) {
        // We don't want leading spaces to have the xref style...
        if (_prevTagXrefHref != tag.href) {
          final index = remainingText.indexAtWord(1);
          if (index > 0) {
            final whitespace = remainingText.substring(0, index);
            remainingText = remainingText.substring(index);
            final wsSpans = _spansForText(tag, whitespace, style, selectedTextStyle, recognizer,
                isDarkTheme: isDarkTheme);
            if (wsSpans.length > 1) {
              dmPrint('_spansForText returned ${wsSpans.length} spans for "$whitespace"!');
            }
            spans.addAll(wsSpans);
          }
        }

        _prevTagXrefHref = tag.href;

        if (remainingText.isNotEmpty) {
          textStyle = textStyle.merge(TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: textStyle.color ?? Colors.blueAccent));
        }
      } else {
        _prevTagXrefHref = '';
      }

      if (remainingText.isNotEmpty) {
        spans.addAll(_spansForText(tag, remainingText, textStyle, selectedTextStyle, recognizer,
            isDarkTheme: isDarkTheme));
      }

      return spans.isEmpty
          ? null
          : spans.length == 1
              ? spans.first
              : TextSpan(children: spans, recognizer: recognizer);
    }

    return TextSpan(text: text, style: style);
  }

  //
  // PRIVATE STUFF
  //

  Iterable<InlineSpan> _spansForText(
    VerseTag tag,
    String text,
    TextStyle textStyle,
    TextStyle selectedTextStyle,
    TapGestureRecognizer recognizer, {
    @required bool isDarkTheme,
  }) {
    if (text.isNotEmpty) {
      // If not in trial mode, and the whole verse is selected...
      if (!selection.isInTrialMode && selection.hasVerse(tag.verse)) {
        _clearPreviousHighlightValues();
        return [
          TaggableTextSpan(
              text: text,
              style: tag.isInVerse ? _merge(textStyle, selectedTextStyle) : textStyle,
              tag: tag,
              recognizer: recognizer)
        ];
      } else if (tag.verse != null) {
        return _spansForHighlights(tag, text, textStyle, recognizer, isDarkTheme: isDarkTheme);
      }
    }
    return [];
  }

  TapGestureRecognizer _recognizerWith(BuildContext context, VerseTag tag) {
    return null;
    /*
    final recognizer = (tag.verse == null ? null : TapGestureRecognizer());
    if (recognizer != null) {
      recognizer
        ..onTapDown = onTapDownHandler
        ..onTapUp = onTapUpHandler
        ..onTap = () => onTapHandler(context, tag);
    }
    return recognizer;
    */
  }

  Iterable<InlineSpan> _spansForHighlights(
    VerseTag tag,
    String text,
    TextStyle textStyle,
    TapGestureRecognizer recognizer, {
    @required bool isDarkTheme,
  }) {
    final spans = <InlineSpan>[];
    final v = tag.verse;
    var currentWord = tag.word;
    final endWord = math.max(currentWord, currentWord + countOfWordsInString(text) - 1);
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
        final errorMsg = 'ERROR in _spanToWord($word)! tag: $tag, '
            'wordCount: $wordCount, endIndex: $endIndex, currentWord: $currentWord, '
            'remainingText.length: ${remainingText.length}, '
            'remainingText: "${jsonEncode(remainingText)}" ';
        dmPrint(errorMsg);
        assert(false);
        return const TextSpan(text: '');
      }
    }

    // Iterate through all the highlights for the words in the tag...
    for (final hl in highlights().highlightsForVerse(v, startWord: tag.word, endWord: endWord)) {
      final hlStartWord = hl.ref.startWordForVerse(v);
      final hlEndWord = hl.ref.endWordForVerse(v);

      // If there are one or more words before the highlight, add them with the default style.
      if (currentWord < hlStartWord) {
        spans.add(_spanToWord(hlStartWord - 1, textStyle));
        _clearPreviousHighlightValues();
      }

      var hlStyle = textStyle;
      HighlightType _highlightType;
      int _highlightColor;
      if (tag.isInVerse ||
          hl.ref.word != Reference.minWord ||
          hl.ref.endWord != Reference.maxWord) {
        _highlightType = hl.highlightType;
        _highlightColor = hl.color ?? 0xfff8f888;
        final color = Color(_highlightColor);
        if (_highlightType == HighlightType.underline) {
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
                  : TextStyle(backgroundColor: highlightColorWith(color, isDarkMode: isDarkTheme)));
        }
      }

      // If the highlight type or color changed, we don't want leading spaces
      // to be highlighted.
      if (_highlightType != null &&
          (_highlightType != _prevHighlightType || _highlightColor != _prevHighlightColor)) {
        final index = remainingText.indexAtWord(1);
        if (index > 0) {
          final whitespace = remainingText.substring(0, index);
          remainingText = remainingText.substring(index);
          spans.add(TaggableTextSpan(
              text: whitespace,
              style: textStyle,
              tag: tag.copyWith(word: currentWord),
              recognizer: recognizer));
          _clearPreviousHighlightValues();
        }
      }

      if (remainingText.isNotEmpty) {
        // Add the highlight words with the highlight style.
        spans.add(_spanToWord(hlEndWord, hlStyle));
        _prevHighlightType = _highlightType;
        _prevHighlightColor = _highlightColor;
      }
    }

    // If there is still text left, add it with the default style.
    if (remainingText.isNotEmpty) {
      spans.add(TaggableTextSpan(
          text: remainingText,
          style: textStyle,
          tag: tag.copyWith(word: currentWord),
          recognizer: recognizer));
      _clearPreviousHighlightValues();
    }

    return spans;
  }

  void _clearPreviousHighlightValues() {
    _prevHighlightType = null;
    _prevHighlightColor = null;
  }

  HighlightType _prevHighlightType;
  int _prevHighlightColor;

  void scrollToVerse(
    int verse,
    ScrollController controller, {
    bool animated = true,
    bool pulse = false,
  }) {
    assert(verse != null && verse > 0 && controller != null);

    final tecHtmlRenderBox = globalKey.currentContext?.findRenderObject();
    if (tecHtmlRenderBox is RenderBox && tecHtmlRenderBox.hasSize) {
      var handled = false;
      double y;

      // Local func that walks the render object tree.
      bool walkRenderTree(Object ro) {
        final rp = ro is RenderParagraph
            ? RenderParagraphAdapter(ro)
            : ro is RenderTextMixin
                ? ro
                : null;

        if (rp != null && rp.text is TextSpan) {
          final paragraph = TecSelectionParagraph.from(rp, ancestor: tecHtmlRenderBox);
          if (paragraph != null) {
            handled = !paragraph.visitChildSpans((span, index) {
              if (span is TaggableTextSpan) {
                final tag = span.tag;
                if (tag is VerseTag && verse >= tag.verse && verse <= tag.endVerse) {
                  final anchor =
                      paragraph.anchorAtRange(TextRange(start: index, end: index + 1), trim: false);
                  y = anchor?.rects?.first?.top;
                  return false; // Stop walking the span tree.
                }
              }
              return true; // Continue walking the span tree.
            });

            // If handled, stop walking the render tree.
            if (handled) return false;
          }
        } else if (ro is RenderObject) {
          // ro.visitChildrenAndTextRenderers(walkRenderTree);
        }

        return true;
      }

      tecHtmlRenderBox.visitChildrenAndTextRenderers(walkRenderTree);

      if (y != null) {
        // dmPrint('scrollToVerse scrolling to offset: $y, animated: $animated');
        if (animated) {
          controller.animateTo(y - 8,
              duration: const Duration(milliseconds: 1000), curve: Curves.ease);
        } else {
          controller.jumpTo(y - 8);
        }
      } else {
        dmPrint(
            'ChapterViewModel scrollToVerse for $volume/$book/$chapter did not find verse $verse');
      }
    }
  }

  var _marginNoteVerse = 0;
  String _currentFootnoteHref;

  Stopwatch _tapDownStopwatch;
  Offset _globalTapUpOffset;

  var _prevTagXrefHref = '';

  void onTapDownHandler(TapDownDetails details) {
    _tapDownStopwatch = Stopwatch()..start();
  }

  void onTapUpHandler(TapUpDetails details) {
    _globalTapUpOffset = details?.globalPosition;
  }

  void onTapHandler(BuildContext context, [Object tag]) {
    var handledTap = false;

    /*
    if (tag is VerseTag) {
      // Was it a long press on an xref?
      if (!handledTap &&
          tag.isInXref &&
          isNotNullOrEmpty(tag.href) &&
          _tapDownStopwatch.elapsed.inMilliseconds > 500) {
        final reference = Reference(volume: volume, book: book, chapter: chapter, verse: tag.verse);
        handledTap = selection.handleXref(context, reference, null, tag, _globalTapUpOffset);
      }
    }
    */

    // Handle the tap if the tapDown/Up values are set and this is a Bible volume.
    if (!handledTap && _globalTapUpOffset != null && isBibleId(volume)) {
      final tecHtmlRenderBox = globalKey.currentContext?.findRenderObject();
      if (tecHtmlRenderBox is RenderBox && tecHtmlRenderBox.hasSize) {
        final pt = _globalTapUpOffset - tecHtmlRenderBox.localToGlobal(Offset.zero);
        final tecHtmlWidth = tecHtmlRenderBox.size.width;

        const hitPadding = 12.0;

        // Local func that walks the render object tree to find the text span that was tapped.
        bool walkRenderTree(Object ro) {
          final rp = ro is RenderParagraph
              ? RenderParagraphAdapter(ro)
              : ro is RenderTextMixin
                  ? ro
                  : null;

          if (rp != null && rp.renderBox.hasSize) {
            final offset = rp.renderBox.getTransformTo(tecHtmlRenderBox)?.getTranslation();
            if (offset != null) {
              // Extend the rect width to the full width of the TecHtml view.
              final rect = Rect.fromLTWH(offset.x + rp.offset.dx, offset.y + rp.offset.dy,
                      tecHtmlWidth - offset.x, rp.renderBox.size.height)
                  .inflate(hitPadding);

              // If the tap point is in this render box's inflated rect...
              if (rect.contains(pt)) {
                if (rp.text is TextSpan) {
                  final paragraph = TecSelectionParagraph.from(rp, ancestor: tecHtmlRenderBox);
                  if (paragraph != null) {
                    //
                    // First, see if the tap landed on or near a footnote or margin note.
                    handledTap = !paragraph.visitChildSpans((span, index) {
                      if (span is TaggableTextSpan) {
                        final tag = span.tag;
                        if (tag is VerseTag && (tag.isInFootnote || tag.isInMarginNote)) {
                          final anchor = paragraph
                              .anchorAtRange(TextRange(start: index, end: index + 1), trim: false);
                          if (anchor?.copyInflated(hitPadding)?.containsPoint(pt) ?? false) {
                            if (tag.isInFootnote) {
                              // dmPrint('tapped on footnote in verse ${tag.verse}');
                              _onTapFootnote(context, tag, _globalTapUpOffset);
                            } else if (tag.isInMarginNote) {
                              // dmPrint('tapped on margin note in verse ${tag.verse}');
                              _onTapMarginNote(context, tag);
                            }
                            return false; // Stop walking the span tree.
                          }
                        }
                      }
                      return true; // Continue walking the span tree.
                    });

                    // Next, see if the tap landed on, or to the right of, a verse...
                    if (!handledTap) {
                      int lastVerseInParagraph;
                      handledTap = !paragraph.visitChildSpans((span, index) {
                        if (span is TaggableTextSpan &&
                            span.text.isNotEmpty &&
                            span.tag is VerseTag &&
                            (span.tag as VerseTag).isInVerse) {
                          final verse = (span.tag as VerseTag).verse;
                          final includeLastLine = span.text.endsWith('\n') ||
                              (lastVerseInParagraph ??= paragraph.lastVerseInParagraph()) == verse;
                          final anchor = paragraph
                              .anchorAtRange(TextRange(start: index, end: index + span.text.length),
                                  trim: false)
                              ?.copyWithRightEdge(tecHtmlWidth, includeLastLine: includeLastLine);
                          if (anchor?.containsPoint(pt) ?? false) {
                            // dmPrint('tapped on "$text"');
                            selection.toggleVerse(context, verse);
                            return false; // Stop walking the span tree.
                          }
                        }
                        return true; // Continue walking the span tree.
                      });
                    }

                    // If handled tap, stop walking the render tree.
                    if (handledTap) return false;
                  }
                } else if (ro is RenderObject) {
                  // ro.visitChildrenAndTextRenderers(walkRenderTree);
                }
              }
            }
          }

          return true;
        }

        tecHtmlRenderBox.visitChildrenAndTextRenderers(walkRenderTree);
      }
    }

    _tapDownStopwatch?.stop();
    _tapDownStopwatch = null;
    _globalTapUpOffset = null;
  }

  void _onTapMarginNote(BuildContext context, VerseTag tag) {
    assert(tag?.isInMarginNote ?? false);
    if (selection.isNotEmpty) {
      TecToast.show(context, 'Clear selection to view margin note');
      // Not sure if I want to force this...
      // _toggleSelectionForVerse(context, tag.verse);
    } else {
      final mn = marginNotes().marginNoteForVerse(tag.verse);
      if (mn != null) {
        final position = context.viewManager?.indexOfView(viewUid) ?? -1;
        context.viewManager?.add(
            type: Const.viewTypeNote,
            data: toJsonString(mn.stateJson()),
            position: position == -1 ? null : position + 1);
      }
    }
  }

  Future<void> _onTapFootnote(BuildContext context, VerseTag tag, Offset offset) async {
    assert(tag?.isInFootnote ?? false);
    final bible = VolumesRepository.shared.bibleWithId(volume);
    final footnoteHtml =
        await bible.footnoteHtmlWith(book, chapter, int.parse(tag.href.split('_').last));
    if (isNotNullOrEmpty(footnoteHtml.value)) {
      if (selection.isNotEmpty) {
        TecToast.show(context, 'Clear selection to view footnote');
        // not sure if I want to force this...
        // _toggleSelectionForVerse(context, tag.verse);
      } else {
        return showTecModalPopup<void>(
          useRootNavigator: true,
          context: context,
          offset: offset,
          builder: (context) {
            final maxWidth = math.min(320.0, MediaQuery.of(context).size.width);
            return TecPopupSheet(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  // color: Colors.red,
                  constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth),
                  child: GestureDetector(
                    child: TecHtml(
                      footnoteHtml.value,
                      baseUrl: '',
                      selectable: false,
                      textScaleFactor: contentTextScaleFactorWith(context),
                    ),
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            );
          },
        );
      }
    } else if (isNullOrEmpty(footnoteHtml.error)) {
      dmPrint('ERROR: ${footnoteHtml?.error}');
    }
  }
}

///
/// Returns the merged result of two [TextStyle]s, and either, or both, can be `null`.
///
TextStyle _merge(TextStyle s1, TextStyle s2) => s1 == null
    ? s2
    : s2 == null
        ? s1
        : s1.merge(s2);

///
/// Returns the chapter HTML for the given volume, book, and chapter.
///
/// If the volume is a Bible, returns the Bible chapter HTML.
///
/// If the volume is study content, returns the study note HTML for the chapter.
/// If the volume does not have study notes for the chapter, returns HTML with the
/// message "Study notes are not available for this chapter."
///
Future<ErrorOrValue<String>> chapterHtmlWith(Volume volume, int book, int chapter) async {
  if (volume is Bible) {
    final result = await volume.chapterHtmlWith(book, chapter);
    if (!_despanifyChapterHtml || isNullOrEmpty(result.value)) return result;
    final html = result.value.despanified();
    dmPrint('Despanifying HTML for ${volume.abbreviation} '
        '${volume.assocBible().nameOfBook(book)} $chapter reduced size by '
        '${100 - (100 * html.length ~/ result.value.length)}%, '
        '${result.value.length - html.length} chars!');
    return ErrorOrValue(null, html);
  } else {
    final result = await volume.resourcesWithBook(book, chapter, ResourceType.studyNote);
    assert(result != null);
    if (result.error != null) {
      return ErrorOrValue<String>(result.error, null);
    } else {
      final html = StringBuffer();
      for (final note in result.value) {
        if (html.isNotEmpty) html.writeln('<p> </p>');
        html.writeln(
            '<div class="v" id="${note.verse}" end="${note.endVerse}">${note.textData}</div>');
      }
      if (html.isEmpty) {
        html.writeln('<p>Study notes are not available for this chapter.</p>');
      }
      return ErrorOrValue<String>(null, html.toString());
    }
  }
}

extension on TecSelectionAnchor {
  TecSelectionAnchor copyWithRightEdge(double rightEdge, {bool includeLastLine = false}) =>
      TecSelectionAnchor(
        paragraph,
        textSel,
        rects
            .map((r) => !includeLastLine && rects.last == r
                ? r
                : Rect.fromLTRB(r.left, r.top, rightEdge, r.bottom))
            .toList(),
      );
}

extension on TecSelectionParagraph {
  int lastVerseInParagraph() {
    var lastVerse = 0;
    visitChildSpans((span, index) {
      if (span is TaggableTextSpan && span.tag is VerseTag && (span.tag as VerseTag).isInVerse) {
        lastVerse = (span.tag as VerseTag).verse;
      }
      return true; // Continue walking the span tree.
    });
    return lastVerse;
  }
}

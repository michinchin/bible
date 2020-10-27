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
import '../../models/string_utils.dart';
import '../common/common.dart';
import '../note/margin_note_view.dart';
import 'chapter_selection.dart';
import 'verse_tag.dart';

///
/// ChapterViewModel
///
class ChapterViewModel {
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
  /// as needed to get the current value of the indicated property, since the property value
  /// can change between widget rebuilds.
  ///
  ChapterViewModel({
    @required this.viewUid,
    @required this.volume,
    @required this.book,
    @required this.chapter,
    @required this.highlights,
    @required this.marginNotes,
    @required this.selection,
  }) : assert(volume != null && book != null && chapter != null && highlights != null);

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
    if (tag is VerseTag && tag.isInFootnote) {
      if (tag.href != _currentFootnoteHref) {
        _currentFootnoteHref = tag.href;

        // Assign a unique key for this footnote.
        final key = '${tag.verse}-${tag.word}';
        _widgetKeys[key] ??= GlobalKey();
        return _footnoteSpan(context, style, tag, _widgetKeys[key], isDarkTheme);
      }

      return null;
    }

    if (tag is VerseTag) {
      final recognizer = tag.verse == null ? null : TapGestureRecognizer();
      if (recognizer != null) {
        recognizer
          ..onTapDown = (details) {
            _tapDownStopwatch = Stopwatch()..start();
            _tapDownTag = tag;
          }
          ..onTapUp = (details) {
            _tapGlobalPosition = details?.globalPosition;
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
      if (!selection.isInTrialMode && selection.hasVerse(tag.verse)) {
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

  //
  // PRIVATE STUFF
  //

  // Maintain a list of keys for footnotes, margin notes, ...
  final _widgetKeys = <String, GlobalKey>{};

  var _marginNoteVerse = 0;
  String _currentFootnoteHref;

  Color _backgroundColor(bool isDarkTheme) {
    return isDarkTheme ? Colors.black : Colors.white;
  }

  Stopwatch _tapDownStopwatch;
  Object _tapDownTag;
  Offset _tapGlobalPosition;

  void _onTappedSpanWithTag(BuildContext context, Object tag) {
    if (tag is VerseTag) {
      var handledTap = false;

      // Was it a long press on an xref?
      if (!handledTap &&
          // !hasSelection &&
          tag.isInXref &&
          tec.isNotNullOrEmpty(tag.href) &&
          _tapDownStopwatch.elapsed.inMilliseconds > 500 &&
          _tapDownTag is VerseTag &&
          (_tapDownTag as VerseTag).href == tag.href) {
        final verseTag = _tapDownTag as VerseTag;
        final reference =
            Reference(volume: volume, book: book, chapter: chapter, verse: verseTag.verse);
        handledTap = selection.handleXref(context, reference, null, verseTag, _tapGlobalPosition);
      }

      // Was the tap near a margin note or footnote widget?
      // Note, `_tapGlobalPosition` is set in the `onTapUp` handler.
      if (!handledTap && selection.isEmpty && _tapGlobalPosition != null) {
        final pt = _tapGlobalPosition;

        for (final key in _widgetKeys.keys) {
          final rect = globalRectWithKey(_widgetKeys[key])?.inflate(12);
          if (rect != null) {
            // If the tap is above the widget, don't bother checking the rest of the widgets.
            if (pt.dy < rect.top) break;

            // If the tap is in the rect...
            if (rect.contains(pt)) {
              if (_widgetKeys[key].currentWidget is GestureDetector) {
                // This is a widget hit. Execute the tap...
                (_widgetKeys[key].currentWidget as GestureDetector).onTap();
                handledTap = true;
                break;
              }
            }
          }
        }
      }

      // If the tap hasn't been handled yet and this is a bible, toggle verse selection.
      if (!handledTap && volume < 1000) selection.toggleVerse(context, tag.verse);
    }

    _tapDownStopwatch?.stop();
    _tapDownStopwatch = null;
    _tapDownTag = null;
  }

  InlineSpan _marginNoteSpan(
      BuildContext context, TextStyle style, VerseTag tag, Key key, bool isDarkTheme) {
    final color = isDarkTheme ? const Color(0xFFFAFAFA) : const Color(0xFFA1090E);
    final iconWidth = (style.fontSize ?? 16.0) / 1.2;
    final widgetWidth = iconWidth;

    void _onPress() {
      if (selection.isNotEmpty) {
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
                    ? Icon(FeatherIcons.fileText,
                        size: iconWidth, color: color, semanticLabel: 'Margin Note')
                    : SvgPicture.asset('assets/marginNote.svg',
                        width: iconWidth,
                        height: iconWidth,
                        color: color,
                        semanticsLabel: 'Margin Note'),
              ),
            ),
          ),
          onTapUp: (details) => _tapGlobalPosition = details?.globalPosition,
          onTap: _onPress,
          onLongPressStart: (details) => _tapGlobalPosition = details?.globalPosition,
          onLongPress: _onPress,
        ),
      ),
    );
  }

  InlineSpan _footnoteSpan(
      BuildContext context, TextStyle style, VerseTag tag, Key key, bool isDarkTheme) {
    final iconWidth = (style.fontSize ?? 16.0) * 0.6;
    final containerWidth = iconWidth + 4.0; // small right padding

    Future<void> _onPress() async {
      final bible = VolumesRepository.shared.bibleWithId(volume);
      final footnoteHtml =
          await bible.footnoteHtmlWith(book, chapter, int.parse(tag.href.split('_').last));
      if (tec.isNotNullOrEmpty(footnoteHtml.value)) {
        if (selection.isNotEmpty) {
          TecToast.show(context, 'Clear selection to view footnote');
          // not sure if I want to force this...
          // _toggleSelectionForVerse(context, tag.verse);
        } else {
          return showTecModalPopup<void>(
            useRootNavigator: true,
            context: context,
            offset: _tapGlobalPosition,
            builder: (context) {
              final maxWidth = math.min(320.0, MediaQuery.of(context).size.width);
              return TecPopupSheet(
                padding: const EdgeInsets.all(0),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    // color: Colors.red,
                    constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth),
                    child: GestureDetector(
                      child: TecHtml(footnoteHtml.value, baseUrl: '', selectable: false),
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
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
                  ? Icon(Icons.ac_unit,
                      size: iconWidth,
                      color: Theme.of(context).accentColor,
                      semanticLabel: 'Footnote')
                  : SvgPicture.asset('assets/footnote.svg',
                      width: iconWidth,
                      height: iconWidth,
                      color: Theme.of(context).accentColor,
                      semanticsLabel: 'Footnote'),
            ),
          ),
        ),
        onTapUp: (details) => _tapGlobalPosition = details?.globalPosition,
        onTap: _onPress,
        onLongPressStart: (details) => _tapGlobalPosition = details?.globalPosition,
        onLongPress: _onPress,
      ),
    );
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
Future<tec.ErrorOrValue<String>> chapterHtmlWith(Volume volume, int book, int chapter) async {
  if (volume is Bible) {
    return volume.chapterHtmlWith(book, chapter);
  } else {
    final result = await volume.resourcesWithBook(book, chapter, ResourceType.studyNote);
    assert(result != null);
    if (result.error != null) {
      return tec.ErrorOrValue<String>(result.error, null);
    } else {
      final html = StringBuffer();
      for (final note in result.value) {
        if (html.isNotEmpty) html.writeln('<p> </p>');
        html.writeln('<div id="${note.verse}" end="${note.endVerse}">${note.textData}</div>');
      }
      if (html.isEmpty) {
        html.writeln('<p>Study notes are not available for this chapter.</p>');
      }
      return tec.ErrorOrValue<String>(null, html.toString());
    }
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_data/chapter_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/misc_utils.dart';
import '../../models/rect_utils.dart';
import '../../models/string_utils.dart';
import '../common/common.dart';
import '../strongs/strongs_popup.dart';
import '../xref/xref_popup.dart';
import 'verse_tag.dart';

const _debugMode = false; // kDebugMode

class ChapterSelection {
  final TecSelectableController wordSelectionController;
  final void Function(VoidCallback fn) widgetNeedsRebuild;
  final int viewUid;
  final int volume;
  final int book;
  final int chapter;

  ChapterSelection({
    @required this.wordSelectionController,
    @required this.widgetNeedsRebuild,
    @required this.viewUid,
    @required this.volume,
    @required this.book,
    @required this.chapter,
  });

  /// Returns `true` iff verses or words are selected.
  bool get isEmpty => !(hasVerses || hasWordRange);

  bool get isNotEmpty => !isEmpty;

  /// Returns `true` iff one or more verses is selected.
  bool get hasVerses => _selectedVerses.isNotEmpty;

  /// Returns `true` iff the given [verse] is selected.
  bool hasVerse(int verse) => _selectedVerses.contains(verse);

  /// Toggles the selection state for the given [verse].
  void toggleVerse(BuildContext context, int verse) {
    assert(verse != null);
    _updateSelectedVersesInBlock(() {
      if (!_selectedVerses.remove(verse)) _selectedVerses.add(verse);
    }, context);
  }

  /// Returns `true` iff a word range is selected.
  bool get hasWordRange => _selectionStart != null;

  bool get isInTrialMode => _isInTrialMode;

  /// Call to clear all selections, if any.
  void clearAllSelections(BuildContext context) {
    _isInTrialMode = false;
    wordSelectionController.deselectAll();
    _clearAllSelectedVerses(context);
  }

  void notifyOfSelections(BuildContext context) {
    // Notify the view manager, if there is one.
    context
        .bloc<ViewManagerBloc>()
        ?.notifyOfSelectionsInView(viewUid, _getRef(), context, hasSelections: isNotEmpty);
  }

  ///
  /// Handles the `TecSelectableController` `onWordSelectionChanged` callback.
  ///
  void onWordSelectionChanged(BuildContext context) {
    // If any words are selected, clear selected verses, if any.
    final isTextSelected = wordSelectionController.isTextSelected;
    if (isTextSelected) _clearAllSelectedVerses(context);

    // Update _selectionStart and _selectionEnd.
    final start = wordSelectionController.selectionStart;
    final end = wordSelectionController.selectionEnd;
    if (start != null && end != null) {
      _selectionStart = start.tag is VerseTag ? start : null;
      _selectionEnd = end.tag is VerseTag ? end : null;
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

  ///
  /// Returns the current selection reference, or null if nothing is selected.
  ///
  Reference _getRef() => _selectedVerses.isNotEmpty
      ? _referenceWithVerses(_selectedVerses, volume: volume, book: book, chapter: chapter)
      : hasWordRange
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
  /// Handles a selection command.
  ///
  void handleCmd(BuildContext context, SelectionCmd cmd) {
    final bloc = context.bloc<ChapterHighlightsBloc>(); // ignore: close_sinks
    if (bloc == null || isEmpty) return;

    cmd.when(clearStyle: () {
      bloc.add(HighlightEvent.clear(_getRef(), HighlightMode.save));
      clearAllSelections(context);
    }, setStyle: (type, color) {
      bloc.add(
          HighlightEvent.add(type: type, color: color, ref: _getRef(), mode: HighlightMode.save));
      clearAllSelections(context);
    }, tryStyle: (type, color) {
      _isInTrialMode = true;
      bloc.add(
          HighlightEvent.add(type: type, color: color, ref: _getRef(), mode: HighlightMode.trial));
    }, cancelTrial: () {
      _isInTrialMode = false;
      bloc.add(HighlightEvent.clear(_getRef(), HighlightMode.trial));
    }, deselectAll: () {
      clearAllSelections(context);
    }, noOp: () {
      // no-op
    });
  }

  //-------------------------------------------------------------------------
  // Popup menu related:

  Iterable<TecSelectableMenuItem> menuItems(BuildContext context, GlobalKey key) {
    return [
      TecSelectableMenuItem(type: TecSelectableMenuItemType.define),
      TecSelectableMenuItem(
        title: 'Strong\'s',
        isEnabled: (ctl) =>
            _enableStrongs(ctl.selectionStart?.verseTag, ctl.selectionEnd?.verseTag),
        handler: (ctl) {
          final handled = _handleStrongs(context, ctl.selectionStart?.verseTag);
          if (handled) ctl?.deselectAll();
          return handled;
        },
      ),
      TecSelectableMenuItem(
        title: 'Cross-ref',
        isEnabled: (ctl) => _enableXref(ctl.selectionStart?.verseTag, ctl.selectionEnd?.verseTag),
        handler: (ctl) {
          var handled = false;
          final globalOffset = globalOffsetOfWidgetWithKey(key);
          if (globalOffset != null) {
            final pt = ctl.rects.merged().center + globalOffset;
            handled =
                handleXref(context, _getRef(), ctl.text?.trim(), ctl.selectionStart?.verseTag, pt);
          }
          if (handled) ctl?.deselectAll();
          return handled;
        },
      ),
    ];
  }

  bool _enableStrongs(VerseTag tag, VerseTag endTag) {
    if ((tag?.isInXref ?? false) && tec.isNotNullOrEmpty(tag?.href) && tag.href == endTag?.href) {
      final parts = tag.href.split(';');
      for (final part in parts) {
        if (part.startsWith('G') || part.startsWith('H')) return true;
      }
    }
    return false;
  }

  bool _handleStrongs(BuildContext context, VerseTag tag) {
    if ((tag?.isInXref ?? false) && tec.isNotNullOrEmpty(tag?.href)) {
      final parts = tag.href.split(';');
      for (final part in parts) {
        if (part.startsWith('G') || part.startsWith('H')) {
          showStrongsPopup(context: context, title: part, strongsId: part);
          return true;
        }
      }
    }
    return false;
  }

  bool _enableXref(VerseTag tag, VerseTag endTag) {
    if ((tag?.isInXref ?? false) && tec.isNotNullOrEmpty(tag?.href) && tag.href == endTag?.href) {
      if (tag.href.contains('_') || tag.href.contains('/')) return true;
    }
    return false;
  }

  bool handleXref(BuildContext context, Reference reference, String text, VerseTag tag, Offset pt) {
    if ((tag?.isInXref ?? false) && tec.isNotNullOrEmpty(tag?.href)) {
      final bible = VolumesRepository.shared.volumeWithId(volume)?.assocBible;

      bible?.xrefsWithHrefProperty(tag.href)?.then((result) {
        if (result?.value?.isEmpty ?? true) {
          // TO-DO(ron): ...
        } else {
          showXrefsPopup(
            context: context,
            reference: reference,
            text: text,
            xrefs: result.value,
            offset: pt,
          );
        }
      });
      return true;
    }
    return false;
  }

  //
  // PRIVATE STUFF
  //

  var _isInTrialMode = false;

  TaggedText _selectionStart;
  TaggedText _selectionEnd;

  final _selectedVerses = <int>{};

  void _clearAllSelectedVerses(BuildContext context) {
    if (_selectedVerses.isEmpty) return;
    _updateSelectedVersesInBlock(_selectedVerses.clear, context);
  }

  void _updateSelectedVersesInBlock(void Function() block, BuildContext context) {
    TecAutoScroll.stopAutoscroll();
    widgetNeedsRebuild(block);
    if (_debugMode) {
      tec.dmPrint('selected verses: $_selectedVerses');
    }
    notifyOfSelections(context);
  }
}

//
// PRIVATE STUFF
//

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

extension on TaggedText {
  VerseTag get verseTag => (tag is VerseTag) ? tag as VerseTag : null;

  int get verse => (tag is VerseTag) ? (tag as VerseTag).verse : null;

  int get word {
    final t = tag;
    if (t is VerseTag) {
      final words = text?.countOfWords(toIndex: index) ?? 0;
      return t.word + words;
    }
    return null; // ignore: avoid_returning_null
  }
}

// extension on TecSelectableController {
//   /// Returns the number of verses that the selection spans.
//   int get verseCount => (selectionEnd?.verse ?? -1) + 1 - (selectionStart?.verse ?? 0);

//   /// Returns the number of words that are selected in a single verse. If more than one
//   /// verse is selected, `null` is returned.
//   int get wordCount =>
//       verseCount == 1 ? ((selectionEnd?.word ?? 0) - (selectionStart?.word ?? 0)) : null;
// }

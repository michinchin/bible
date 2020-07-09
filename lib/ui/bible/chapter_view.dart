import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../common/common.dart';
import '../common/tec_page_view.dart';
import '../nav/nav.dart';

const bibleChapterType = 'BibleChapter';

const _initialReference = BookChapterVerse(50, 1, 1);
const _bibleId = 51;

Key bibleChapterKeyMaker(BuildContext context, ViewState state) {
  return GlobalKey<PageableViewState>();
}

Widget bibleChapterViewBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');
  return PageableView(
    key: bodyKey,
    state: state,
    size: size,
    controllerBuilder: () {
      final chapterData = _ChapterData.fromJson(state.data);
      return TecPageController(initialPage: chapterData.page);
    },
    pageBuilder: (context, state, size, index) {
      final bible = VolumesRepository.shared.bibleWithId(_bibleId);
      final ref = _initialReference.advancedBy(chapters: index, bible: bible);

      // If the bible doesn't have the given reference, or we advanced past either end, return null.
      if (ref == null || ref.advancedBy(chapters: -index, bible: bible) != _initialReference) {
        return null;
      }
      return _BibleChapterView(size: size, bible: bible, ref: ref);
    },
    onPageChanged: (context, state, page) async {
      tec.dmPrint('View ${state.uid} onPageChanged($page)');
      final bible = VolumesRepository.shared.bibleWithId(_bibleId);
      if (bible != null) {
        final bcv = _initialReference.advancedBy(chapters: page, bible: bible);
        context.bloc<ViewManagerBloc>()?.add(ViewManagerEvent.setData(
            uid: state.uid, data: tec.toJsonString(_ChapterData(bcv, page))));
      }
    },
  );
}

Widget bibleChapterTitleBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) {
  final bible = VolumesRepository.shared.bibleWithId(_bibleId);
  final bcv = _ChapterData.fromJson(state.data).bcv;
  return CupertinoButton(
    child: Text(
      bible.titleWithHref('${bcv.book}/${bcv.chapter}'),
      style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).accentColor),
    ),
    onPressed: () async {
      final bcv = await navigate(context);
      if (bcv != null) {
        final key = tec.as<GlobalKey<PageableViewState>>(bodyKey);
        final pageController = key?.currentState?.pageController;
        if (pageController != null) {
          final _bible = VolumesRepository.shared.bibleWithId(_bibleId);
          final page = _initialReference.chaptersTo(bcv, bible: _bible);
          if (page == null) {
            tec.dmPrint('bibleChapterTitleBuilder unable to navigate to $bcv');
          } else {
            pageController.jumpToPage(page);
          }
        }
      }
    },
  );
}

//
// PRIVATE STUFF
//

class _ChapterData {
  final BookChapterVerse bcv;
  final int page;

  const _ChapterData(BookChapterVerse bcv, int page)
      : bcv = bcv ?? _initialReference,
        page = page ?? 0;

  factory _ChapterData.fromJson(Object object) {
    BookChapterVerse bcv;
    int page;
    final json = (object is String ? tec.parseJsonSync(object) : object);
    if (json is Map<String, dynamic>) {
      bcv = BookChapterVerse.fromJson(json['bcv']);
      page = tec.as<int>(json['page']);
    }
    return _ChapterData(bcv, page);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'bcv': bcv, 'page': page};
  }
}

class _BibleChapterView extends StatelessWidget {
  final Size size;
  final Bible bible;
  final BookChapterVerse ref;

  const _BibleChapterView({
    Key key,
    @required this.size,
    @required this.bible,
    @required this.ref,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<tec.ErrorOrValue<String>>(
      future: bible.chapterHtmlWith(ref.book, ref.chapter),
      builder: (context, snapshot) {
        final html = snapshot.hasData ? snapshot.data.value : null;
        if (tec.isNotNullOrEmpty(html)) {
          return StreamBuilder<double>(
            stream: AppSettings.shared.contentTextScaleFactor.stream,
            builder: (c, snapshot) {
              return _ChapterView(
                volumeId: bible.id,
                ref: ref,
                baseUrl: bible.baseUrl,
                html: html,
                size: size,
              );
            },
          );
        } else {
          final error =
              snapshot.hasError ? snapshot.error : snapshot.hasData ? snapshot.data.error : null;
          final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
          final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
          return Container(
            color: backgroundColor,
            child: Center(
              child: error == null ? const LoadingIndicator() : Text(error.toString()),
            ),
          );
        }
      },
    );
  }
}

///
/// _ChapterView
///
class _ChapterView extends StatefulWidget {
  final int volumeId;
  final BookChapterVerse ref;
  final String baseUrl;
  final String html;
  final Size size;
  final List<String> versesToShow;

  const _ChapterView({
    Key key,
    @required this.volumeId,
    @required this.ref,
    @required this.baseUrl,
    @required this.html,
    this.versesToShow,
    this.size,
  })  : assert(volumeId != null && baseUrl != null && html != null),
        super(key: key);

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<_ChapterView> {
  @override
  void didUpdateWidget(_ChapterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) _html = null;
  }

  // Cached values, for quick rebuild.
  var _contentScaleFactor = 1.0;
  var _env = const TecEnv();
  String _html;

  @override
  Widget build(BuildContext context) {
    // Did the content scale factor change?
    final newContentScaleFactor = contentTextScaleFactorWith(context);
    if (newContentScaleFactor != _contentScaleFactor) {
      _contentScaleFactor = newContentScaleFactor;
      _html = null; // Need to rebuild HTML.
    }

    // Did the theme brightness change?
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    if (_env.darkMode != isDarkTheme) {
      _env = _env.copyWith(darkMode: isDarkTheme);
      _html = null; // Need to rebuild HTML.
    }

    // Rebuild the HTML string only when necessary...
    _html ??= _env.html(
      htmlFragment: widget.html,
      fontSizePercent: (_contentScaleFactor * 100.0).round(),
      marginTop: '0px',
      vendorFolder: (widget.baseUrl?.startsWith('http') ?? false)
          ? null
          : _useZondervanCss(widget.volumeId) ? 'zondervan' : 'tecarta',
      customStyles: ' .${_useZondervanCss(widget.volumeId) ? 'C' : 'cno'} { display: none; } '
          '.FOOTNO { line-height: inherit; }',
    );

    return Container(
      color: isDarkTheme ? Colors.black : Colors.white,
      child: BlocProvider(
        create: (_) => ChapterHighlightsBloc(
          volume: widget.volumeId,
          book: widget.ref.book,
          chapter: widget.ref.chapter,
        ),
        child: BlocBuilder<ChapterHighlightsBloc, ChapterHighlights>(
          builder: (context, highlights) {
            return StreamBuilder<String>(
              stream: AppSettings.shared.contentFontName.stream,
              builder: (c, snapshot) {
                final fontName =
                    (snapshot.hasData ? snapshot.data : AppSettings.shared.contentFontName.value);
                return _BibleHtml(
                  volumeId: widget.volumeId,
                  ref: widget.ref,
                  baseUrl: widget.baseUrl,
                  html: _html,
                  versesToShow: widget.versesToShow ?? [],
                  size: widget.size,
                  fontName: fontName,
                  highlights: highlights,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BibleHtml extends StatefulWidget {
  final int volumeId;
  final BookChapterVerse ref;
  final String baseUrl;
  final String html;
  final Size size;
  final List<String> versesToShow;
  final String fontName;
  final ChapterHighlights highlights;

  const _BibleHtml({
    Key key,
    @required this.volumeId,
    @required this.ref,
    @required this.baseUrl,
    @required this.html,
    @required this.versesToShow,
    @required this.size,
    @required this.fontName,
    @required this.highlights,
  }) : super(key: key);

  @override
  _BibleHtmlState createState() => _BibleHtmlState();
}

class _BibleHtmlState extends State<_BibleHtml> {
  final _scrollController = ScrollController();
  final _selectionController = TecSelectableController();

  @override
  void initState() {
    super.initState();
    _selectionController.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final volume = widget.volumeId;
    final book = widget.ref.book;
    final chapter = widget.ref.chapter;

    // ignore_for_file: omit_local_variable_types

    /// Local func that returns `true` iff the given element is a section element.
    final TecHtmlCheckElementFunc _isSectionElement = _useZondervanCss(volume)
        ? (name, attrs, level, isVisible) {
            return name == 'div' && (attrs.className == 'SUBA' || attrs.className == 'PARREF');
          }
        : (name, attrs, level, isVisible) {
            return name == 'h5';
          };

    var skipSectionTitle = false;

    /// Local func that returns `true` iff the visibility should be toggled
    /// for the given element.
    final TecHtmlCheckElementFunc _toggleVisibilityWithHtmlElement = widget.versesToShow.isEmpty
        ? null
        : (name, attrs, level, isVisible) {
            final id = attrs.id;
            if (tec.isNotNullOrEmpty(id) &&
                name == 'div' &&
                (attrs.className == 'v' || attrs.className.startsWith('v '))) {
              final toggle = (!isVisible && widget.versesToShow.contains(id)) ||
                  (isVisible && !widget.versesToShow.contains(id));
              if (isVisible || toggle) {
                final v = int.tryParse(id);
                skipSectionTitle = (v != null && !widget.versesToShow.contains((v + 1).toString()));
              }
              return toggle;
            }
            return false;
          };

    /// Local func that returns true iff the given element should be skipped.
    final TecHtmlCheckElementFunc _shouldSkipHtmlElement = widget.versesToShow.isEmpty
        ? null
        : (name, attrs, level, isVisible) {
            return (isVisible &&
                skipSectionTitle &&
                _isSectionElement(name, attrs, level, isVisible));
          };

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final selectedTextStyle = TextStyle(
        backgroundColor:
            isDarkTheme ? Colors.blueGrey[800] : const Color(0xffe6e6e6)); // Colors.blue[100]);

    var currentVerse = 1;
    var currentWord = 0;
    var isInVerse = false;
    var isInNonVerseElement = false;
    var nonVerseElementLevel = 0;
    var wasInVerse = false;

    ///
    /// Local function for tagging HTML elements.
    ///
    Object _tagHtmlElement(
      String name,
      LinkedHashMap<dynamic, String> attrs,
      String text,
      int level,
      bool isVisible,
    ) {
      if (isInNonVerseElement && level <= nonVerseElementLevel) {
        isInNonVerseElement = false;
        isInVerse = wasInVerse;
      }
      if (!isInNonVerseElement) {
        final id = attrs.id;
        if (tec.isNotNullOrEmpty(id) &&
            name == 'div' &&
            (attrs.className == 'v' || attrs.className.startsWith('v '))) {
          final verse = int.tryParse(id);
          if (verse != null) {
            isInVerse = true;
            if (verse > currentVerse) {
              currentVerse = verse;
              currentWord = 0;
            } else if (verse == 1) {
              currentWord++; // The old app has a chapter number, which is counted as a word.
            } else {
              tec.dmPrint('current verse: $currentVerse, new verse: $id');
              assert(false);
            }
          }
        } else if (id == 'copyright' ||
            attrs['v'] == '0' ||
            _isSectionElement(name, attrs, level, isVisible)) {
          wasInVerse = isInVerse;
          isInVerse = false;
          isInNonVerseElement = true;
          nonVerseElementLevel = level;
        }
      }

      if (text?.isNotEmpty ?? false) {
        final wordCount = tec.countOfWordsInString(text);
        //tec.dmPrint('$wordCount words for text: $text');
        if (wordCount > 0) {
          final word = currentWord;
          currentWord += wordCount;
          if (wordCount == 1) {
            tec.dmPrint('verse: $currentVerse, word $word: [$text]');
          } else {
            tec.dmPrint('verse: $currentVerse, words $word-${word + wordCount - 1}: [$text]');
          }
          return VerseTag(currentVerse, word, isInVerse);
        }
      }

      return VerseTag(currentVerse, currentWord, isInVerse);
    }

    TextStyle _merge(TextStyle s1, TextStyle s2) =>
        s1 == null ? s2 : s2 == null ? s1 : s1.merge(s2);

    ///
    /// Local function that converts an HTML text node into a TextSpan.
    ///
    InlineSpan _spanForText(String text, TextStyle style, Object tag) {
      if (tag is VerseTag) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _toggleSelectionForVerse(tag.verse);

        // If not in trial mode, and this whole verse is selected, just
        // return a span with the selected text style.
        if (!_isSelectionTrialMode && _selectedVerses.contains(tag.verse)) {
          return TaggableTextSpan(
              text: text,
              style: _merge(style, selectedTextStyle),
              tag: tag,
              recognizer: recognizer);
        } else if (tag.verse != null) {
          final v = tag.verse;
          var currentWord = tag.word;
          final endWord = currentWord + tec.countOfWordsInString(text) - 1;
          var remainingText = text;

          ///
          /// Local func that returns a new span from the `remainingText` up
          /// to and including the given [word], with the given [style]. And
          /// it also updates `currentWord` and `remainingText` appropriately.
          ///
          InlineSpan _spanToWord(int word, TextStyle style) {
            final wordCount = (word - currentWord) + 1;
            final endIndex = remainingText.indexAtEndOfWord(wordCount);
            if (endIndex > 0 && endIndex <= remainingText.length) {
              final span = TaggableTextSpan(
                  text: remainingText.substring(0, endIndex),
                  style: style,
                  tag: VerseTag(v, currentWord, tag.isInVerse),
                  recognizer: recognizer);
              remainingText = remainingText.substring(endIndex);
              currentWord += wordCount;
              return span;
            } else {
              tec.dmPrint('ERROR in _spanToWord! tag: $tag, word: $word, wordCount: $wordCount, endIndex: $endIndex, currentWord: $currentWord, remainingText: "$remainingText", text: "$text"');
              assert(false);
              return const TextSpan(text: 'FAILED!');
            }
          }

          // We're building a list of one or more spans...
          final spans = <InlineSpan>[];

          // Iterate through all the highlights for the words in the tag...
          for (final highlight
              in widget.highlights.highlightsForVerse(v, startWord: tag.word, endWord: endWord)) {
            final hlStartWord = highlight.ref.startWordForVerse(v);
            final hlEndWord = highlight.ref.endWordForVerse(v);

            // If there are one or more words before the highlight, add them with the default style.
            if (currentWord < hlStartWord) {
              spans.add(_spanToWord(hlStartWord - 1, style));
            }

            TextStyle hlStyle = style;
            final color = Color(highlight.color ?? 0xfff8f888);
            switch (highlight.highlightType) {
              case HighlightType.highlight:
                hlStyle = _merge(style,
                    isDarkTheme ? TextStyle(color: color) : TextStyle(backgroundColor: color));
                break;
              case HighlightType.underline:
                hlStyle = _merge(
                    style,
                    TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: color.withAlpha(192),
                        decorationThickness: 2));
                break;
              default:
                break;
            }

            // Add the highlight words with the highlight style.
            spans.add(_spanToWord(hlEndWord, hlStyle));
          }

          // If there is still text left, add it with the default style.
          if (remainingText.isNotEmpty) {
            spans.add(TaggableTextSpan(
                text: remainingText,
                style: style,
                tag: VerseTag(v, currentWord, tag.isInVerse),
                recognizer: recognizer));
          }

          return spans.length == 1
              ? spans.first
              : TextSpan(children: spans, recognizer: recognizer);
        }
      }
      return TextSpan(text: text, style: style);
    }

    return BlocListener<SelectionStyleBloc, SelectionStyle>(
      listener: (context, selectionStyle) => Future.delayed(Duration.zero,
          () => _selectionStyleChanged(context, selectionStyle, volume, book, chapter)),
      child: Semantics(
        //textDirection: textDirection,
        label: 'Bible text',
        child: ExcludeSemantics(
          child: TecAutoScroll(
            scrollController: _scrollController,
            allowAutoscroll: () => !context.bloc<SelectionBloc>().state.isTextSelected,
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                TecHtml(
                  widget.html,
                  debugId: '$volume/$book/$chapter',
                  scrollController: _scrollController,
                  baseUrl: widget.baseUrl,
                  textScaleFactor: 1.0, // HTML is already scaled.
                  textStyle: widget.fontName.isEmpty
                      ? _htmlDefaultTextStyle.merge(TextStyle(color: textColor))
                      : GoogleFonts.getFont(widget.fontName, color: textColor),
                  padding: EdgeInsets.symmetric(
                    horizontal: (widget.size.width * _marginPercent).roundToDouble(),
                  ),

                  // Tagging HTML elements:
                  tagHtmlElement: _tagHtmlElement,

                  // Rendering HTML text to a TextSpan:
                  spanForText: _spanForText,

                  // Word range selection related:
                  selectable: !kIsWeb && _selectedVerses.isEmpty,
                  selectionController: _selectionController,

                  // `versesToShow` related (when viewing a subset of verses in the chapter):
                  isInitialHtmlElementVisible:
                      widget.versesToShow.isEmpty || widget.versesToShow.contains('1'),
                  toggleVisibilityWithHtmlElement: _toggleVisibilityWithHtmlElement,
                  shouldSkipHtmlElement: _shouldSkipHtmlElement,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var _isSelectionTrialMode = false;

  //-------------------------------------------------------------------------
  // Selection related:

  bool get _hasSelection => _selectedVerses.isNotEmpty || _selectionStart != null;

  void _selectionStyleChanged(
      BuildContext context, SelectionStyle selectionStyle, int volume, int book, int chapter) {
    final bloc = context.bloc<ChapterHighlightsBloc>(); // ignore: close_sinks
    if (bloc == null || !_hasSelection) return;
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
            endWord: _selectionEnd.word - 1);

    if (!_isSelectionTrialMode) {
      _selectionController.deselectAll();
      _clearAllSelectedVerses();
    }

    if (selectionStyle.type == HighlightType.clear) {
      bloc.add(HighlightsEvent.clear(ref));
    } else {
      bloc.add(
          HighlightsEvent.add(type: selectionStyle.type, color: selectionStyle.color, ref: ref));
    }
  }

  //-------------------------------------------------------------------------
  // Word range selection:

  TaggedText _selectionStart;
  TaggedText _selectionEnd;

  void _onSelectionChanged() {
    final isTextSelected = _selectionController.isTextSelected;
    if (isTextSelected) _clearAllSelectedVerses();

    final start = _selectionController.selectionStart;
    final end = _selectionController.selectionEnd;
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
        tec.dmPrint('START: $_selectionStart');
        tec.dmPrint('END:   $_selectionEnd');
      }
    } else {
      _selectionStart = _selectionEnd = null;
      tec.dmPrint('NO WORDS SELECTED');
    }

    context.bloc<SelectionBloc>()?.add(SelectionState(isTextSelected: _selectionStart != null));
  }

  //-------------------------------------------------------------------------
  // Verse selection:

  final _selectedVerses = <int>{};

  void _toggleSelectionForVerse(int verse) {
    assert(verse != null);
    _updateSelectedVersesInBlock(() {
      if (!_selectedVerses.remove(verse)) _selectedVerses.add(verse);
    });
  }

  void _clearAllSelectedVerses() {
    if (_selectedVerses.isEmpty) return;
    _updateSelectedVersesInBlock(_selectedVerses.clear);
  }

  void _updateSelectedVersesInBlock(void Function() block) {
    final wasTextSelected = _selectedVerses.isNotEmpty;
    setState(block);
    tec.dmPrint('selected verses: $_selectedVerses');
    final isTextSelected = _selectedVerses.isNotEmpty;
    if (wasTextSelected != isTextSelected) {
      context.bloc<SelectionBloc>()?.add(SelectionState(isTextSelected: isTextSelected));
    }
  }

  //-------------------------------------------------------------------------
}

Reference _referenceWithVerses(
  Iterable<int> verses, {
  int volume,
  int book,
  int chapter,
  DateTime modified,
}) {
  if (verses?.isEmpty ?? true) return null;
  final sorted = List.of(Set.of(verses))..sort();
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

extension on Iterable<int> {
  List<int> missingValues() {
    if (isEmpty ?? true) return [];
    final set = Set.of(this);
    final sorted = List.of(set)..sort();
    if (sorted.last - sorted.first > sorted.length) {
      final first = sorted.first;
      final last = sorted.last;
      final missing = Set.of(Iterable<int>.generate((last - first) + 1, (i) => first + i))
        ..removeAll(set);
      return missing.toList()..sort();
    }
    return [];
  }
}

const _lineSpacing = 1.4;
const _marginPercent = 0.05; // 0.05;

bool _useZondervanCss(int volume) => (volume == 32);

const TextStyle _htmlDefaultTextStyle = TextStyle(
  inherit: false,
  //fontFamily: tec.platformIs(tec.Platform.iOS) ? 'Avenir' : 'normal',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: _lineSpacing,
);

///
/// Used to tag an HTML text node with the verse it is in, and the word index
/// of the first word in the text node.
///
@immutable
class VerseTag {
  final int verse;
  final int word;
  final bool isInVerse;

  // ignore: avoid_positional_boolean_parameters
  const VerseTag(this.verse, this.word, this.isInVerse)
      : assert(verse != null && word != null && isInVerse != null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseTag &&
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

extension ChapterViewExtOnString on String {
  int countOfWords({int toIndex}) {
    var count = 0;
    var isInWord = false;
    var i = 0;
    final units = codeUnits;
    for (final codeUnit in units) {
      if (toIndex != null && i >= toIndex) break;
      final isWhitespace = tec.isWhitespace(codeUnit);
      if (isInWord) {
        if (isWhitespace) isInWord = false;
      } else if (!isWhitespace) {
        count++;
        isInWord = true;
      }
      i++;
    }
    return count;
  }

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

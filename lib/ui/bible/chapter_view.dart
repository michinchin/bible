import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/margin_notes/margin_notes_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/bible_chapter_state.dart';
import '../common/common.dart';
import '../common/tec_page_view.dart';
import '../misc/view_actions.dart';
import '../nav/nav.dart';
import 'chapter_view_model.dart';

const bibleChapterType = 'BibleChapter';

Widget bibleChapterViewBuilder(BuildContext context, ViewState state, Size size) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');
  return _PageableBibleView(state: state, size: size);
}

String bibleChapterDefaultData() {
  return tec.toJsonString(BibleChapterState.initial());
}

class _PageableBibleView extends StatefulWidget {
  final ViewState state;
  final Size size;

  const _PageableBibleView({Key key, this.state, this.size}) : super(key: key);

  @override
  __PageableBibleViewState createState() => __PageableBibleViewState();
}

class __PageableBibleViewState extends State<_PageableBibleView> {
  final _pageableViewStateKey = GlobalKey<PageableViewState>();

  StreamController<String> _title;
  Bible _bible;
  BookChapterVerse _bcvPageZero;

  @override
  void initState() {
    final chapterState = BibleChapterState.fromJson(widget.state.data);
    // we're putting title in a stream so we can update outside of setState - as that
    // rebuilds the PageableView :(
    _title = StreamController<String>()..add(chapterState.title);
    _bible = VolumesRepository.shared.bibleWithId(chapterState.bibleId);
    _bcvPageZero = chapterState.bcv;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinHeightAppBar(
        appBar: AppBar(
          title: CupertinoButton(
            child: StreamBuilder<String>(
                stream: _title.stream,
                builder: (context, snapshot) {
                  return Text(
                    (snapshot.hasData) ? snapshot.data : '',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Theme.of(context).accentColor),
                  );
                }),
            onPressed: () async {
              // TODO(abby): is this the correct bcv value to pass in?
              final bcv = await navigate(context, _bcvPageZero);
              if (bcv != null) {
                // small delay to allow the nav popup to clean up before we navigate
                // away...
                Future.delayed(const Duration(milliseconds: 350), () {
                  final pageController = _pageableViewStateKey.currentState?.pageController;
                  if (pageController != null) {
                    final page = _bcvPageZero.chaptersTo(bcv, bible: _bible);
                    if (page == null) {
                      tec.dmPrint('bibleChapterTitleBuilder unable to navigate to $bcv');
                    } else {
                      pageController.jumpToPage(page);
                    }
                  }
                });
              }
            },
          ),
          actions: defaultActionsBuilder(context, widget.state, widget.size),
        ),
      ),
      body: PageableView(
        key: _pageableViewStateKey,
        state: widget.state,
        size: widget.size,
        controllerBuilder: () {
          return TecPageController(initialPage: 0);
        },
        pageBuilder: (context, _, size, index) {
          final ref = _bcvPageZero.advancedBy(chapters: index, bible: _bible);

          // If the bible doesn't have the given reference, or we advanced past either end,
          // return null.
          if (ref == null) {
            return null;
          }

          debugPrint('page builder: ${ref.toString()}');
          return _BibleChapterView(viewUid: widget.state.uid, size: size, bible: _bible, ref: ref);
        },
        onPageChanged: (context, _, page) async {
          tec.dmPrint('View ${widget.state.uid} onPageChanged($page)');
          final bcv = _bcvPageZero.advancedBy(chapters: page, bible: _bible);
          if (bcv != null) {
            updateLocation(bcv, page);
          }
        },
      ),
    );
  }

  void updateLocation(BookChapterVerse bcv, int page) {
    final nextViewState = BibleChapterState(_bible.id, bcv, page);
    _title.add(nextViewState.title);

    // update the view manager state
    context.bloc<ViewManagerBloc>()?.add(ViewManagerEvent.updateData(
          uid: widget.state.uid,
          data: tec.toJsonString(nextViewState),
        ));
  }
}

class _BibleChapterView extends StatefulWidget {
  final int viewUid;
  final Size size;
  final Bible bible;
  final BookChapterVerse ref;

  const _BibleChapterView({
    Key key,
    @required this.viewUid,
    @required this.size,
    @required this.bible,
    @required this.ref,
  }) : super(key: key);

  @override
  _BibleChapterViewState createState() => _BibleChapterViewState();
}

class _BibleChapterViewState extends State<_BibleChapterView> {
  Future<tec.ErrorOrValue<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.bible.chapterHtmlWith(widget.ref.book, widget.ref.chapter);
  }

  @override
  Widget build(BuildContext context) {
    return TecFutureBuilder<tec.ErrorOrValue<String>>(
      future: _future,
      builder: (context, data, error) {
        final html = data?.value;
        if (tec.isNotNullOrEmpty(html)) {
          return TecStreamBuilder<double>(
            stream: AppSettings.shared.contentTextScaleFactor.stream,
            initialData: AppSettings.shared.contentTextScaleFactor.value,
            builder: (c, data, error) {
              if (data != null) {
                // when we get here, html and text scale are actually loaded and ready to go...
                return _ChapterView(
                  viewUid: widget.viewUid,
                  volumeId: widget.bible.id,
                  ref: widget.ref,
                  baseUrl: widget.bible.baseUrl,
                  html: html,
                  size: widget.size,
                );
              } else {
                return _blankContainer(context, error);
              }
            },
          );
        } else {
          tec.dmPrint('VIEW ${widget.viewUid} waiting for HTML to load...');
          return _blankContainer(context, error ?? data?.error);
        }
      },
    );
  }

  Widget _blankContainer(BuildContext context, Object error) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    return Container(
      color: backgroundColor,
      child: Center(
        child: error == null ? const LoadingIndicator() : Text(error.toString()),
      ),
    );
  }
}

///
/// _ChapterView
///
class _ChapterView extends StatefulWidget {
  final int viewUid;
  final int volumeId;
  final BookChapterVerse ref;
  final String baseUrl;
  final String html;
  final Size size;
  final List<String> versesToShow;

  const _ChapterView({
    Key key,
    @required this.viewUid,
    @required this.volumeId,
    @required this.ref,
    @required this.baseUrl,
    @required this.html,
    @required this.size,
    this.versesToShow,
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
      marginLeft: '0px',
      marginRight: '0px',
      marginTop: '0px',
      marginBottom: '60px',
      vendorFolder: (widget.baseUrl?.startsWith('http') ?? false)
          ? null
          : useZondervanCss(widget.volumeId) ? 'zondervan' : 'tecarta',
      customStyles: ' .${useZondervanCss(widget.volumeId) ? 'C' : 'cno'} { display: none; } '
          '.FOOTNO { line-height: inherit; top: inherit; }',
    );

    return Container(
      color: isDarkTheme ? Colors.black : Colors.white,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ChapterMarginNotesBloc(
              volume: widget.volumeId,
              book: widget.ref.book,
              chapter: widget.ref.chapter,
            ),
          ),
          BlocProvider(
            create: (_) => ChapterHighlightsBloc(
              volume: widget.volumeId,
              book: widget.ref.book,
              chapter: widget.ref.chapter,
            ),
          ),
        ],
        child: BlocBuilder<ChapterMarginNotesBloc, ChapterMarginNotes>(
          builder: (context, marginNotes) {
            return BlocBuilder<ChapterHighlightsBloc, ChapterHighlights>(
                builder: (context, highlights) {
              return TecStreamBuilder<String>(
                stream: AppSettings.shared.contentFontName.stream,
                initialData: AppSettings.shared.contentFontName.value,
                builder: (c, fontName, error) {
                  assert(fontName != null);
                  if (highlights.loaded && marginNotes.loaded) {
                    // TODO(mike): fix multiple reloading of a chapter...
                    // Psalm 119 example...
                    // on first load - chapter is loaded 2x - snapshot.hasData = false, then snapShot.hasData = true
                    // nav to a different part of the bible - current chapter is reloaded (hasData = true)
                    // swipe to next chapter - chapter is loaded 3x (hasData = true)
                    // swipe back - chapter is loaded 5x (hasData = false, 4x hasData = true)

                    if (widget.ref.chapter == 119) {
                      debugPrint('loading 119');
                    } else {
                      debugPrint('loading ${widget.ref.chapter}');
                    }

                    return _BibleHtml(
                      viewUid: widget.viewUid,
                      volumeId: widget.volumeId,
                      ref: widget.ref,
                      baseUrl: widget.baseUrl,
                      html: _html,
                      versesToShow: widget.versesToShow ?? [],
                      // ['1', '2', '3']
                      size: widget.size,
                      fontName: fontName,
                      highlights: highlights,
                      marginNotes: marginNotes,
                    );
                  } else {
                    tec.dmPrint('VIEW ${widget.viewUid} waiting for highlights and margin notes');
                    return Container();
                  }
                },
              );
            });
          },
        ),
      ),
    );
  }
}

class _BibleHtml extends StatefulWidget {
  final int viewUid;
  final int volumeId;
  final BookChapterVerse ref;
  final String baseUrl;
  final String html;
  final Size size;
  final List<String> versesToShow;
  final String fontName;
  final ChapterHighlights highlights;
  final ChapterMarginNotes marginNotes;

  const _BibleHtml({
    Key key,
    @required this.viewUid,
    @required this.volumeId,
    @required this.ref,
    @required this.baseUrl,
    @required this.html,
    @required this.versesToShow,
    @required this.size,
    @required this.fontName,
    @required this.highlights,
    @required this.marginNotes,
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

    tec.dmPrint(
        'New BibleChapterViewModel for ${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}');
    _viewModel = BibleChapterViewModel(
      viewUid: widget.viewUid,
      volume: widget.volumeId,
      book: widget.ref.book,
      chapter: widget.ref.chapter,
      versesToShow: () => widget.versesToShow,
      highlights: () => widget.highlights,
      marginNotes: () => widget.marginNotes,
      selectionController: _selectionController,
      refreshFunc: _refresh,
    );

    _selectionController.addListener(() => _viewModel.onSelectionChanged(context));
  }

  BibleChapterViewModel _viewModel;

  void _refresh(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debugId = '${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}';
    tec.dmPrint('_BibleHtml building TecHtml for $debugId ${widget.size}');

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final selectionColor = isDarkTheme ? Colors.white.withAlpha(48) : Colors.black.withAlpha(32);
    final selectedTextStyle =
        TextStyle(backgroundColor: isDarkTheme ? Colors.grey[850] : const Color(0xffe6e6e6));

    // A new [TecHtmlBuildHelper] needs to be created for each build...
    final helper = _viewModel.tecHtmlBuildHelper();

    return BlocListener<SelectionStyleBloc, SelectionStyle>(
      listener: (context, selectionStyle) => _viewModel.selectionStyleChanged(
          context, selectionStyle, widget.volumeId, widget.ref.book, widget.ref.chapter),
      child: Semantics(
        //textDirection: textDirection,
        label: 'Bible text',
        child: ExcludeSemantics(
          child: TecAutoScroll(
            scrollController: _scrollController,
            allowAutoscroll: () => !context.bloc<SelectionBloc>().state.isTextSelected,
            autoscrollActive: (active) {
              if (active) {
                context.bloc<SheetManagerBloc>().collapse(context);
              } else {
                context.bloc<SheetManagerBloc>().restore(context);
              }
            },
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                TecHtml(
                  widget.html,
                  debugId: debugId,
                  scrollController: _scrollController,
                  baseUrl: widget.baseUrl,
                  textScaleFactor: 1.0,
                  // HTML is already scaled.
                  textStyle: widget.fontName.isEmpty
                      ? _htmlDefaultTextStyle.merge(TextStyle(color: textColor))
                      : GoogleFonts.getFont(widget.fontName, color: textColor),
                  padding: EdgeInsets.symmetric(
                    horizontal: (widget.size.width * _marginPercent).roundToDouble(),
                  ),

                  // Tagging HTML elements:
                  tagHtmlElement: helper.tagHtmlElement,

                  // Rendering HTML text to a TextSpan:
                  spanForText: (text, style, tag) => _viewModel.spanForText(
                      context, text, style, tag, selectedTextStyle,
                      isDarkTheme: isDarkTheme),

                  // Word range selection related:
                  selectable: !kIsWeb && !_viewModel.hasVersesSelected,
                  selectionColor: selectionColor,
                  showSelection: !_viewModel.isSelectionTrialMode,
                  showSelectionPopup: false,
                  selectionController: _selectionController,

                  // `versesToShow` related (when viewing a subset of verses in the chapter):
                  isInitialHtmlElementVisible:
                      widget.versesToShow.isEmpty || widget.versesToShow.contains('1'),
                  toggleVisibilityWithHtmlElement: helper.toggleVisibility,
                  shouldSkipHtmlElement: helper.shouldSkip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _lineSpacing = 1.4;
const _marginPercent = 0.05; // 0.05;

const TextStyle _htmlDefaultTextStyle = TextStyle(
  inherit: false,
  //fontFamily: tec.platformIs(tec.Platform.iOS) ? 'Avenir' : 'normal',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: _lineSpacing,
);

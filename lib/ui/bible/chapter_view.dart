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
import '../../blocs/view_data/volume_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../common/common.dart';
import '../common/tec_page_view.dart';
import '../library/library.dart';
import 'chapter_view_app_bar.dart';
import 'chapter_view_model.dart';

class ViewableBibleChapter extends Viewable {
  ViewableBibleChapter(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return _PageableBibleView(state: state, size: size);
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) {
    return state?.uid == null
        ? 'Bible'
        : VolumeViewData.fromContext(context, state.uid).bookNameChapterAndAbbr;
  }

  @override
  Future<ViewData> dataForNewView({BuildContext context, int currentViewId}) async {
    final bibleId = await selectVolume(context,
        title: 'Select Bible Translation',
        filter: const VolumesFilter(
          volumeType: VolumeType.bible,
        ));
    // tec.dmPrint('selected $bibleId');

    if (bibleId != null) {
      final vmBloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
      final previous = ChapterViewData.fromJson(vmBloc?.dataWithView(currentViewId));
      assert(previous != null);
      return ChapterViewData(bibleId, previous.bcv, previous.page);
    }

    return null;
  }
}

class _PageableBibleView extends StatefulWidget {
  final ViewState state;
  final Size size;

  const _PageableBibleView({Key key, this.state, this.size}) : super(key: key);

  @override
  __PageableBibleViewState createState() => __PageableBibleViewState();
}

class __PageableBibleViewState extends State<_PageableBibleView> {
  TecPageController _pageController;
  BookChapterVerse _bcvPageZero;
  Bible _bible;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) {
          final vmBloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
          final viewData = ChapterViewData.fromJson(vmBloc.dataWithView(widget.state.uid));
          _bible = VolumesRepository.shared.bibleWithId(viewData.bibleId);
          _bcvPageZero = viewData.bcv;
          return ViewDataBloc(vmBloc, widget.state.uid, viewData);
        },
        child: Scaffold(
          appBar: MinHeightAppBar(
              appBar: ChapterViewAppBar(
                  viewState: widget.state, size: widget.size, onUpdate: _onUpdate)),
          body: PageableView(
            state: widget.state,
            size: widget.size,
            controllerBuilder: () {
              _pageController = TecPageController(initialPage: 0);
              return _pageController;
            },
            pageBuilder: (context, _, size, index) {
              final ref = _bcvPageZero.advancedBy(chapters: index, bible: _bible);
              if (ref == null) return null;
              return BlocBuilder<ViewDataBloc, ViewData>(
                buildWhen: (before, after) =>
                    (before as ChapterViewData).bibleId != (after as ChapterViewData).bibleId,
                builder: (context, viewData) {
                  if (viewData is ChapterViewData) {
                    final bible = VolumesRepository.shared.bibleWithId(viewData.bibleId);
                    final ref = _bcvPageZero.advancedBy(chapters: index, bible: bible);
                    if (ref == null) return Container();
                    tec.dmPrint('page builder: ${ref.toString()}');
                    return _BibleChapterView(
                        viewUid: widget.state.uid, size: size, bible: bible, ref: ref);
                  } else {
                    throw UnsupportedError('_PageableBibleView must use ChapterViewData');
                  }
                },
              );
            },
            onPageChanged: (context, _, page) async {
              tec.dmPrint('View ${widget.state.uid} onPageChanged($page)');
              final bcv = _bcvPageZero.advancedBy(chapters: page, bible: _bible);
              if (bcv != null) {
                final viewData = ChapterViewData(_bible.id, bcv, page);
                tec.dmPrint('_PageableBibleView updating with new data: $viewData');
                context.bloc<ViewDataBloc>().update(viewData);
              }
            },
          ),
        ));
  }

  void _onUpdate(
      BuildContext context, int newBibleId, BookChapterVerse newBcv, VolumeViewData viewData) {
    if (!mounted || newBibleId == null || newBcv == null) return;

    var bibleChanged = false;
    var bible = _bible;
    if (newBibleId != viewData.volumeId) {
      bibleChanged = true;
      bible = VolumesRepository.shared.bibleWithId(newBibleId);
      if (bible == null) return; // ---------------------------------------->
    }

    final page = _bcvPageZero.chaptersTo(newBcv, bible: bible);
    if (page == null) {
      tec.dmPrint('BibleView unable to navigate to $newBcv in ${bible.abbreviation}');
      return; // ---------------------------------------->
    }

    if (bibleChanged) {
      _bible = bible;
      context.bloc<ViewDataBloc>()?.update(ChapterViewData(bible.id, newBcv, page));
    } else if (newBcv != viewData.bcv) {
      _pageController?.jumpToPage(page);
    }
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
  void didUpdateWidget(_BibleChapterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bible.id != widget.bible.id || oldWidget.ref != widget.ref) {
      _future = widget.bible.chapterHtmlWith(widget.ref.book, widget.ref.chapter);
    }
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
                  bible: widget.bible,
                  ref: widget.ref,
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
  final Bible bible;
  final BookChapterVerse ref;
  final String html;
  final Size size;
  final List<String> versesToShow;

  const _ChapterView({
    Key key,
    @required this.viewUid,
    @required this.bible,
    @required this.ref,
    @required this.html,
    @required this.size,
    this.versesToShow,
  })  : assert(bible != null && html != null),
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
      vendorFolder: widget.bible.vendorFolder,
      customStyles: ' .C, .cno { display: none; } '
          '.FOOTNO { line-height: inherit; top: inherit; }'
          'h5, .SUBA, h1 { font-weight: normal !important; font-style: italic; font-size: 100% !important;}',
    );

    return Container(
      color: isDarkTheme ? Colors.black : Colors.white,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ChapterMarginNotesBloc(
              volumeId: widget.bible.id,
              book: widget.ref.book,
              chapter: widget.ref.chapter,
            ),
          ),
          BlocProvider(
            create: (context) => ChapterHighlightsBloc(
              volumeId: widget.bible.id,
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
                  var userContentValid = true;
                  if (marginNotes.loaded && marginNotes.volumeId != widget.bible.id) {
                    context
                        .bloc<ChapterMarginNotesBloc>()
                        .add(MarginNotesEvent.changeVolumeId(widget.bible.id));
                    userContentValid = false;
                  }

                  if (highlights.loaded && highlights.volumeId != widget.bible.id) {
                    context
                        .bloc<ChapterHighlightsBloc>()
                        .add(HighlightEvent.changeVolumeId(widget.bible.id));
                    userContentValid = false;
                  }

                  if (userContentValid && highlights.loaded && marginNotes.loaded) {
                    tec.dmPrint('loading ${widget.ref.chapter}');

                    return _BibleHtml(
                      viewUid: widget.viewUid,
                      volumeId: widget.bible.id,
                      ref: widget.ref,
                      baseUrl: widget.bible.baseUrl,
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
        TextStyle(backgroundColor: isDarkTheme ? const Color(0xff393939) : const Color(0xffe6e6e6));

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
            navigationBarPadding: () => TecScaffoldWrapper.navigationBarPadding,
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
                  textStyle: _htmlDefaultTextStyle.merge(widget.fontName.isEmpty
                      ? TextStyle(color: textColor)
                      : widget.fontName.startsWith('embedded_')
                          ? TextStyle(color: textColor, fontFamily: widget.fontName.substring(9))
                          : GoogleFonts.getFont(widget.fontName, color: textColor)),

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

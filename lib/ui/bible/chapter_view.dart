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
import '../common/common.dart';
import '../common/tec_page_view.dart';
import '../misc/view_actions.dart';
import '../nav/nav.dart';
import 'chapter_view_model.dart';

const bibleChapterType = 'BibleChapter';

const _initialReference = BookChapterVerse(50, 1, 1);
const _bibleId = 51;

Widget bibleChapterViewBuilder(BuildContext context, ViewState state, Size size) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');
  return _PageableBibleView(state: state, size: size);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ManagedViewAppBar(
        appBar: AppBar(
          title: _titleBuilder(context, _pageableViewStateKey, widget.state, widget.size),
          actions: defaultActionsBuilder(context, widget.state, widget.size),
        ),
      ),
      body: PageableView(
        key: _pageableViewStateKey,
        state: widget.state,
        size: widget.size,
        controllerBuilder: () {
          final chapterData = _ChapterData.fromJson(widget.state.data);
          return TecPageController(initialPage: chapterData.page);
        },
        pageBuilder: (context, state, size, index) {
          final bible = VolumesRepository.shared.bibleWithId(_bibleId);
          final ref = _initialReference.advancedBy(chapters: index, bible: bible);

          // If the bible doesn't have the given reference, or we advanced past either end, return null.
          if (ref == null || ref.advancedBy(chapters: -index, bible: bible) != _initialReference) {
            return null;
          }
          return _BibleChapterView(viewUid: state.uid, size: size, bible: bible, ref: ref);
        },
        onPageChanged: (context, state, page) async {
          tec.dmPrint('View ${state.uid} onPageChanged($page)');
          final bible = VolumesRepository.shared.bibleWithId(_bibleId);
          if (bible != null) {
            final bcv = _initialReference.advancedBy(chapters: page, bible: bible);
            context.bloc<ViewManagerBloc>()?.add(ViewManagerEvent.setData(
                uid: state.uid, data: _ChapterData(bcv, page).toJson()));
          }
        },
      ),
    );
  }
}

Widget _titleBuilder(BuildContext context, Key pageableViewStateKey, ViewState state, Size size) {
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
        final key = tec.as<GlobalKey<PageableViewState>>(pageableViewStateKey);
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
    final bible = VolumesRepository.shared.bibleWithId(_bibleId);
    final _bcv = bcv ?? _initialReference;
    final abbreviation = (bible.abbreviation == null) ? '' : ' ${bible.abbreviation}';
    final title = bible.titleWithHref('${_bcv.book}/${_bcv.chapter}$abbreviation}');

    return <String, dynamic>{'bcv': bcv, 'page': page, 'title': title };
  }
}

class _BibleChapterView extends StatelessWidget {
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
                viewUid: viewUid,
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
              return StreamBuilder<String>(
                stream: AppSettings.shared.contentFontName.stream,
                builder: (c, snapshot) {
                  if (snapshot.hasData && highlights.loaded && marginNotes.loaded) {
                    final fontName = snapshot.data;

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
                context.bloc<SheetManagerBloc>().changeType(SheetType.collapsed);
              } else {
                context.bloc<SheetManagerBloc>().toDefaultView();
              }
            },
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                TecHtml(
                  widget.html,
                  debugId: '${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}',
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
                  tagHtmlElement: helper.tagHtmlElement,

                  // Rendering HTML text to a TextSpan:
                  spanForText: (text, style, tag) => _viewModel.spanForText(
                      context, text, style, tag, selectedTextStyle,
                      isDarkTheme: isDarkTheme),

                  // Rendering CSS padding/margin to a WidgetSpan:
                  spanForSpace: (width, tag) =>
                      _viewModel.spanForSpace(context, width, tag, isDarkTheme: isDarkTheme),

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

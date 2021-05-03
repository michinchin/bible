import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_bloc/tec_bloc.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../../blocs/content_settings.dart';
import '../../../blocs/highlights/highlights_bloc.dart';
import '../../../blocs/margin_notes/margin_notes_bloc.dart';
import '../../../blocs/selection/selection_bloc.dart';
import '../../../blocs/shared_bible_ref_bloc.dart';
import '../../../blocs/sheet/sheet_manager_bloc.dart';
import '../../../models/app_settings.dart';
import '../../common/common.dart';
import '../../common/tec_overflow_box.dart';
import '../../common/tec_scroll_listener.dart';
import '../volume_view_data_bloc.dart';
import 'chapter_build_helper.dart';
import 'chapter_selection.dart';
import 'chapter_view_model.dart';
// import 'v91_bible_vendor_css.dart';

class PageableChapterView extends StatefulWidget {
  final ViewState viewState;
  final Size size;
  final EdgeInsets htmlPadding;

  const PageableChapterView({Key key, this.viewState, this.size, this.htmlPadding})
      : super(key: key);

  @override
  _PageableChapterViewState createState() => _PageableChapterViewState();
}

class _PageableChapterViewState extends State<PageableChapterView> {
  TecPageController _pageController;
  BookChapterVerse _bcvPageZero;
  Volume _volume;
  Bible _bible;

  final _animatingToPage = false;

  @override
  void initState() {
    // dmPrint('_PageableChapterViewState initState for ${widget.viewState.uid} size ${widget.size}');
    super.initState();
    final viewData = context.tbloc<VolumeViewDataBloc>().state.asVolumeViewData;
    _volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
    _bible = _volume.assocBible();
    _bcvPageZero = viewData.bcv;
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          BlocListener<VolumeViewDataBloc, ViewData>(
            // Only listen for when the volume, book, chapter, or verse changes.
            listenWhen: (a, b) =>
                a.asVolumeViewData.volumeId != b.asVolumeViewData.volumeId ||
                a.asVolumeViewData.bcv != b.asVolumeViewData.bcv,
            listener: (context, viewData) => _onNewViewData(viewData.asVolumeViewData),
          ),
          BlocListener<SharedBibleRefBloc, BookChapterVerse>(listener: (context, sharedRef) {
            if (!_animatingToPage && mounted && _pageController != null && _bible != null) {
              handleSharedBibleRefChange(context, sharedRef);
            }
          }),
        ],
        child: PageableView(
          state: widget.viewState,
          size: widget.size,
          controllerBuilder: () {
            _pageController = TecPageController(initialPage: 0);
            return _pageController;
          },
          pageBuilder: _buildPage,
          onPageChanged: _onPageChanged,
        ),
      );

  ///
  /// This is called when the VolumeViewData volume, book, chapter, or verse changes.
  ///
  void _onNewViewData(VolumeViewData viewData) {
    if (!mounted || viewData == null || _volume == null) return;

    // dmPrint('PageableChapterView._onNewViewData $viewData');

    var volumeChanged = false;
    var volume = _volume;
    if (volume?.id != viewData.volumeId) {
      volumeChanged = true;
      volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
      if (volume == null) return; // --------------------------------------->
    }

    final page = _bcvPageZero.chaptersTo(viewData.bcv, bible: volume.assocBible());
    if (page == null) {
      // dmPrint('PageableChapterView._onNewViewData unable to navigate to '
      //     '${viewData.bcv} in ${volume.assocBible().abbreviation}');
      return; // ----------------------------------------------------------->
    }

    if (volumeChanged) {
      // dmPrint('PageableChapterView._onNewViewData: Volume changed '
      //     'from ${_volume.id} to ${volume.id}.');
      _volume = volume;
      _bible = volume.assocBible();
    }

    if (_pageController != null && _pageController.page.round() != page) {
      // dmPrint('PageableChapterView._onNewViewData: Page changed '
      //     'from ${_pageController.page.round()} to $page');
      _pageController?.jumpToPage(page);
    }
  }

  ///
  /// Builds and returns the page with the given [index].
  ///
  Widget _buildPage(BuildContext context, ViewState _, Size size, int index) {
    final ref = _bcvPageZero.advancedBy(chapters: index, bible: _bible);
    if (ref == null) return null;
    return BlocBuilder<VolumeViewDataBloc, ViewData>(
      // When the VolumeViewDataBloc changes, only rebuild if the volume changes.
      buildWhen: (a, b) => a.asVolumeViewData.volumeId != b.asVolumeViewData.volumeId,
      builder: (context, viewData) {
        if (viewData is VolumeViewData) {
          final volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
          var ref = _bcvPageZero.advancedBy(chapters: index, bible: volume.assocBible());
          if (ref == null) return Container();
          if (ref.book == viewData.bcv.book &&
              ref.chapter == viewData.bcv.chapter &&
              viewData.bcv.verse > 1) {
            ref = ref.copyWith(verse: viewData.bcv.verse);
          }
          // dmPrint('PageableChapterView.pageBuilder: creating ChapterView for '
          //     '${_bible.abbreviation} ${ref.toString()}');
          return _BibleChapterView(
            viewUid: widget.viewState.uid,
            size: size,
            volume: volume,
            ref: ref,
            padding: widget.htmlPadding,
          );
        } else {
          throw UnsupportedError('PageableChapterView must use VolumeViewData');
        }
      },
    );
  }

  ///
  /// Called when the page changes to the given [page].
  ///
  Future<void> _onPageChanged(BuildContext context, ViewState _, int page) async {
    final bcv = _bcvPageZero.advancedBy(chapters: page, bible: _bible);
    if (bcv != null) {
      // restore the sheet...
      Future.delayed(const Duration(milliseconds: 250), () {
        context.tbloc<SheetManagerBloc>().add(SheetEvent.main);
      });

      final viewData = context.tbloc<VolumeViewDataBloc>().state.asVolumeViewData;
      final newData = viewData.copyWith(
          bcv: viewData.bcv.book == bcv.book && viewData.bcv.chapter == bcv.chapter ? null : bcv,
          page: page);
      // dmPrint('PageableChapterView.onPageChanged: updating $viewData with new '
      //     'data: $newData');
      await context
          .tbloc<VolumeViewDataBloc>()
          .update(context, newData, updateSharedRef: !_animatingToPage);
    }
  }
}

class _BibleChapterView extends StatefulWidget {
  final int viewUid;
  final Size size;
  final Volume volume;
  final BookChapterVerse ref;
  final EdgeInsets padding;

  const _BibleChapterView({
    Key key,
    @required this.viewUid,
    @required this.size,
    @required this.volume,
    @required this.ref,
    this.padding,
  }) : super(key: key);

  @override
  _BibleChapterViewState createState() => _BibleChapterViewState();
}

class _BibleChapterViewState extends State<_BibleChapterView> {
  Future<ErrorOrValue<String>> _future;

  @override
  void initState() {
    // dmPrint('_BibleChapterView initState for ${widget.viewUid} size ${widget.size}');
    super.initState();
    _update();
  }

  @override
  void didUpdateWidget(_BibleChapterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volume.id != widget.volume.id || oldWidget.ref != widget.ref) {
      _update();
    }
  }

  void _update() {
    _future = chapterHtmlWith(widget.volume, widget.ref.book, widget.ref.chapter);
  }

  @override
  Widget build(BuildContext context) {
    // dmPrint('_BibleChapterView build for ${widget.viewUid} size ${widget.size}');
    return TecFutureBuilder<ErrorOrValue<String>>(
      future: _future,
      builder: (context, data, error) {
        final htmlFragment = data?.value;
        if (isNotNullOrEmpty(htmlFragment)) {
          return BlocBuilder<ContentSettingsBloc, ContentSettings>(builder: (context, settings) {
            return _ChapterView(
              viewUid: widget.viewUid,
              volume: widget.volume,
              ref: widget.ref,
              htmlFragment: htmlFragment,
              size: widget.size,
              padding: widget.padding,
            );
          });
        } else {
          // dmPrint('VIEW ${widget.viewUid} waiting for HTML to load...');
          return Container(
            color: Theme.of(context).backgroundColor,
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
  final Volume volume;
  final BookChapterVerse ref;
  final String htmlFragment;
  final Size size;
  final List<String> versesToShow;
  final EdgeInsets padding;

  const _ChapterView({
    Key key,
    @required this.viewUid,
    @required this.volume,
    @required this.ref,
    @required this.htmlFragment,
    @required this.size,
    this.versesToShow,
    this.padding,
  })  : assert(volume != null && htmlFragment != null),
        super(key: key);

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<_ChapterView> {
  @override
  void didUpdateWidget(_ChapterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.htmlFragment != widget.htmlFragment) _html = null;
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
    if (_html == null) {
      final customStyles = isBibleId(widget.volume.id)
          ? '.cno, .C { height: unset; margin-bottom: 0px; } '
           '.FOOTNO { line-height: inherit; top: inherit; } '
              'h5, .SUBA, h1 { font-weight: normal !important; '
              'font-style: italic; font-size: 100% !important; } '
          : ' p { line-height: 1.2em; } ';

      _html = _env.html(
        htmlFragment: widget.htmlFragment,
        fontSizePercent: (_contentScaleFactor * 100.0).round(),
        marginLeft: '0px',
        marginRight: '0px',
        marginTop: '0px',
        marginBottom: '160px',
        vendorFolder: widget.volume.vendorFolder,
        customStyles: customStyles,
      );

      // If it is a study volume, switch `bible_vendor.css` to `studynotes.css`.
      if (!isBibleId(widget.volume.id)) {
        _html = _html.replaceAll('bible_vendor.css', 'studynotes.css');
      }
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ChapterMarginNotesBloc(
              volumeId: widget.volume.id,
              book: widget.ref.book,
              chapter: widget.ref.chapter,
            ),
          ),
          BlocProvider(
            create: (context) => ChapterHighlightsBloc(
              volumeId: widget.volume.id,
              book: widget.ref.book,
              chapter: widget.ref.chapter,
            ),
          ),
        ],
        child: BlocBuilder<ChapterMarginNotesBloc, ChapterMarginNotes>(
          builder: (context, marginNotes) {
            return BlocBuilder<ChapterHighlightsBloc, ChapterHighlights>(
              builder: (context, highlights) {
                var userContentValid = true;
                if (marginNotes.loaded && marginNotes.volumeId != widget.volume.id) {
                  context
                      .tbloc<ChapterMarginNotesBloc>()
                      .add(MarginNotesEvent.changeVolumeId(widget.volume.id));
                  userContentValid = false;
                }

                if (highlights.loaded && highlights.volumeId != widget.volume.id) {
                  context
                      .tbloc<ChapterHighlightsBloc>()
                      .add(HighlightEvent.changeVolumeId(widget.volume.id));
                  userContentValid = false;
                }

                if (userContentValid && highlights.loaded && marginNotes.loaded) {
                  // dmPrint('loading ${widget.ref.chapter}');

                  return _ChapterHtml(
                    viewUid: widget.viewUid,
                    volumeId: widget.volume.id,
                    ref: widget.ref,
                    baseUrl: widget.volume.baseUrl,
                    html: _html,
                    versesToShow: widget.versesToShow ?? [],
                    // ['1', '2', '3']
                    size: widget.size,
                    fontName: context.tbloc<ContentSettingsBloc>().state.fontName,
                    highlights: highlights,
                    marginNotes: marginNotes,
                    padding: widget.padding,
                  );
                } else {
                  // dmPrint('VIEW ${widget.viewUid} waiting for highlights and margin notes');
                  return Container();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChapterHtml extends StatefulWidget {
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
  final EdgeInsets padding;

  const _ChapterHtml({
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
    this.padding,
  }) : super(key: key);

  @override
  _ChapterHtmlState createState() => _ChapterHtmlState();
}

class _ChapterHtmlState extends State<_ChapterHtml> {
  final _scrollController = ScrollController();
  final _wordSelectionController = TecSelectableController();
  ChapterSelection _selection;
  ChapterViewModel _viewModel;
  final _tecHtmlKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // dmPrint('New ChapterViewModel for ${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}');

    _selection = ChapterSelection(
        wordSelectionController: _wordSelectionController,
        widgetNeedsRebuild: (fn) => mounted ? setState(fn) : null,
        viewUid: widget.viewUid,
        volume: widget.volumeId,
        book: widget.ref.book,
        chapter: widget.ref.chapter);

    _wordSelectionController.addListener(() => _selection.onWordSelectionChanged(context));

    _viewModel = ChapterViewModel(
      globalKey: _tecHtmlKey,
      viewUid: widget.viewUid,
      volume: widget.volumeId,
      book: widget.ref.book,
      chapter: widget.ref.chapter,
      highlights: () => widget.highlights,
      marginNotes: () => widget.marginNotes,
      selection: _selection,
    );

    _scrollToVerse = widget.ref.verse;
  }

  var _scrollToVerse = 0;

  @override
  void dispose() {
    _wordSelectionController.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debugId = '${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}';
    // dmPrint('_ChapterHtml building TecHtml for $debugId ${widget.size}');

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final selectionColor = isDarkTheme ? Colors.white.withAlpha(48) : Colors.black.withAlpha(32);
    final selectedTextStyle =
        TextStyle(backgroundColor: isDarkTheme ? const Color(0xff393939) : const Color(0xffe6e6e6));

    // A new [ChapterBuildHelper] needs to be created for each build...
    final helper = ChapterBuildHelper(widget.volumeId, widget.versesToShow);

    final marginWidth = (widget.size.width * _marginPercent).roundToDouble();
    var padding = (widget.padding ?? EdgeInsets.zero);
    padding = padding.copyWith(
      left: padding.left + marginWidth,
      right: padding.right + marginWidth,
    );

    // dmPrint('rebuilding ${widget.ref} with size ${widget.size} ');

    return MultiBlocListener(
      listeners: [
        BlocListener<SelectionCmdBloc, SelectionCmd>(
          listener: (context, cmd) => _selection.handleCmd(context, cmd),
        ),
        BlocListener<VolumeViewDataBloc, ViewData>(
          listener: (context, viewData) {
            final newBcv = viewData.asVolumeViewData.bcv;
            if (newBcv.book == widget.ref.book && newBcv.chapter == widget.ref.chapter) {
              // dmPrint('Notifying of selections for ${widget.ref}');
              _selection.notifyOfSelections(context);
              // TO-DO(ron): Only scroll if the verse changes?
              if (newBcv.verse > 1 || _scrollController.offset > 0) {
                dmPrint('ChapterHtml ViewData changed, so scrolling to verse ${newBcv.verse}');
                _viewModel.scrollToVerse(newBcv.verse, _scrollController);
              }
            } else {
              // dmPrint('Ignoring selections in ${widget.ref}');
            }
          },
        )
      ],
      child: Semantics(
        //textDirection: textDirection,
        label: 'Bible text',
        child: ExcludeSemantics(
          child: TecAutoScroll(
            scrollController: _scrollController,
            allowAutoscroll: () => !context.tbloc<SelectionBloc>().state.isTextSelected,
            navigationBarPadding: () => context.fullBottomBarPadding,
            autoscrollActive: (active) {
              if (!active) {
                TecScrollListener.of(context)?.simulateReverse();
              }
            },
            child: TecScrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                children: <Widget>[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTapDown: _viewModel.onTapDownHandler,
                    onTapUp: _viewModel.onTapUpHandler,
                    onTap: () => _viewModel.onTapHandler(context),

                    // `TecOverflowBox` makes sure the `TecHtml` widget is not rebuilt
                    // during animated view size changes. It sets the width of `TecHtml`
                    // to `widget.size.width`, which is the width it will be when the
                    // animation finishes.
                    child: TecOverflowBox(
                      maxWidth: widget.size.width,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // dmPrint('Building TecHtml for ${widget.volumeId} ${widget.ref} '
                          //     'with size ${constraints.biggest}');
                          return TecHtml(
                            widget.html,
                            baseUrl: widget.baseUrl,
                            key: _tecHtmlKey,
                            debugId: debugId,
                            backgroundColor: Theme.of(context).backgroundColor,
                            avoidUsingWidgetSpans: true,
                            allowTextAlignJustify: false,
                            scrollController: _scrollController,
                            // The HTML is scaled via CSS.
                            textScaleFactor: 1.0,
                            textStyle: _htmlDefaultTextStyle.merge(widget.fontName.isEmpty
                                ? TextStyle(color: textColor)
                                : widget.fontName.startsWith('embedded_')
                                    ? TextStyle(
                                        color: textColor, fontFamily: widget.fontName.substring(9))
                                    : GoogleFonts.getFont(widget.fontName, color: textColor)),

                            padding: padding,

                            // Tagging HTML elements:
                            tagHtmlElement: helper.tagHtmlElement,

                            // Rendering HTML text to a TextSpan:
                            spanForText: (text, style, tag) {
                              // If scrolling to a verse > 1, add a post frame callback to do so.
                              // Note, we do it here, because until `spanForText` has been called,
                              // the HTML has not be rendered.
                              if (_scrollToVerse > 1) {
                                _scrollToVerse = 0;
                                dmPrint(
                                    'ChapterHtml post build will scroll to verse ${widget.ref.verse}');
                                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                  _viewModel.scrollToVerse(widget.ref.verse, _scrollController,
                                      animated: false);
                                });
                              }

                              return _viewModel.spanForText(
                                  context, text, style, tag, selectedTextStyle,
                                  isDarkTheme: isDarkTheme);
                            },

                            // Word range selection related:
                            selectable: !_selection.hasVerses,
                            selectionColor: selectionColor,
                            showSelection: !_selection.isInTrialMode,
                            selectionMenuItems: _selection.menuItems(context, _tecHtmlKey),
                            selectionController: _wordSelectionController,

                            // `versesToShow` related (when viewing a subset of verses in the chapter):
                            isInitialHtmlElementVisible:
                                widget.versesToShow.isEmpty || widget.versesToShow.contains('1'),
                            toggleVisibilityWithHtmlElement: helper.toggleVisibility,
                            shouldSkipHtmlElement: helper.shouldSkip,

                            /*
                            logStylesheetParsingErrors: true,
                            futureStringFromUrl: (url) async {
                              if (widget.volumeId == 91 && url.contains('bible_vendor.css')) {
                                return v91BibleVendorCss;
                              }
                              return textFromUrl(url);
                            }, */
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _lineSpacing = 1.35; // 1.4;
const _marginPercent = 0.05;

const TextStyle _htmlDefaultTextStyle = TextStyle(
  inherit: false,
  //fontFamily: TecPlatform.isIOS ? 'Avenir' : 'normal',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: _lineSpacing,
);

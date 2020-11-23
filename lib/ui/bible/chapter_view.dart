import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/content_settings.dart';
import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/margin_notes/margin_notes_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/shared_bible_ref_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../common/common.dart';
import '../common/tec_page_view.dart';
import 'chapter_build_helper.dart';
import 'chapter_selection.dart';
import 'chapter_view_data.dart';
import 'chapter_view_model.dart';

class PageableChapterView extends StatefulWidget {
  final ViewState state;
  final Size size;

  const PageableChapterView({Key key, this.state, this.size}) : super(key: key);

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
    // tec.dmPrint('_PageableChapterViewState initState for ${widget.state.uid} size ${widget.size}');
    super.initState();
    final viewData = context.tbloc<ChapterViewDataBloc>().state.asChapterViewData;
    _volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
    _bible = _volume.assocBible();
    _bcvPageZero = viewData.bcv;
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          BlocListener<ChapterViewDataBloc, ViewData>(
            // Only listen for when the volume, book, chapter, or verse changes.
            listenWhen: (a, b) =>
                a.asChapterViewData.volumeId != b.asChapterViewData.volumeId ||
                a.asChapterViewData.bcv != b.asChapterViewData.bcv,
            listener: (context, viewData) => _onNewViewData(viewData.asChapterViewData),
          ),
          BlocListener<SharedBibleRefBloc, BookChapterVerse>(listener: _sharedBibleRefChanged),
        ],
        child: PageableView(
          state: widget.state,
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
  /// This is called when the ChapterViewData volume, book, chapter, or verse changes.
  ///
  void _onNewViewData(ChapterViewData viewData) {
    if (!mounted || viewData == null || _volume == null) return;

    // tec.dmPrint('PageableChapterView._onNewViewData $viewData');

    var volumeChanged = false;
    var volume = _volume;
    if (volume?.id != viewData.volumeId) {
      volumeChanged = true;
      volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
      if (volume == null) return; // --------------------------------------->
    }

    final page = _bcvPageZero.chaptersTo(viewData.bcv, bible: volume.assocBible());
    if (page == null) {
      // tec.dmPrint('PageableChapterView._onNewViewData unable to navigate to '
      //     '${viewData.bcv} in ${volume.assocBible().abbreviation}');
      return; // ----------------------------------------------------------->
    }

    if (volumeChanged) {
      // tec.dmPrint('PageableChapterView._onNewViewData: Volume changed '
      //     'from ${_volume.id} to ${volume.id}.');
      _volume = volume;
      _bible = volume.assocBible();
    }

    if (_pageController != null && _pageController.page.round() != page) {
      // tec.dmPrint('PageableChapterView._onNewViewData: Page changed '
      //     'from ${_pageController.page.round()} to $page');
      _pageController?.jumpToPage(page);
    }
  }

  ///
  /// This is called when the shared bible reference changes.
  ///
  Future<void> _sharedBibleRefChanged(BuildContext context, BookChapterVerse sharedRef) async {
    if (!_animatingToPage && mounted && _pageController != null && _bible != null) {
      final viewDataBloc = context.tbloc<ChapterViewDataBloc>();
      final viewData = viewDataBloc.state.asChapterViewData;
      if (!viewDataBloc.isUpdatingSharedBibleRef &&
          viewData.useSharedRef &&
          viewData.bcv != sharedRef) {
        final newViewData = viewData.copyWith(bcv: sharedRef);
        // tec.dmPrint('PageableChapterView shared ref changed to $sharedRef, '
        //     'calling viewDataBloc.update with $newViewData');
        await viewDataBloc.update(context, newViewData, updateSharedRef: false);
      }
    }
  }

  ///
  /// Builds and returns the page with the given [index].
  ///
  Widget _buildPage(BuildContext context, ViewState _, Size size, int index) {
    final ref = _bcvPageZero.advancedBy(chapters: index, bible: _bible);
    if (ref == null) return null;
    return BlocBuilder<ChapterViewDataBloc, ViewData>(
      // When the ChapterViewDataBloc changes, only rebuild if the volume changes.
      buildWhen: (a, b) => a.asChapterViewData.volumeId != b.asChapterViewData.volumeId,
      builder: (context, viewData) {
        if (viewData is ChapterViewData) {
          final volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
          var ref = _bcvPageZero.advancedBy(chapters: index, bible: volume.assocBible());
          if (ref == null) return Container();
          if (ref.book == viewData.bcv.book &&
              ref.chapter == viewData.bcv.chapter &&
              viewData.bcv.verse > 1) {
            ref = ref.copyWith(verse: viewData.bcv.verse);
          }
          // tec.dmPrint('PageableChapterView.pageBuilder: creating ChapterView for '
          //     '${_bible.abbreviation} ${ref.toString()}');
          return _BibleChapterView(viewUid: widget.state.uid, size: size, volume: volume, ref: ref);
        } else {
          throw UnsupportedError('PageableChapterView must use ChapterViewData');
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
        context.tbloc<SheetManagerBloc>().add(SheetEvent.restore);
      });

      final viewData = context.tbloc<ChapterViewDataBloc>().state.asChapterViewData;
      final newData = viewData.copyWith(
          bcv: viewData.bcv.book == bcv.book && viewData.bcv.chapter == bcv.chapter ? null : bcv,
          page: page);
      // tec.dmPrint('PageableChapterView.onPageChanged: updating $viewData with new '
      //     'data: $newData');
      await context
          .tbloc<ChapterViewDataBloc>()
          .update(context, newData, updateSharedRef: !_animatingToPage);
    }
  }
}

class _BibleChapterView extends StatefulWidget {
  final int viewUid;
  final Size size;
  final Volume volume;
  final BookChapterVerse ref;

  const _BibleChapterView({
    Key key,
    @required this.viewUid,
    @required this.size,
    @required this.volume,
    @required this.ref,
  }) : super(key: key);

  @override
  _BibleChapterViewState createState() => _BibleChapterViewState();
}

class _BibleChapterViewState extends State<_BibleChapterView> {
  Future<tec.ErrorOrValue<String>> _future;

  @override
  void initState() {
    // tec.dmPrint('_BibleChapterView initState for ${widget.viewUid} size ${widget.size}');
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
    // tec.dmPrint('_BibleChapterView build for ${widget.viewUid} size ${widget.size}');
    return TecFutureBuilder<tec.ErrorOrValue<String>>(
      future: _future,
      builder: (context, data, error) {
        final htmlFragment = data?.value;
        if (tec.isNotNullOrEmpty(htmlFragment)) {
          return BlocBuilder<ContentSettingsBloc, ContentSettings>(builder: (context, settings) {
            return _ChapterView(
              viewUid: widget.viewUid,
              volume: widget.volume,
              ref: widget.ref,
              htmlFragment: htmlFragment,
              size: widget.size,
            );
          });
        } else {
          // tec.dmPrint('VIEW ${widget.viewUid} waiting for HTML to load...');
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

  const _ChapterView({
    Key key,
    @required this.viewUid,
    @required this.volume,
    @required this.ref,
    @required this.htmlFragment,
    @required this.size,
    this.versesToShow,
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
          ? ' .C, .cno { display: none; } '
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
                  // tec.dmPrint('loading ${widget.ref.chapter}');

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
                  );
                } else {
                  // tec.dmPrint('VIEW ${widget.viewUid} waiting for highlights and margin notes');
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
  }) : super(key: key);

  @override
  _ChapterHtmlState createState() => _ChapterHtmlState();
}

class _ChapterHtmlState extends State<_ChapterHtml> {
  final _scrollController = ScrollController();
  final _wordSelectionController = TecSelectableController();
  ChapterSelection _selection;
  ChapterViewModel _viewModel;
  double lastScrollOffset;

  final _tecHtmlKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    lastScrollOffset = 0;

    // tec.dmPrint('New ChapterViewModel for ${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}');

    _selection = ChapterSelection(
        wordSelectionController: _wordSelectionController,
        widgetNeedsRebuild: (fn) => mounted ? setState(fn) : null,
        viewUid: widget.viewUid,
        volume: widget.volumeId,
        book: widget.ref.book,
        chapter: widget.ref.chapter);

    _wordSelectionController.addListener(() => _selection.onWordSelectionChanged(context));

    _viewModel = ChapterViewModel(
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debugId = '${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}';
    // tec.dmPrint('_ChapterHtml building TecHtml for $debugId ${widget.size}');

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final selectionColor = isDarkTheme ? Colors.white.withAlpha(48) : Colors.black.withAlpha(32);
    final selectedTextStyle =
        TextStyle(backgroundColor: isDarkTheme ? const Color(0xff393939) : const Color(0xffe6e6e6));

    // A new [ChapterBuildHelper] needs to be created for each build...
    final helper = ChapterBuildHelper(widget.volumeId, widget.versesToShow);

    return MultiBlocListener(
      listeners: [
        BlocListener<SelectionCmdBloc, SelectionCmd>(
          listener: (context, cmd) => _selection.handleCmd(context, cmd),
        ),
        BlocListener<ChapterViewDataBloc, ViewData>(
          listener: (context, viewData) {
            final newBcv = viewData.asChapterViewData.bcv;
            if (newBcv.book == widget.ref.book && newBcv.chapter == widget.ref.chapter) {
              // tec.dmPrint('Notifying of selections for ${widget.ref}');
              _selection.notifyOfSelections(context);
              // TO-DO(ron): Only scroll if the verse changes?
              if (newBcv.verse > 1 || _scrollController.offset > 0) {
                tec.dmPrint('ChapterHtml ViewData changed, so scrolling to verse ${newBcv.verse}');
                _viewModel.scrollToVerse(newBcv.verse, _tecHtmlKey, _scrollController);
              }
            } else {
              // tec.dmPrint('Ignoring selections in ${widget.ref}');
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
            navigationBarPadding: () => TecScaffoldWrapper.navigationBarPadding,
            autoscrollActive: (active) {
              if (active) {
                tec.dmPrint('ChapterViewHtml: autoscroll is active, collapsing the bottom sheet.');
                context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse);
              } else {
                // tec.dmPrint('ChapterViewHtml autoscrollActive false, restoring the bottom sheet.');
                // context.tbloc<SheetManagerBloc>().restore(context);
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  const scrollBuffer = 3.0;
                  lastScrollOffset ??= notification.metrics.pixels - scrollBuffer - 1;
                  if (notification.metrics.pixels < (lastScrollOffset - scrollBuffer)) {
                    tec.dmPrint('ChapterViewHtml: scrolled up, restoring the bottom sheet.');
                    context.tbloc<SheetManagerBloc>().add(SheetEvent.restore);
                    lastScrollOffset = notification.metrics.pixels;
                  } else if (notification.metrics.pixels > (lastScrollOffset + scrollBuffer)) {
                    tec.dmPrint('ChapterViewHtml: scrolled down, collapsing the bottom sheet.');
                    context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse);
                    lastScrollOffset = notification.metrics.pixels;
                  }
                }
                return false;
              },
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: GestureDetector(
                    onTapUp: (details) => _viewModel.globalOffsetOfTap = details?.globalPosition,
                    onTap: () => _viewModel.onTapHandler(),
                    child: TecHtml(
                      widget.html,
                      backgroundColor: Theme.of(context).backgroundColor,
                      key: _tecHtmlKey,
                      debugId: debugId,
                      avoidUsingWidgetSpans: false,
                      scrollController: _scrollController,
                      baseUrl: widget.baseUrl,
                      textScaleFactor: 1.0,
                      // HTML is already scaled.
                      textStyle: _htmlDefaultTextStyle.merge(widget.fontName.isEmpty
                          ? TextStyle(color: textColor)
                          : widget.fontName.startsWith('embedded_')
                              ? TextStyle(
                                  color: textColor, fontFamily: widget.fontName.substring(9))
                              : GoogleFonts.getFont(widget.fontName, color: textColor)),

                      padding: EdgeInsets.symmetric(
                        horizontal: (widget.size.width * _marginPercent).roundToDouble(),
                      ),

                      // Tagging HTML elements:
                      tagHtmlElement: helper.tagHtmlElement,

                      // Rendering HTML text to a TextSpan:
                      spanForText: (text, style, tag) {
                        // If scrolling to a verse > 1, add a post frame callback to do so.
                        // Note, we do it here, because until `spanForText` has been called,
                        // the HTML has not be rendered.
                        if (_scrollToVerse > 1) {
                          _scrollToVerse = 0;
                          tec.dmPrint(
                              'ChapterHtml post build will scroll to verse ${widget.ref.verse}');
                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                            _viewModel.scrollToVerse(
                                widget.ref.verse, _tecHtmlKey, _scrollController,
                                animated: false);
                          });
                        }

                        return _viewModel.spanForText(context, text, style, tag, selectedTextStyle,
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
                    ),
                  ),
                ),
              ),
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

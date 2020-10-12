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

import '../../blocs/content_settings.dart';
import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/margin_notes/margin_notes_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/shared_bible_ref_bloc.dart';
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
    return PageableChapterView(state: state, size: size);
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
      final previous = ChapterViewData.fromContext(context, currentViewId);
      assert(previous != null);
      return previous.copyWith(volumeId: bibleId);
    }

    return null;
  }
}

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

  var _updatingSharedBibleRef = false;
  var _animatingToPage = false;

  @override
  void initState() {
    super.initState();
    final viewData = ChapterViewData.fromContext(context, widget.state.uid);
    _volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
    _bible = _volume.assocBible;
    _bcvPageZero = viewData.bcv;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewDataBloc(context.bloc<ViewManagerBloc>(), widget.state.uid,
          ChapterViewData.fromContext(context, widget.state.uid)),
      child: Scaffold(
        appBar: MinHeightAppBar(
          appBar: ChapterViewAppBar(
            volumeType: _volume is Bible ? VolumeType.bible : VolumeType.studyContent,
            viewState: widget.state,
            size: widget.size,
            onUpdate: _onUpdate,
          ),
        ),
        body: BlocListener<SharedBibleRefBloc, BookChapterVerse>(
          listener: (context, bcv) async {
            if (!_updatingSharedBibleRef &&
                !_animatingToPage &&
                mounted &&
                _pageController != null &&
                _bible != null &&
                ChapterViewData.fromContext(context, widget.state.uid).useSharedRef) {
              final currentPage = _pageController.page.round();
              final newPage = _bcvPageZero.chaptersTo(bcv, bible: _bible);
              if (newPage != null && newPage != currentPage) {
                _animatingToPage = true;
                await _pageController.animateToPage(newPage);
                _animatingToPage = false;
              }
            }
          },
          child: pageableView(),
        ),
      ),
    );
  }

  Widget pageableView() => PageableView(
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
                (before as ChapterViewData).volumeId != (after as ChapterViewData).volumeId,
            builder: (context, viewData) {
              if (viewData is ChapterViewData) {
                final volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
                final ref = _bcvPageZero.advancedBy(chapters: index, bible: volume.assocBible);
                if (ref == null) return Container();
                // tec.dmPrint('page builder: ${ref.toString()}');
                return _BibleChapterView(
                    viewUid: widget.state.uid, size: size, volume: volume, ref: ref);
              } else {
                throw UnsupportedError('PageableChapterView must use ChapterViewData');
              }
            },
          );
        },
        onPageChanged: (context, _, page) async {
          // tec.dmPrint('View ${widget.state.uid} onPageChanged($page)');
          context
              .bloc<SelectionStyleBloc>()
              ?.add(const SelectionStyle(type: HighlightType.clear, isTrialMode: true));
          final bcv = _bcvPageZero.advancedBy(chapters: page, bible: _bible);
          if (bcv != null) {
            final viewData = ChapterViewData.fromContext(context, widget.state.uid)
                .copyWith(bcv: bcv, page: page);
            // tec.dmPrint('PageableChapterView updating with new data: $viewData');
            context.bloc<ViewDataBloc>().update(viewData);

            if (!_animatingToPage && !_updatingSharedBibleRef && viewData.useSharedRef) {
              _updatingSharedBibleRef = true;
              context.bloc<SharedBibleRefBloc>().update(bcv);
              _updatingSharedBibleRef = false;
            }
          }
        },
      );

  void _onUpdate(
      BuildContext context, int newVolumeId, BookChapterVerse newBcv, VolumeViewData viewData) {
    if (!mounted || newVolumeId == null || newBcv == null) return;

    var volumeChanged = false;
    var volume = _volume;
    if (newVolumeId != viewData.volumeId) {
      volumeChanged = true;
      volume = VolumesRepository.shared.volumeWithId(newVolumeId);
      if (volume == null) return; // ---------------------------------------->
    }

    final page = _bcvPageZero.chaptersTo(newBcv, bible: volume.assocBible);
    if (page == null) {
      tec.dmPrint('BibleView unable to navigate to $newBcv in ${volume.assocBible.abbreviation}');
      return; // ---------------------------------------->
    }

    if (volumeChanged) {
      _volume = volume;
      _bible = volume.assocBible;
      if (viewData is ChapterViewData) {
        context
            .bloc<ViewDataBloc>()
            ?.update(viewData.copyWith(volumeId: volume.id, bcv: newBcv, page: page));
      }
    }
    if (newBcv != viewData.bcv) {
      _pageController?.jumpToPage(page);
    }
  }
}

Future<tec.ErrorOrValue<String>> _chapterHtmlWith(Volume volume, int book, int chapter) async {
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
    super.initState();
    _future = _chapterHtmlWith(widget.volume, widget.ref.book, widget.ref.chapter);
  }

  @override
  void didUpdateWidget(_BibleChapterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volume.id != widget.volume.id || oldWidget.ref != widget.ref) {
      _future = _chapterHtmlWith(widget.volume, widget.ref.book, widget.ref.chapter);
    }
  }

  @override
  Widget build(BuildContext context) {
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
    _html ??= _env.html(
      htmlFragment: widget.htmlFragment,
      fontSizePercent: (_contentScaleFactor * 100.0).round(),
      marginLeft: '0px',
      marginRight: '0px',
      marginTop: '0px',
      marginBottom: '160px',
      vendorFolder: widget.volume.vendorFolder,
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
                      .bloc<ChapterMarginNotesBloc>()
                      .add(MarginNotesEvent.changeVolumeId(widget.volume.id));
                  userContentValid = false;
                }

                if (highlights.loaded && highlights.volumeId != widget.volume.id) {
                  context
                      .bloc<ChapterHighlightsBloc>()
                      .add(HighlightEvent.changeVolumeId(widget.volume.id));
                  userContentValid = false;
                }

                if (userContentValid && highlights.loaded && marginNotes.loaded) {
                  // tec.dmPrint('loading ${widget.ref.chapter}');

                  return _BibleHtml(
                    viewUid: widget.viewUid,
                    volumeId: widget.volume.id,
                    ref: widget.ref,
                    baseUrl: widget.volume.baseUrl,
                    html: _html,
                    versesToShow: widget.versesToShow ?? [],
                    // ['1', '2', '3']
                    size: widget.size,
                    fontName: context.bloc<ContentSettingsBloc>().state.fontName,
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
  ChapterViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    // tec.dmPrint('New ChapterViewModel for ${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}');
    _viewModel = ChapterViewModel(
      viewUid: widget.viewUid,
      volume: widget.volumeId,
      book: widget.ref.book,
      chapter: widget.ref.chapter,
      versesToShow: () => widget.versesToShow,
      highlights: () => widget.highlights,
      marginNotes: () => widget.marginNotes,
      selectionController: _selectionController,
      refreshFunc: (fn) => mounted ? setState(fn) : null,
    );

    _selectionController.addListener(() => _viewModel.onSelectionChanged(context));
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
    // tec.dmPrint('_BibleHtml building TecHtml for $debugId ${widget.size}');

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final selectionColor = isDarkTheme ? Colors.white.withAlpha(48) : Colors.black.withAlpha(32);
    final selectedTextStyle =
        TextStyle(backgroundColor: isDarkTheme ? const Color(0xff393939) : const Color(0xffe6e6e6));

    // A new [TecHtmlBuildHelper] needs to be created for each build...
    final helper = _viewModel.tecHtmlBuildHelper();

    return MultiBlocListener(
      listeners: [
        BlocListener<SelectionStyleBloc, SelectionStyle>(
          listener: (context, selectionStyle) => _viewModel.selectionStyleChanged(
              context, selectionStyle, widget.volumeId, widget.ref.book, widget.ref.chapter),
        ),
        BlocListener<ViewDataBloc, ViewData>(
          listener: (context, viewData) {
            if ((viewData as ChapterViewData).bcv == widget.ref) {
              // tec.dmPrint('Notifying of selections for ${widget.ref}');
              _viewModel.notifyOfSelections(context);
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
                  avoidUsingWidgetSpans: false,
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
                  selectable: !_viewModel.hasVersesSelected,
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

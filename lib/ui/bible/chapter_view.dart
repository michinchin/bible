import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

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

    // pageBuilder
    pageBuilder: (context, state, size, index) {
      final bible = VolumesRepository.shared.bibleWithId(_bibleId);
      final ref = _initialReference.advancedBy(chapters: index, bible: bible);

      // If the bible doesn't have the given reference, or we advanced past either end, return null.
      if (ref == null || ref.advancedBy(chapters: -index, bible: bible) != _initialReference) {
        return null;
      }
      return _BibleChapterView(state: state, size: size, bible: bible, ref: ref);
    },

    // onPageChanged
    onPageChanged: (context, state, page) async {
      tec.dmPrint('View ${state.uid} onPageChanged($page)');
      final bible = VolumesRepository.shared.bibleWithId(_bibleId);
      if (bible != null) {
        final bcv = _initialReference.advancedBy(chapters: page, bible: bible);
        context.bloc<ViewManagerBloc>().add(ViewManagerEvent.setData(
            uid: state.uid, data: tec.toJsonString(_ChapterData(bcv, page))));
      }
    },
  );
}

Widget bibleChapterTitleBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) {
  final bible = VolumesRepository.shared.bibleWithId(_bibleId);
  final bcv = _ChapterData.fromJson(state.data).bcv;
  return CupertinoButton(
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
    child: Text(
      bible.titleWithHref('${bcv.book}/${bcv.chapter}'),
    ),
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
  final ViewState state;
  final Size size;
  final Bible bible;
  final BookChapterVerse ref;

  const _BibleChapterView({
    Key key,
    @required this.state,
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

const _lineSpacing = 1.4;
const _marginPercent = 0.05; // 0.05;

const TextStyle htmlTextStyle = TextStyle(
  inherit: false,
  //fontFamily: tec.platformIs(tec.Platform.iOS) ? 'Avenir' : 'normal',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: _lineSpacing,
);

class _ChapterView extends StatefulWidget {
  final int volumeId;
  final BookChapterVerse ref;
  final String baseUrl;
  final String html;
  final Size size;

  const _ChapterView({
    Key key,
    @required this.volumeId,
    @required this.ref,
    @required this.baseUrl,
    @required this.html,
    this.size,
  }) : super(key: key);

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<_ChapterView> {
  final _scrollController = ScrollController();
  var _env = const TecEnv();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  var _contentScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    final newContentScaleFactor = contentTextScaleFactorWith(context);
    if (newContentScaleFactor != _contentScaleFactor) {
      _contentScaleFactor = newContentScaleFactor;
    }

    final htmlFragment = widget.html;

    //final baseUrl = '${tec.streamUrl}/${widget.volumeId}/urlbase/';
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final useZondervanCss = widget.volumeId == 32;

    String vendorFolder;
    if (!(widget.baseUrl?.startsWith('http') ?? false)) {
      vendorFolder = useZondervanCss ? 'zondervan' : 'tecarta';
    }

    final cssClass = useZondervanCss ? 'C' : 'cno';
    final customStyles = ' .$cssClass { display: none; } ';

    if (_env.darkMode != isDarkTheme) {
      _env = _env.copyWith(darkMode: isDarkTheme);
    }

    final html = _env.html(
      htmlFragment: htmlFragment,
      fontSizePercent: (_contentScaleFactor * 100.0).round(),
      marginTop: '0px',
      vendorFolder: vendorFolder,
      customStyles: customStyles,
    );

    return Container(
      color: backgroundColor,
      child: ListView(
        controller: _scrollController,
        children: <Widget>[
          // const SizedBox(height: 16),
          // Center(
          //   child: TecText(
          //     Bible.refTitleFromHref('${widget.chapter.book}/${widget.chapter.chapter}'),
          //   ),
          // ),
          StreamBuilder<String>(
            stream: AppSettings.shared.contentFontName.stream,
            builder: (c, snapshot) {
              final fontName =
                  (snapshot.hasData ? snapshot.data : AppSettings.shared.contentFontName.value);

              return TecHtml(
                html,
                debugId: '${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}',
                selectable: !kIsWeb,
                scrollController: _scrollController,
                baseUrl: widget.baseUrl,
                textScaleFactor: 1.0, // HTML is already scaled.
                textStyle: fontName.isEmpty
                    ? htmlTextStyle.merge(TextStyle(color: textColor))
                    : GoogleFonts.getFont(fontName, color: textColor),
                padding: EdgeInsets.symmetric(
                  horizontal: (widget.size.width * _marginPercent).roundToDouble(),
                ),
                onLinkTap: null,
              );
            },
          ),
        ],
      ),
    );
  }
}

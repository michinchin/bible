import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_manager_bloc.dart';
import '../common/common.dart';
import '../common/tec_page_view.dart';

const bibleChapterType = 'BibleChapter';

Widget bibleChapterViewBuilder(BuildContext context, ViewState state, Size size) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');
  return PageableView(
    state: state,
    size: size,
    controllerBuilder: () {
      final chapterData = _ChapterData.fromJson(state.data);
      return TecPageController(initialPage: chapterData.page);
    },

    // pageBuilder
    pageBuilder: (context, state, size, index) {
      return BibleChapterView(state: state, size: size, pageIndex: index);
    },

    // onPageChanged
    onPageChanged: (context, state, page) {
      tec.dmPrint('View ${state.uid} onPageChanged($page)');
      final bcv = const BookChapterVerse(50, 1, 1).advancedBy(chapters: page, bible: _bible);
      context.bloc<ViewManagerBloc>().add(ViewManagerEvent.setData(
          uid: state.uid, data: tec.toJsonString(_ChapterData(bcv, page))));
    },
  );
}

class _ChapterData {
  final BookChapterVerse bcv;
  final int page;

  const _ChapterData(BookChapterVerse bcv, int page)
      : bcv = bcv ?? const BookChapterVerse(50, 1, 1),
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

Widget bibleChapterTitleBuilder(BuildContext context, ViewState state, Size size) {
  final bcv = _ChapterData.fromJson(state.data).bcv;
  return Text(Bible.refTitleFromHref('${bcv.book}/${bcv.chapter}'));
}

const _bible = Bible(id: 32);

class BibleChapterView extends StatelessWidget {
  final ViewState state;
  final Size size;
  final int pageIndex;

  const BibleChapterView({
    Key key,
    @required this.state,
    @required this.size,
    @required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ref = const BookChapterVerse(50, 1, 1).advancedBy(chapters: pageIndex, bible: _bible);
    return BlocProvider(
      create: (_) {
        tec.dmPrint(
            'BibleChapterView: creating ChapterBloc for ${_bible.id}/${ref.book}/${ref.chapter}');
        return ChapterBloc(
            volumes: TecVolumesRepository(const TecEnv()),
            volume: _bible.id,
            book: ref.book,
            chapter: ref.chapter);
      },
      child: BlocBuilder<ChapterBloc, ChapterState>(
        builder: (_, chapterState) {
          return chapterState.when<Widget>(
            loading: () => const Center(child: LoadingIndicator()),
            loadSuccess: (chapter) => _ChapterView(chapter: chapter, size: size),
            loadFailure: (e) => Center(child: Text(e.toString())),
          );
        },
      ),
    );
  }
}

class _ChapterView extends StatefulWidget {
  final Chapter chapter;
  final Size size;

  const _ChapterView({Key key, this.chapter, this.size}) : super(key: key);

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

  final _contentScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    // final newContentScaleFactor = contentTextScaleFactorWith(context);
    // if (newContentScaleFactor != _contentScaleFactor) {
    //   _contentScaleFactor = newContentScaleFactor;
    // }

    final htmlFragment = widget.chapter.html;

    final baseUrl = '${tec.streamUrl}/${widget.chapter.volumeId}/urlbase/';
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final useZondervanCss = widget.chapter.volumeId == 32;

    final cssClass = useZondervanCss ? 'C' : 'cno';
    final customStyles = ' .$cssClass { display: none; } ';

    if (_env.darkMode != isDarkTheme) {
      _env = _env.copyWith(darkMode: isDarkTheme);
    }

    final html = _env.html(
      htmlFragment: htmlFragment,
      fontSizePercent: (_contentScaleFactor * 100.0).round(),
      marginTop: '0px',
      //vendorFolder: useZondervanCss ? 'zondervan' : 'tecarta',
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
          TecHtml(
            html,
            debugId: '${widget.chapter.volumeId}/${widget.chapter.book}/${widget.chapter.chapter}',
            selectable: !kIsWeb,
            scrollController: _scrollController,
            baseUrl: baseUrl,
            textScaleFactor: 1.0, // HTML is already scaled.
            textStyle: htmlTextStyle.merge(TextStyle(color: textColor)),
            padding: EdgeInsets.symmetric(
              horizontal: (widget.size.width * 0.05).roundToDouble(),
            ),
            onLinkTap: null,
          ),
        ],
      ),
    );
  }
}

const TextStyle htmlTextStyle = TextStyle(
  inherit: false,
  //fontFamily: tec.platformIs(tec.Platform.iOS) ? 'Avenir' : 'normal',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: 1.5,
);

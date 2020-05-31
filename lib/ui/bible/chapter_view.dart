import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager_bloc.dart';
import '../common/common.dart';
import '../common/tec_page_view.dart';

const bibleChapterType = 'BibleChapter';

Widget bibleChapterViewBuilder(BuildContext context, ViewState state) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');
  return PageableView(
    state: state,
    controllerBuilder: () => TecPageController(initialPage: 0),
    pageBuilder: (context, state, index) {
      return BibleChapterView(state: state, pageIndex: index);
    },
  );
}

const _bible = Bible(id: 32);

class BibleChapterView extends StatelessWidget {
  final ViewState state;
  final int pageIndex;

  const BibleChapterView({Key key, @required this.state, @required this.pageIndex})
      : super(key: key);

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
            loadSuccess: (chapter) => LayoutBuilder(
              builder: (context, constraints) => _ChapterView(
                chapter: chapter,
                constraints: constraints,
              ),
            ),
            loadFailure: (e) => Center(child: Text(e.toString())),
          );
        },
      ),
    );
  }
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.green[300],
  //       borderRadius: const BorderRadius.all(Radius.circular(36)),
  //       //border: Border.all(),
  //     ),
  //     child: Center(
  //       child: Text(
  //         'Bible View ${state.uid}, Page $pageIndex',
  //         style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
  //       ),
  //     ),
  //   );
  // }
}

class _ChapterView extends StatefulWidget {
  final Chapter chapter;
  final BoxConstraints constraints;

  const _ChapterView({Key key, this.chapter, this.constraints}) : super(key: key);

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
          const SizedBox(height: 16),
          Center(
            child: TecText(
              Bible.refTitleFromHref('${widget.chapter.book}/${widget.chapter.chapter}'),
            ),
          ),
          TecHtml(
            html,
            debugId: '${widget.chapter.volumeId}/${widget.chapter.book}/${widget.chapter.chapter}',
            selectable: !kIsWeb,
            scrollController: _scrollController,
            baseUrl: baseUrl,
            textScaleFactor: 1.0, // HTML is already scaled.
            textStyle: htmlTextStyle.merge(TextStyle(color: textColor)),
            padding: EdgeInsets.symmetric(
              horizontal: (widget.constraints.maxWidth * 0.05).roundToDouble(),
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

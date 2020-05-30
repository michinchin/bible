import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_manager_bloc.dart';
import '../common/common.dart';
import '../common/tec_page_view.dart';

const bibleChapterType = 'BibleChapter';

Widget bibleChapterViewBuilder(BuildContext context, ViewState state) {
  // tec.dmPrint('bibleChapterViewBuilder for uid: ${state.uid}');
  return PageableView(
    state: state,
    controllerBuilder: () => TecPageController(initialPage: 1),
    pageBuilder: (context, state, index) {
      return (index >= -2 && index <= 2) ? BibleChapterView(state: state, pageIndex: index) : null;
    },
  );
}

class BibleChapterView extends StatelessWidget {
  final ViewState state;
  final int pageIndex;

  const BibleChapterView({Key key, @required this.state, @required this.pageIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChapterBloc(
          volumes: TecVolumesRepository(const TecEnv()), volume: 32, book: 50, chapter: 1),
      child: BlocBuilder<ChapterBloc, ChapterState>(
        builder: (_, chapterState) {
          return chapterState.when<Widget>(
            loading: () => const Center(child: LoadingIndicator()),
            loadSuccess: (chapter) => _ChapterView(chapter: chapter),
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

  const _ChapterView({Key key, this.chapter}) : super(key: key);

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<_ChapterView> {
  final _scrollController = ScrollController();
  final _env = TecEnv();

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

    final baseUrl = 'https://${_env.streamServerAndVersion}/${widget.chapter.volumeId}/urlbase/';
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final useZondervanCss = widget.chapter.volumeId == 32;

    final cssClass = useZondervanCss ? 'C' : 'cno';
    final customStyles = ' .$cssClass { display: none; } ';

    final html = _env.html(
      htmlFragment: htmlFragment,
      fontSizePercent: (_contentScaleFactor * 100.0).round(),
      //vendorFolder: useZondervanCss ? 'zondervan' : 'tecarta',
      customStyles: customStyles,
    );

    return Container(
      color: backgroundColor,
      child: ListView(
        controller: _scrollController,
        children: <Widget>[
          TecHtml(
            html,
            selectable: !kIsWeb,
            scrollController: _scrollController,
            baseUrl: baseUrl,
            textScaleFactor: 1.0, // HTML is already scaled.
            textStyle: htmlTextStyle.merge(TextStyle(color: textColor)),
            padding: null,
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

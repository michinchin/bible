import 'package:flutter/cupertino.dart';
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
import '../nav/nav.dart';

const bibleChapterType = 'BibleChapter';
const _bibleId = 51;

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
    onPageChanged: (context, state, page) async {
      tec.dmPrint('View ${state.uid} onPageChanged($page)');
      final bible = VolumesRepository.shared.bibleWithId(_bibleId);
      if (bible != null) {
        final bcv = const BookChapterVerse(50, 1, 1).advancedBy(chapters: page, bible: bible);
        context.bloc<ViewManagerBloc>().add(ViewManagerEvent.setData(
            uid: state.uid, data: tec.toJsonString(_ChapterData(bcv, page))));
      }
    },
  );
}

Widget bibleChapterTitleBuilder(BuildContext context, ViewState state, Size size) {
  final bible = VolumesRepository.shared.bibleWithId(_bibleId);
  final bcv = _ChapterData.fromJson(state.data).bcv;
  return CupertinoButton(
    onPressed: () {
      showTecModalPopup<void>(
        context: context,
        popupMode: TecPopupMode.slideDown,
        useRootNavigator: false,
        //builder: (context) => const Scaffold(appBar: ManagedViewAppBar(), body: Text('test')),
        builder: (context) => TecPopupSheet(child: Nav()),
        //builder: (context) => const TecPopupSheet(child: Text('test')),
      );

      // showTecDialog<void>(
      //   context: context,
      //   useRootNavigator: false,
      //   maxWidth: 400,
      //   builder: (context) {
      //     return Scaffold(appBar: const ManagedViewAppBar(), body: Nav());
      //   },
      // );

      // // Navigator.of(context).push<void>(TecPageRoute<void>(
      // //   fullscreenDialog: true,
      // //   builder: (context) => const Scaffold(appBar: ManagedViewAppBar(), body: Text('test')),
      // // ));
    },
    child: Text(
      bible.titleWithHref('${bcv.book}/${bcv.chapter}'),
    ),
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
    final _bible = VolumesRepository.shared.bibleWithId(_bibleId);
    final ref = const BookChapterVerse(50, 1, 1).advancedBy(chapters: pageIndex, bible: _bible);
    return FutureBuilder<tec.ErrorOrValue<String>>(
      future: _bible.chapterHtmlWith(ref.book, ref.chapter),
      builder: (context, snapshot) {
        final html = snapshot.hasData ? snapshot.data.value : null;
        if (tec.isNotNullOrEmpty(html)) {
          return _ChapterView(
            volumeId: _bible.id,
            ref: ref,
            baseUrl: _bible.baseUrl,
            html: html,
            size: size,
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

  final _contentScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    // final newContentScaleFactor = contentTextScaleFactorWith(context);
    // if (newContentScaleFactor != _contentScaleFactor) {
    //   _contentScaleFactor = newContentScaleFactor;
    // }

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
          TecHtml(
            html,
            debugId: '${widget.volumeId}/${widget.ref.book}/${widget.ref.chapter}',
            selectable: !kIsWeb,
            scrollController: _scrollController,
            baseUrl: widget.baseUrl,
            textScaleFactor: 1.0, // HTML is already scaled.
            textStyle: htmlTextStyle.merge(TextStyle(color: textColor)),
            padding: EdgeInsets.symmetric(
              horizontal: (widget.size.width * _marginPercent).roundToDouble(),
            ),
            onLinkTap: null,
          ),
        ],
      ),
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

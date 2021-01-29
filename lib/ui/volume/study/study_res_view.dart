import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../../blocs/content_settings.dart';
import '../../../models/app_settings.dart';
import '../../common/common.dart';
import '../../common/tec_auto_hide_app_bar.dart';
import '../../common/tec_interactive_viewer.dart';
import '../../common/tec_pdf_viewer.dart';
import '../volume_view_data_bloc.dart';
import 'shared_app_bar_bloc.dart';
import 'study_res_bloc.dart';
import 'study_res_card.dart';

const _altTopPadding = 130.0;

class StudyResView extends StatelessWidget {
  final Size viewSize;
  final EdgeInsets padding;

  const StudyResView({Key key, @required this.viewSize, @required this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: BlocBuilder<StudyResBloc, StudyRes>(
        builder: (context, studyRes) {
          final type = studyRes.res?.baseType;

          if (type == ResourceType.folder || type == ResourceType.link) {
            return _Folder(
                studyRes: studyRes,
                viewSize: viewSize,
                padding: studyRes.resId == 0 ? padding : padding.copyWith(top: _altTopPadding));
          }

          if (tec.isNotNullOrEmpty(studyRes.res?.filename)) {
            final url = VolumesRepository.shared
                .volumeWithId(studyRes.res.volumeId)
                .fileUrlForResource(studyRes.res);
            if (tec.isNotNullOrEmpty(url)) {
              // HTML
              if (url.endsWith('.html')) {
                return _Article(
                    studyRes: studyRes,
                    viewSize: viewSize,
                    padding: type == ResourceType.introduction
                        ? padding
                        : padding.copyWith(top: _altTopPadding));
              }

              // JPG
              if (url.endsWith('.jpg')) {
                return TecInteractiveViewer(
                    child: TecImage(url: url), caption: studyRes.res.caption);
              }

              // PDF
              if (url.endsWith('.pdf')) {
                return TecPdfViewer(url: url, caption: studyRes.res.caption);
              }
            }
          }

          if (type == ResourceType.studyNote) {
            // TODO(ron): Handle this case.
          }

          if (type == ResourceType.question) {
            // TODO(ron): Handle this case.
          }

          if (studyRes.error != null) {
            return Center(child: Text(studyRes.error.toString()));
          }

          if (studyRes.res == null) {
            return const Center(child: LoadingIndicator());
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(42),
              child: Text('Sorry, viewing $type is not yet supported.'),
            ),
          );
        },
      ),
    );
  }
}

class _Folder extends StatelessWidget {
  final StudyRes studyRes;
  final Size viewSize;
  final EdgeInsets padding;

  const _Folder({Key key, @required this.studyRes, @required this.viewSize, @required this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bible = VolumesRepository.shared.volumeWithId(studyRes.volumeId)?.assocBible();

    return tec.isNullOrEmpty(studyRes.children)
        ? const Center(child: LoadingIndicator())
        : TecScrollbar(
            // Use ScrollablePositionedList?
            child: ListView.builder(
              // physics: const AlwaysScrollableScrollPhysics(),
              itemCount: studyRes.children.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return SizedBox(height: padding.top);
                final res = studyRes.children[index - 1];
                return StudyResCard(
                  res: res,
                  parent: studyRes.res,
                  bible: bible,
                  onTap: () => onTap(context, res),
                );
              },
            ),
          );
  }

  void onTap(BuildContext context, Resource res) {
    // If it is a Reference, just update VolumeViewDataBloc with the reference and return.
    if (res.hasType(ResourceType.reference)) {
      if (res.book != null && res.book > 0 && res.chapter != null && res.chapter > 0) {
        final viewData = context.read<VolumeViewDataBloc>().state.asVolumeViewData;
        final bcv = BookChapterVerse(res.book, res.chapter, res.verse ?? 1);
        final newData = viewData.copyWith(bcv: bcv);
        context.read<VolumeViewDataBloc>().update(context, newData);
      }
      return;
    }

    final appBarBloc = context.read<SharedAppBarBloc>();
    final prevAppBarState = appBarBloc.state;
    appBarBloc.updateWith(
      title: res.title,
      onTapBack: () {
        Navigator.of(context).maybePop();
        context.read<SharedAppBarBloc>().update(prevAppBarState);
      },
    );

    context.read<TecAutoHideAppBarBloc>()?.hide(false);
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            body: BlocProvider<StudyResBloc>(
              create: (context) => StudyResBloc.withResource(res),
              child: StudyResView(viewSize: viewSize, padding: padding),
            ),
          );
        },
      ),
    );
  }
}

class _Article extends StatelessWidget {
  final StudyRes studyRes;
  final Size viewSize;
  final EdgeInsets padding;

  const _Article(
      {Key key, @required this.studyRes, @required this.viewSize, @required this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return tec.isNullOrEmpty(studyRes.html)
        ? const Center(child: LoadingIndicator())
        : TecScrollbar(
            child: SingleChildScrollView(
              child: BlocBuilder<ContentSettingsBloc, ContentSettings>(
                builder: (context, settings) {
                  final marginWidth = (viewSize.width * _marginPercent).roundToDouble();
                  var _padding = (padding ?? EdgeInsets.zero);
                  _padding = padding.copyWith(
                    left: padding.left + marginWidth,
                    right: padding.right + marginWidth,
                  );

                  if (kIsWeb) return Text(studyRes.html);

                  return TecHtml(
                    studyRes.html,
                    baseUrl: VolumesRepository.shared.volumeWithId(studyRes.volumeId)?.baseUrl,
                    backgroundColor: Theme.of(context).backgroundColor,
                    textScaleFactor: contentTextScaleFactorWith(context),
                    padding: _padding,
                  );
                },
              ),
            ),
          );
  }
}

const _marginPercent = 0.05; // 0.05;

class DraggablePositioned extends StatefulWidget {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;
  final Widget child;

  const DraggablePositioned({
    @required this.child,
    Key key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
  })  : assert(left == null || right == null || width == null),
        assert(top == null || bottom == null || height == null),
        super(key: key);

  @override
  _DraggablePositionedState createState() => _DraggablePositionedState();
}

class _DraggablePositionedState extends State<DraggablePositioned> {
  double _left;
  double _top;
  double _right;
  double _bottom;
  double _width;
  double _height;

  @override
  void initState() {
    super.initState();
    _left = widget.left;
    _top = widget.top;
    _right = widget.right;
    _bottom = widget.bottom;
    _width = widget.width;
    _height = widget.height;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _left,
      top: _top,
      right: _right,
      bottom: _bottom,
      width: _width,
      height: _height,
      child: GestureDetector(
        onPanUpdate: (pan) {
          setState(() {
            if (_bottom != null && _top == null) _bottom = math.min(0.0, _bottom - pan.delta.dy);
          });
        },
        child: widget.child,
      ),
    );
  }
}

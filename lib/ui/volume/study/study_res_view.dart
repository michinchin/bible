import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../../blocs/content_settings.dart';
import '../../../models/app_settings.dart';
import '../../common/common.dart';
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
          switch (type) {
            case ResourceType.folder:
            case ResourceType.link:
              tec.dmPrint('StudyResView handled type $type');
              return _Folder(
                  studyRes: studyRes,
                  viewSize: viewSize,
                  padding: studyRes.resId == 0 ? padding : padding.copyWith(top: _altTopPadding));
              break;

            case ResourceType.chart:
            case ResourceType.map:
            case ResourceType.image:
            case ResourceType.video:
            case ResourceType.interactive:
            case ResourceType.timeline:
              // TO-DO(ron): Handle this case.
              break;

            case ResourceType.article:
            case ResourceType.introduction:
              return _Article(
                  studyRes: studyRes,
                  viewSize: viewSize,
                  padding: type == ResourceType.introduction
                      ? padding
                      : padding.copyWith(top: _altTopPadding));
              break;

            case ResourceType.reference:
              // TO-DO(ron): Handle this case.
              break;

            case ResourceType.studyNote:
              // TO-DO(ron): Handle this case.
              break;

            case ResourceType.question:
              // TO-DO(ron): Handle this case.
              break;

            default:
              // TO-DO(ron): Handle this case.
              tec.dmPrint('StudyResView unhandled type $type');
              break;
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
                  child: Text('Sorry, viewing $type is not yet supported.')));
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
    final appBarBloc = context.read<SharedAppBarBloc>();
    final prevAppBarState = appBarBloc.state;
    appBarBloc.updateWith(
      title: res.title,
      onTapBack: () {
        Navigator.of(context).maybePop();
        context.read<SharedAppBarBloc>().update(prevAppBarState);
      },
    );

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

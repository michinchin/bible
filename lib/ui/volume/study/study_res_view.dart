import 'dart:math' as math;

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
              return _Folder(
                  studyRes: studyRes,
                  viewSize: viewSize,
                  padding: studyRes.resId == 0 ? padding : padding.copyWith(top: _altTopPadding));
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

            case ResourceType.chart:
            case ResourceType.map:
            case ResourceType.image:
            case ResourceType.video:
            case ResourceType.interactive:
            case ResourceType.timeline:
              if (studyRes.res.filename.endsWith('.jpg')) {
                return _Image(studyRes: studyRes, viewSize: viewSize, padding: padding);
              }
              break;

            case ResourceType.reference:
            // TO-DO(ron): Handle this case.

            case ResourceType.studyNote:
            // TO-DO(ron): Handle this case.

            case ResourceType.question:
            // TO-DO(ron): Handle this case.

            default:
              // TO-DO(ron): Handle this case.
              if (type != null) tec.dmPrint('StudyResView unhandled type $type');
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

class _Image extends StatelessWidget {
  final StudyRes studyRes;
  final Size viewSize;
  final EdgeInsets padding;

  const _Image({Key key, @required this.studyRes, @required this.viewSize, @required this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final res = studyRes.res;
    final imageUrl =
        VolumesRepository.shared.volumeWithId(res.volumeId)?.fileUrlForResource(studyRes.res);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(60),
              minScale: 0.1,
              maxScale: 4.0,
              child: Center(child: TecImage(url: imageUrl)), // fit: BoxFit.none),
            ),
            if (tec.isNotNullOrEmpty(studyRes.res.caption))
              BlocBuilder<TecAutoHideAppBarBloc, bool>(
                builder: (context, hide) {
                  return AnimatedPositioned(
                    duration: _duration,
                    bottom: hide ? -100.0 : 0.0,
                    right: 0,
                    left: 0,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: _duration,
                        opacity: hide ? 0 : 1,
                        child: Material(
                          //type: MaterialType.transparency,
                          color: isDarkTheme ? const Color(0xCC333333) : const Color(0xCC666666),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                studyRes.res.caption,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkTheme
                                      ? const Color(0xFFAAAAAA)
                                      : const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      onTap: () => context.read<TecAutoHideAppBarBloc>()?.toggle(),
    );
  }
}

const _duration = Duration(milliseconds: 300);

class _MoveableStackChild extends StatefulWidget {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;
  final Widget child;

  const _MoveableStackChild({
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
  __MoveableStackChildState createState() => __MoveableStackChildState();
}

class __MoveableStackChildState extends State<_MoveableStackChild> {
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

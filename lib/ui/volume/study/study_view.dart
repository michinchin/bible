import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../../blocs/shared_bible_ref_bloc.dart';
import '../../common/common.dart';
import '../../common/tec_scroll_listener.dart';
import '../chapter/chapter_view.dart';
import '../volume_view_data_bloc.dart';
import 'study_res_bloc.dart';
import 'study_res_view.dart';
import 'study_view_bloc.dart';

class StudyView extends StatefulWidget {
  final ViewState viewState;
  final Size size;

  const StudyView({Key key, this.viewState, this.size}) : super(key: key);

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SharedBibleRefBloc, BookChapterVerse>(
      listener: _sharedBibleRefChanged,
      child: BlocProvider(
        create: (_) => StudyViewBloc()
          ..updateWithData(context.read<VolumeViewDataBloc>().state.asVolumeViewData),
        child: BlocListener<VolumeViewDataBloc, ViewData>(
          listener: (context, viewData) =>
              context.read<StudyViewBloc>().updateWithData(viewData as VolumeViewData),
          child: BlocBuilder<StudyViewBloc, StudyViewState>(
            builder: (context, state) {
              // tec.dmPrint('StudyView.build in StudyViewBloc volume: ${state.volumeId}');
              if (state.sections == null || state.sections.isEmpty) {
                return const Center(child: LoadingIndicator());
              }

              const aboutTitle = 'About';
              const introTitle = 'Intro';
              const resourcesTitle = 'Resources';
              const notesTitle = 'Notes';
              const titles = [aboutTitle, introTitle, resourcesTitle, notesTitle];

              final tabTitles = state.sections.map((e) => titles[e.index]).toList();
              final textStyle = Theme.of(context).textTheme.headline2;

              const _headerHeight = 70.0;

              Widget childForTab(String title) {
                switch (title) {
                  case aboutTitle:
                  case introTitle:
                    return _ScrollConnector(
                      scrollController: _scrollController,
                      height: _headerHeight,
                      child: BlocProvider(
                        create: (_) {
                          final viewData =
                              context.read<VolumeViewDataBloc>().state.asVolumeViewData;
                          return StudyResBloc(
                              volumeId: viewData.volumeId,
                              book: title == introTitle ? viewData.bcv.book : 0,
                              chapter: 0,
                              type: ResourceType.introduction);
                        },
                        child: BlocListener<VolumeViewDataBloc, ViewData>(
                          listener: (context, viewData) {
                            if (viewData is VolumeViewData) {
                              // tec.dmPrint('childForTab VolumeViewDataBloc listener volume: '
                              //     '${viewData.volumeId} book: ${viewData.bcv.book}');
                              context.read<StudyResBloc>().update(
                                  volumeId: viewData.volumeId,
                                  book: title == introTitle ? viewData.bcv.book : 0);
                            }
                          },
                          child: const StudyResView(),
                        ),
                      ),
                    );
                  case notesTitle:
                    return _ScrollConnector(
                      scrollController: _scrollController,
                      height: _headerHeight,
                      child: PageableChapterView(viewState: widget.viewState, size: widget.size),
                    );
                  default:
                    return Center(child: Text(title, style: textStyle));
                }
              }

              final tabs = tabTitles.map((e) => Tab(text: e)).toList();
              final tabContents = tabTitles.map(childForTab).toList();

              return DefaultTabController(
                length: tabs.length,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        // backgroundColor: Colors.orange[100],
                        elevation: 0,
                        floating: true,
                        snap: true,
                        expandedHeight: 30.0,
                        flexibleSpace: OverflowBox(
                          maxHeight: double.infinity,
                          child: Container(
                            color: Theme.of(context).backgroundColor,
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Center(child: TabBar(tabs: tabs, isScrollable: true)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        child: TabBarView(children: tabContents),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  ///
  /// This is called when the shared bible reference changes.
  ///
  Future<void> _sharedBibleRefChanged(BuildContext context, BookChapterVerse sharedRef) async {
    if (mounted) {
      final viewDataBloc = context.read<VolumeViewDataBloc>();
      final viewData = viewDataBloc.state.asVolumeViewData;
      if (!viewDataBloc.isUpdatingSharedBibleRef &&
          viewData.useSharedRef &&
          viewData.bcv != sharedRef) {
        final newViewData = viewData.copyWith(bcv: sharedRef);
        // tec.dmPrint('StudyView shared ref changed to $sharedRef, '
        //     'calling viewDataBloc.update with $newViewData');
        await viewDataBloc.update(context, newViewData, updateSharedRef: false);
      }
    }
  }
}

class _ScrollConnector extends StatelessWidget {
  final Widget child;
  final double height;
  final ScrollController scrollController;

  const _ScrollConnector({
    Key key,
    @required this.scrollController,
    @required this.height,
    @required this.child,
  })  : assert(scrollController != null && height != null && child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TecScrollListener(
      axisDirection: AxisDirection.down,
      changedDirection: (direction) {
        if (direction == ScrollDirection.reverse) {
          scrollController._scroll(-height);
        } else if (direction == ScrollDirection.forward) {
          scrollController._scroll(height);
        }
      },
      child: child,
    );
  }
}

extension on ScrollController {
  void _scroll(double delta) {
    animateTo(offset + delta, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }
}

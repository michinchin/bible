import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../bible/chapter_view.dart';
import '../common/common.dart';
import '../common/tec_scroll_listener.dart';
import 'study_view_bloc.dart';
import 'volume_view_data_bloc.dart';

class StudyView extends StatefulWidget {
  final ViewState viewState;
  final Size size;
  final VolumeViewData viewData;

  const StudyView({Key key, this.viewState, this.size, this.viewData}) : super(key: key);

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudyViewBloc()..updateWithData(widget.viewData),
      child: BlocBuilder<StudyViewBloc, StudyViewState>(
        builder: (context, state) {
          if (state.sections == null || state.sections.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          final tabTitles =
              state.sections.map((e) => ['About', 'Intro', 'Resources', 'Notes'][e.index]).toList();
          final textStyle = Theme.of(context).textTheme.headline2;

          Widget childForTab(String title) {
            final index = tabTitles.indexOf(title);
            switch (index) {
              case 3:
                return _ScrollConnector(
                  scrollController: _scrollController,
                  height: 120,
                  child: StudyNotes(viewState: widget.viewState, size: widget.size),
                );
              default:
                return Center(child: Text(title, style: textStyle));
            }
          }

          final tabs = tabTitles.map((e) => Tab(text: e)).toList();
          final tabContents = tabTitles.map(childForTab).toList();

          final volume = VolumesRepository.shared.volumeWithId(state.volumeId);

          return BlocListener<VolumeViewDataBloc, ViewData>(
            listener: (context, viewData) {
              context.read<StudyViewBloc>().updateWithData(viewData as VolumeViewData);
            },
            child: DefaultTabController(
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
                      expandedHeight: 102, // kTextTabBarHeight,
                      flexibleSpace: OverflowBox(
                        maxHeight: double.infinity,
                        child: Container(
                          color: Theme.of(context).backgroundColor,
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
                              Text(
                                volume?.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              ),
                              Center(
                                child: TabBar(
                                  tabs: tabs,
                                  isScrollable: true,
                                ),
                              ),
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
            ),
          );
        },
      ),
    );
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

class StudyNotes extends StatelessWidget {
  final ViewState viewState;
  final Size size;

  const StudyNotes({Key key, this.viewState, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageableChapterView(viewState: viewState, size: size);
  }
}

extension on ScrollController {
  void _scroll(double delta) {
    animateTo(offset + delta, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }
}

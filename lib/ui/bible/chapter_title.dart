import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/search_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/user_item_helper.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../nav/nav.dart';
import '../sheet/selection_sheet_model.dart';
import '../volume/study_view_data.dart';
import 'chapter_view_data.dart';

class ChapterTitle extends StatelessWidget {
  final VolumeType volumeType;

  const ChapterTitle({Key key, this.volumeType = VolumeType.anyType})
      : assert(volumeType == VolumeType.bible || volumeType == VolumeType.studyContent),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterViewDataBloc, ViewData>(
      builder: (context, viewData) {
        // tec.dmPrint('rebuilding PageableBibleView title with $viewData');
        if (viewData is ChapterViewData) {
          const minFontSize = 10.0;
          const buttonPadding = EdgeInsets.only(top: 16.0, bottom: 16.0);
          final buttonStyle = Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Theme.of(context).textColor.withOpacity(0.5));
          final autosizeGroup = TecAutoSizeGroup();

          final volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);

          return Row(
            children: [
              Container(
                padding: EdgeInsets.zero,
                width: 32.0,
                child: BlocBuilder<SearchBloc, SearchState>(
                    cubit: context.tbloc<SearchBloc>(),
                    builder: (c, s) => IconButton(
                        padding: const EdgeInsets.only(right: 8.0),
                        iconSize: 20,
                        icon: s.searchResults.isNotEmpty
                            ? const IconWithNumberBadge(
                                color: Colors.orange,
                                icon: FeatherIcons.search,
                              )
                            : const Icon(FeatherIcons.search),
                        tooltip: 'Search',
                        color: Theme.of(context).textColor.withOpacity(0.5),
                        onPressed: () => _onNavigate(context, viewData, searchView: true))),
              ),
              Flexible(
                flex: 3,
                child: CupertinoButton(
                  minSize: 0,
                  padding: buttonPadding,
                  child: TecAutoSizeText(
                    viewData.bookNameAndChapter,
                    minFontSize: minFontSize,
                    maxLines: 1,
                    group: autosizeGroup,
                    style: buttonStyle,
                  ),
                  onPressed: () => _onNavigate(context, viewData),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Container(
                  color: Theme.of(context).textColor.withOpacity(0.2),
                  width: 1,
                  height: const MinHeightAppBar().preferredSize.height *
                      .55, // 22 * textScaleFactorWith(context),
                ),
              ),
              Flexible(
                child: CupertinoButton(
                  minSize: 0,
                  padding: buttonPadding,
                  child: TecAutoSizeText(
                    volume?.abbreviation ?? '',
                    minFontSize: minFontSize,
                    group: autosizeGroup,
                    maxLines: 1,
                    style: buttonStyle,
                  ),
                  onPressed: () => _onSelectVolume(context, viewData),
                ),
              ),
            ],
          );
        } else {
          throw UnsupportedError('ChapterTitle must use ChapterViewData');
        }
      },
    );
  }

  Future<void> _onNavigate(BuildContext context, ChapterViewData viewData,
      {int initialIndex = 0, bool searchView = false}) async {
    TecAutoScroll.stopAutoscroll();

    final ref = await navigate(
        context, Reference.fromHref(viewData.bcv.toString(), volume: viewData.volumeId),
        initialIndex: initialIndex, searchView: searchView);

    if (ref != null) {
      // Save navigation ref to nav history.
      unawaited(UserItemHelper.saveNavHistoryItem(ref));

      // Small delay to allow the nav popup to clean up...
      await Future.delayed(const Duration(milliseconds: 350), () {
        final newViewData = context
            .tbloc<ChapterViewDataBloc>()
            .state
            .asChapterViewData
            .copyWith(bcv: BookChapterVerse.fromRef(ref));
        tec.dmPrint('ChapterTitle _onNavigate updating with new data: $newViewData');
        context.tbloc<ChapterViewDataBloc>().update(context, newViewData);
      });
    }
  }

  Future<void> _onSelectVolume(BuildContext context, ChapterViewData viewData) async {
    TecAutoScroll.stopAutoscroll();

    final volumeId = await selectVolumeInLibrary(context,
        title: 'Switch To...', selectedVolume: viewData.volumeId);

    ChapterViewData newViewData;
    if (volumeId != null) {
      final previous = context.tbloc<ChapterViewDataBloc>().state.asChapterViewData;
      assert(previous != null);
      if (isBibleId(volumeId)) {
        newViewData =
            ChapterViewData(volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
      } else if (isStudyVolumeId(volumeId)) {
        newViewData =
            StudyViewData(0, volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
      } else {
        assert(false);
      }
    }

    if (newViewData != null) {
      tec.dmPrint('ChapterTitle _onSelectVolume updating with new data: $newViewData');
      await context.tbloc<ChapterViewDataBloc>().update(context, newViewData);
    }
  }
}

class SelectionModeBibleChapterTitle extends StatelessWidget {
  final int uid;
  const SelectionModeBibleChapterTitle(this.uid);
  @override
  Widget build(BuildContext context) {
    const minFontSize = 10.0;
    final autosizeGroup = TecAutoSizeGroup();
    final buttonStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: Theme.of(context).textColor.withOpacity(0.5));

    // ignore: close_sinks
    final vmBloc = context.viewManager;

    final ref = tec.as<Reference>(vmBloc.selectionObjectWithViewUid(uid));
    return Row(children: [
      Container(
        padding: EdgeInsets.zero,
        width: 32.0,
        child: IconButton(
            padding: const EdgeInsets.only(right: 8.0),
            icon: const Icon(Icons.close),
            tooltip: 'Search',
            color: Theme.of(context).textColor.withOpacity(0.5),
            onPressed: () => SelectionSheetModel.deselect(context)),
      ),
      Expanded(
        child: TecAutoSizeText(
          ref.label(),
          minFontSize: minFontSize,
          group: autosizeGroup,
          maxLines: 1,
          style: buttonStyle,
        ),
      ),
    ]);
  }
}

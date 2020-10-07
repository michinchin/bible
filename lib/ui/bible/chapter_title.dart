import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_data/volume_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/user_item_helper.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../nav/nav.dart';
import '../sheet/selection_sheet_model.dart';

class ChapterTitle extends StatelessWidget {
  final VolumeType volumeType;
  final void Function(
          BuildContext context, int newVolumeId, BookChapterVerse newBcv, VolumeViewData viewData)
      onUpdate;

  const ChapterTitle({Key key, this.volumeType = VolumeType.anyType, @required this.onUpdate})
      : assert(volumeType == VolumeType.bible || volumeType == VolumeType.studyContent),
        assert(onUpdate != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewDataBloc, ViewData>(
      builder: (context, viewData) {
        // tec.dmPrint('rebuilding PageableBibleView title with $viewData');
        if (viewData is VolumeViewData) {
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
                padding: const EdgeInsets.all(0),
                width: 32.0,
                child: IconButton(
                    padding: const EdgeInsets.only(right: 8.0),
                    icon: const Icon(FeatherIcons.search, size: 20),
                    tooltip: 'Search',
                    color: Theme.of(context).textColor.withOpacity(0.5),
                    onPressed: () => _onNavigate(context, viewData)),
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
                  // onPressed: () =>
                  //     onNavigate(context, viewData, initialIndex: NavTabs.translation.index),
                  onPressed: () => _onSelectVolume(context, viewData),
                ),
              ),
            ],
          );
        } else {
          throw UnsupportedError('ChapterTitle must use VolumeViewData');
        }
      },
    );
  }

  Future<void> _onNavigate(BuildContext context, VolumeViewData viewData,
      {int initialIndex = 0}) async {
    TecAutoScroll.stopAutoscroll();

    final ref = await navigate(
        context, Reference.fromHref(viewData.bcv.toString(), volume: viewData.volumeId),
        initialIndex: initialIndex);

    if (ref != null) {
      // Save navigation ref to nav history.
      unawaited(UserItemHelper.saveNavHistoryItem(ref));

      // Small delay to allow the nav popup to clean up...
      await Future.delayed(const Duration(milliseconds: 350), () {
        onUpdate(context, ref.volume, BookChapterVerse.fromRef(ref), viewData);
      });
    }
  }

  Future<void> _onSelectVolume(BuildContext context, VolumeViewData viewData) async {
    TecAutoScroll.stopAutoscroll();
    final volumeTypeName = volumeType == VolumeType.bible
        ? 'Bible'
        : volumeType == VolumeType.studyContent
            ? 'Study Content'
            : 'Something';
    final bibleId = await selectVolume(context,
        title: 'Select $volumeTypeName',
        filter: VolumesFilter(volumeType: volumeType),
        selectedVolume: viewData.volumeId);

    onUpdate(context, bibleId, viewData.bcv, viewData);
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
    final vmBloc = context.bloc<ViewManagerBloc>();

    final ref = tec.as<Reference>(vmBloc.selectionObjectWithViewUid(uid));
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(0),
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

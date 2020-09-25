import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_data/volume_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../common/bible_chapter_title.dart';
import '../misc/view_actions.dart';
import '../sheet/selection_sheet_model.dart';

class ChapterViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ViewState viewState;
  final Size size;
  final SelectionState selectionState;
  final void Function(
          BuildContext context, int newBibleId, BookChapterVerse newBcv, VolumeViewData viewData)
      onUpdate;
  const ChapterViewAppBar({Key key, this.viewState, this.size, this.selectionState, this.onUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionInViewsCubit, Iterable<int>>(
        cubit: context.bloc<SelectionInViewsCubit>(),
        builder: (context, state) {
          final visibleViewsWithSelections = state;
          return BlocBuilder<SelectionBloc, SelectionState>(builder: (context, s) {
            if (s.isTextSelected && visibleViewsWithSelections.contains(viewState.uid)) {
              return AppBar(
                centerTitle: false,
                title: SelectionModeBibleChapterTitle(viewState.uid),
                actions: [
                  IconButton(
                    icon: const Icon(FeatherIcons.play),
                    iconSize: 20,
                    onPressed: () {},
                  ),
                  IconButton(
                      icon: const Icon(FeatherIcons.copy),
                      iconSize: 20,
                      onPressed: () => SelectionSheetModel.copy(context, viewState.uid)),
                  IconButton(
                      icon: const Icon(FeatherIcons.share),
                      iconSize: 20,
                      onPressed: () => SelectionSheetModel.share(context, viewState.uid)),
                ],
              );
            }

            return AppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: BibleChapterTitle(volumeType: VolumeType.bible, onUpdate: onUpdate),
              actions: defaultActionsBuilder(context, viewState, size),
            );
          });
        });
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

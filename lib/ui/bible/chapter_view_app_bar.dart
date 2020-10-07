import 'package:flutter/material.dart';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_data/volume_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../menu/view_actions.dart';
import 'chapter_title.dart';

class ChapterViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VolumeType volumeType;
  final ViewState viewState;
  final Size size;
  final SelectionState selectionState;
  final void Function(
          BuildContext context, int newBibleId, BookChapterVerse newBcv, VolumeViewData viewData)
      onUpdate;

  const ChapterViewAppBar({Key key, this.volumeType, this.viewState, this.size, this.selectionState, this.onUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return BlocBuilder<SelectionBloc, SelectionState>(
    // builder: (context, state) {
    //   if (state.viewsWithSelections?.contains(viewState.uid) ?? false) {
    //     return AppBar(
    //       centerTitle: false,
    //       title: SelectionModeBibleChapterTitle(viewState.uid),
    //       actions: [
    //         IconButton(
    //           icon: const Icon(FeatherIcons.play),
    //           iconSize: 20,
    //           onPressed: () {},
    //         ),
    //       ],
    //     );
    //   }

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: ChapterTitle(volumeType: volumeType, onUpdate: onUpdate),
      actions: defaultActionsBuilder(context, viewState, size),
    );
    // },
    // );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

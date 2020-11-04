import 'package:flutter/material.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../menu/view_actions.dart';
import 'chapter_title.dart';

class ChapterViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VolumeType volumeType;
  final ViewState viewState;
  final Size size;
  final SelectionState selectionState;

  const ChapterViewAppBar({
    Key key,
    this.volumeType,
    this.viewState,
    this.size,
    this.selectionState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: ChapterTitle(volumeType: volumeType),
        actions: defaultActionsBuilder(context, viewState, size),
      );

  @override
  Size get preferredSize => AppBar().preferredSize;
}

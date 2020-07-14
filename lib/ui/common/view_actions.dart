import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../main_menu.dart';
import '../bible/chapter_view.dart';
import 'common.dart';

List<Widget> defaultActionsBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) {
  return [
    IconButton(
      icon: const Icon(Icons.photo_size_select_large),
      tooltip: 'Windows',
      onPressed: () => _showMoreMenu(context, bodyKey, state, size),
    ),
    if (context.bloc<ViewManagerBloc>().indexOfView(state.uid) == 0 ||
        context.bloc<ViewManagerBloc>().state.maximizedViewUid == state.uid)
      IconButton(
        icon: const Icon(Icons.account_circle),
        tooltip: 'Main Menu',
        onPressed: () => showMainMenu(context),
      ),
  ];
}

Future<void> _showMoreMenu(BuildContext context, Key bodyKey, ViewState state, Size size) {
  return showTecModalPopup<void>(
    context: context,
    alignment: Alignment.topRight,
    // useRootNavigator: false,
    builder: (context) {
      final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
      final isMaximized = bloc?.state?.maximizedViewUid != 0;
      return TecPopupSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((bloc?.state?.views?.length ?? 0) > 1)
              _menuItem(context, Icons.close, 'Close View', () {
                Navigator.of(context).maybePop();
                bloc?.add(ViewManagerEvent.remove(state.uid));
              }),
            ..._generateOffScreenItems(context, state.uid),
            if ((bloc?.state?.views?.length ?? 0) > 1)
              _menuItem(context, isMaximized ? FeatherIcons.minimize2 : FeatherIcons.maximize2,
                  isMaximized ? 'Restore' : 'Maximize', () {
                Navigator.of(context).maybePop();
                bloc?.add(isMaximized
                    ? const ViewManagerEvent.restore()
                    : ViewManagerEvent.maximize(state.uid));
              }),
            ..._generateAddMenuItems(context, state.uid),
          ],
        ),
      );
    },
  );
}

Iterable<Widget> _generateOffScreenItems(BuildContext context, int viewUid) {
  final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
  final vm = ViewManager.shared;
  final iconMap = <String, IconData>{
    'Bible': FeatherIcons.book,
    'Note': FeatherIcons.edit,
    'Test View': FeatherIcons.plusSquare
  };

  final items = <Widget>[];
  for (final each in bloc.state.views) {
    if (!bloc.isViewWithUidVisible(each.uid)) {
      var title = vm.titleForType(each.type);
      if (each.type == 'BibleChapter') {
        title = bibleChapterTitleFromState(each);
      }
      items.add(_menuItem(context, iconMap[vm.titleForType(each.type)], '$title', () {
        if (bloc.state.maximizedViewUid == viewUid) {
          Navigator.of(context).maybePop();
          bloc?.add(ViewManagerEvent.move(fromPosition: bloc.indexOfView(each.uid), toPosition: 0));
          bloc?.add(ViewManagerEvent.maximize(each.uid));
        } else {
          Navigator.of(context).maybePop();
          bloc?.add(ViewManagerEvent.move(fromPosition: bloc.indexOfView(each.uid), toPosition: 0));
        }
      }));
    }
  }
  return items;
}

Iterable<Widget> _generateAddMenuItems(BuildContext context, int viewUid) {
  final vm = ViewManager.shared;

  return vm.types.map<Widget>(
    (type) => _menuItem(context, FeatherIcons.plusCircle, 'New ${vm.titleForType(type)}', () {
      Navigator.of(context).maybePop();
      final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
      final position = bloc?.indexOfView(viewUid) ?? -1;
      bloc?.add(ViewManagerEvent.add(
          type: type, data: '', position: position == -1 ? null : position + 1));
    }),
  );
}

Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onPressed) {
  final textColor = Theme.of(context).textColor;
  const iconSize = 24.0;
  return CupertinoButton(
    padding: EdgeInsets.zero,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon == null)
          const SizedBox(width: iconSize)
        else
          Icon(icon, color: Theme.of(context).textColor, size: iconSize),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(color: textColor),
        ),
      ],
    ),
    borderRadius: null,
    onPressed: onPressed,
  );
}

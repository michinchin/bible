import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../menu/main_menu.dart';
import 'window_manager.dart';

List<Widget> defaultActionsBuilder(BuildContext context, ViewState state, Size size) {
  // ignore: close_sinks
  final vm = context.bloc<ViewManagerBloc>();
  final topRight = vm.state.maximizedViewUid == state.uid ||
      (vm.columnsInRow(0) - 1) == vm.indexOfView(state.uid);

  return [
    IconButton(
      icon: const Icon(Icons.photo_size_select_large),
      tooltip: 'Windows',
      onPressed: () => _showMoreMenu(context, state, size),
    ),
    if (topRight)
      IconButton(
        icon: const Icon(Icons.account_circle),
        tooltip: 'Main Menu',
        onPressed: () => showMainMenu(context),
      ),
  ];
}

Future<void> _showMoreMenu(BuildContext context, ViewState state, Size size) {
  TecAutoScroll.stopAutoscroll();

  return showWindowDialog(
    context: context,
    builder: (context) {
      return WindowManager(
        state: state,
      );
    },
  );
}

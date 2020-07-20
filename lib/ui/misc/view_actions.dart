import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../menu/main_menu.dart';
import 'window_manager.dart';

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
  return showWindowDialog(
    context: context,
    builder: (context) {
      return WindowManager(
        state: state,
      );
    },
  );
}

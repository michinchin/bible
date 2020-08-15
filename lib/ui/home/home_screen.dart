import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../common/tec_scaffold_wrapper.dart';
import '../sheet/snap_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.bloc<ThemeModeBloc>().state == ThemeMode.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SelectionBloc>(create: (context) => SelectionBloc()),
        BlocProvider<SelectionStyleBloc>(create: (context) => SelectionStyleBloc()),
        BlocProvider<SheetManagerBloc>(
          create: (context) => SheetManagerBloc(),
        ),
      ],
      child: TecSystemUiOverlayWidget(
        isDarkMode ? lightOverlayStyle : darkOverlayStyle,
        child: Container(
          color: Theme.of(context).canvasColor,
          child: TecScaffoldWrapper(
            child: Builder(builder: (_) {
              // this Scaffold is wrapped in a Builder so our parent widget can finish
              // initialization before this Scaffold tries to access the status bar height
              return Scaffold(
                // there is flutter bug! both true and false act as true - null acts as false
                resizeToAvoidBottomInset:
                    (AppSettings.shared.androidStatusBarHeight > 0) ? true : null,
                body: SafeArea(
                  left: false,
                  right: false,
                  bottom: false,
                  child: BlocBuilder<ViewManagerBloc, ViewManagerState>(
                      condition: (previous, current) {
                    return current.rebuild == ViewManagerStateBuildInfo.build;
                  }, builder: (context, state) {
                    return _BottomSheet(
                      child: ViewManagerWidget(state: state),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final Widget child;

  const _BottomSheet({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectionBloc, SelectionState>(
      bloc: context.bloc<SelectionBloc>(),
      // condition: (previous, current) => previous.isTextSelected != current.isTextSelected,
      listener: (context, state) {
        if (state.isTextSelected) {
          context.bloc<SheetManagerBloc>()..changeTypeSize(SheetType.selection, SheetSize.mini);
        } else {
          context.bloc<SheetManagerBloc>()..changeTypeSize(SheetType.main, SheetSize.mini);
        }
      },
      child: SnapSheet(
        body: child,
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
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
    final isDarkMode = context.bloc<ThemeModeBloc>().state == ThemeMode.dark ||
        (context.bloc<ThemeModeBloc>().state == ThemeMode.system &&
            WidgetsBinding.instance.window.platformBrightness == Brightness.dark);

    return MultiBlocProvider(
      providers: [
        BlocProvider<SelectionBloc>(create: (context) => SelectionBloc()),
        BlocProvider<SelectionStyleBloc>(create: (context) => SelectionStyleBloc()),
        BlocProvider<SheetManagerBloc>(
          create: (context) => SheetManagerBloc(),
        ),
      ],
      child: TecScaffoldWrapper(
        // Wrapped in a Builder so we can finish
        // initialization before variables are accessed
        child: Builder(builder: (_) {
          final overlayStyle = isDarkMode
              ? (tec.platformIs(tec.Platform.android) && !AppSettings.shared.androidFullScreen)
              ? lightOverlayStyle.copyWith(systemNavigationBarColor: Theme.of(context).cardColor)
              : lightOverlayStyle
              : darkOverlayStyle;

          return TecSystemUiOverlayWidget(
            overlayStyle,
            child: Container(
              color: Theme.of(context).canvasColor,
              child: Scaffold(
                resizeToAvoidBottomInset: !AppSettings.shared.androidFullScreen,
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
              ),
            ),
          );
        }),
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

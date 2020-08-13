import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../sheet/snap_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SelectionBloc>(create: (context) => SelectionBloc()),
        BlocProvider<SelectionStyleBloc>(create: (context) => SelectionStyleBloc()),
        BlocProvider<SheetManagerBloc>(
          create: (context) => SheetManagerBloc(),
        ),
      ],
      child: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.bloc<ThemeModeBloc>().state == ThemeMode.dark;
    final overlayNavigationBar = tec.platformIs(tec.Platform.android) &&
        MediaQuery.of(context).systemGestureInsets.bottom == 32;

    // tec.dmPrint('_HomeScreen build()');
    return Scaffold(
      resizeToAvoidBottomInset: overlayNavigationBar,
      body: TecSystemUiOverlayWidget(
        isDarkMode ? lightOverlayStyle : darkOverlayStyle,
        child: Container(
          color: Theme.of(context).canvasColor, // primaryColor,
          child: SafeArea(
            left: false,
            right: false,
            bottom: false,
            child: Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: SafeArea(
                bottom: false,
                child: BlocBuilder<ViewManagerBloc, ViewManagerState>(
                  condition: (previous, current) {
                    return current.rebuild == ViewManagerStateBuildInfo.build;
                  },
                  builder: (context, state) {
                    final size = MediaQuery.of(context).size;
                    if (size == Size.zero) {
                      return Container();
                    } else {
                      var statusBarPadding = 0.0;

                      if (tec.platformIs(tec.Platform.android)) {
                        final landscape = size.width > size.height;
                        if (max(size.width, size.height) < 1004) {
                          // it's a phone...
                          if (landscape) {
                            SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
                          }
                          else {
                            statusBarPadding = 24;
                            SystemChrome.setEnabledSystemUIOverlays(
                                [SystemUiOverlay.top, SystemUiOverlay.bottom]);
                          }
                        }
                      }

                      return _BottomSheet(
                        child: ViewManagerWidget(state: state, statusBarPadding: statusBarPadding),
                      );
                    }
                  },
                ),
              ),
            ),
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
          context.bloc<SheetManagerBloc>()
            ..changeTypeSize(SheetType.selection, SheetSize.mini);
        } else {
          context.bloc<SheetManagerBloc>()
            ..changeTypeSize(SheetType.main, SheetSize.mini);
        }
      },
      child: SnapSheet(
        body: child,
      ),
    );
  }
}

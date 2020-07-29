import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

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
        BlocProvider<SelectionBloc>(create: (_) => SelectionBloc()),
        BlocProvider<SelectionStyleBloc>(create: (_) => SelectionStyleBloc()),
        BlocProvider<SheetManagerBloc>(
          create: (_) => SheetManagerBloc(),
        ),
      ],
      child: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  Future<double> whenNotZero(Stream<double> source) async {
    await for (final value in source) {
      if (value > 0) {
        return value;
      }
    }

    // stream exited without a true value, maybe return an exception.
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final canvasColor = Theme.of(context).canvasColor;
    final brightness = ThemeData.estimateBrightnessForColor(canvasColor);

    // tec.dmPrint('_HomeScreen build()');
    return Scaffold(
      body: TecSystemUiOverlayWidget(
        brightness == Brightness.light ? darkOverlayStyle : lightOverlayStyle,
        child: Container(
          color: canvasColor, // primaryColor,
          child: SafeArea(
            left: false,
            right: false,
            bottom: false,
            child: Container(
              color: canvasColor,
              child: SafeArea(
                bottom: false,
                child: BlocProvider<ViewManagerBloc>(
                  create: (_) => ViewManagerBloc(kvStore: tec.Prefs.shared),
                  child: BlocBuilder<ViewManagerBloc, ViewManagerState>(
                    condition: (previous, current) {
                      return current.rebuild == ViewManagerStateBuildInfo.build;
                    },
                    builder: (context, state) {
                      return FutureBuilder(
                        future: whenNotZero(
                          Stream<double>.periodic(const Duration(milliseconds: 50),
                              (x) => MediaQuery.of(context).size.height),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return _BottomSheet(
                              child: ViewManagerWidget(state: state),
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  ),
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

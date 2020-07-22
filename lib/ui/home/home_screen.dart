import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final canvasColor = Theme.of(context).canvasColor;
    final brightness = ThemeData.estimateBrightnessForColor(canvasColor);

    // tec.dmPrint('_HomeScreen build()');
    return Scaffold(
      body: TecSystemUiOverlayWidget(
        brightness == Brightness.light ? darkOverlayStyle : lightOverlayStyle,
        child: _BottomSheet(
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
                  child: BlocBuilder<ViewManagerBloc, ViewManagerState>(
                    builder: (_, state) => ViewManagerWidget(state: state),
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

class _BottomSheet extends StatefulWidget {
  final Widget child;

  const _BottomSheet({Key key, this.child}) : super(key: key);

  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectionBloc, SelectionState>(
        bloc: context.bloc<SelectionBloc>(),
        // condition: (previous, current) => previous.isTextSelected != current.isTextSelected,
        listener: (context, state) {
          if (state.isTextSelected) {
            context.bloc<SheetManagerBloc>()
              ..changeType(SheetType.selection)
              ..changeSize(SheetSize.mini);
          } else {
            context.bloc<SheetManagerBloc>()
              ..changeType(SheetType.main)
              ..changeSize(SheetSize.mini);
          }
        },
        child: SnapSheet(
          body: widget.child,
        ));
  }
}

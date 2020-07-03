import 'package:bible/ui/sheet/main_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../sheet/selection_sheet.dart';
import '../sheet/snap_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ViewManagerBloc>(
          create: (_) => ViewManagerBloc(kvStore: tec.Prefs.shared),
        ),
        BlocProvider<SelectionBloc>(create: (_) => SelectionBloc()),
        BlocProvider<SelectionStyleBloc>(create: (_) => SelectionStyleBloc()),
      ],
      child: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // tec.dmPrint('_HomeScreen build()');
    return Scaffold(
      body: _BottomSheet(
        child: Container(
          color: Theme.of(context).canvasColor, // primaryColor,
          child: SafeArea(
            left: false,
            right: false,
            bottom: false,
            child: Container(
              color: Theme.of(context).canvasColor,
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
    return BlocBuilder<SelectionBloc, SelectionState>(
      bloc: context.bloc<SelectionBloc>(),
      condition: (previous, current) => previous.isTextSelected != current.isTextSelected,
      builder: (context, state) {
        if (state.isTextSelected) {
          return SnapSheet(
              body: widget.child, builder: (c, sheetSize) => SelectionSheet(sheetSize: sheetSize));
        }
        return SnapSheet(
            body: widget.child, builder: (c, sheetSize) => MainSheet(sheetSize: sheetSize));
      },
      // listener: (context, state) {
      //   if (state.isTextSelected) {
      //     _sheetController?.snapToExtent(snappings[1]);
      //   } else {
      //     _sheetController?.snapToExtent(snappings[1]);
      //   }
      // },
    );
  }
}

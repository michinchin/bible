import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../bible/selection_sheet.dart';

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
  SheetController _sheetController;
  List<double> snappings;

  @override
  void initState() {
    _sheetController = SheetController();
    super.initState();
  }

  List<double> _calculateHeightSnappings() {
    // figure out dimensions depending on view size
    const topBarHeight = 30.0;
    const secondBarHeight = 80.0;
    final ratio = (topBarHeight / MediaQuery.of(context).size.height) + 0.1;
    final ratio2 = (secondBarHeight / MediaQuery.of(context).size.height) + 0.1;

    debugPrint(ratio.toString());
    return [0, ratio, ratio + ratio2, ratio * 4];
  }

  @override
  Widget build(BuildContext context) {
    snappings = _calculateHeightSnappings();

    return BlocListener<SelectionBloc, SelectionState>(
      child: SnapSheet(
          controller: _sheetController,
          body: widget.child,
          onSnap: (s, d) {},
          snappings: snappings,
          child: SelectionSheet()),
      condition: (previous, current) =>
          previous.isTextSelected != current.isTextSelected,
      listener: (context, state) {
        if (state.isTextSelected) {
          _sheetController?.snapToExtent(snappings[1]);
        } else {
          _sheetController?.collapse();
        }
      },
    );
  }
}

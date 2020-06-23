import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ViewManagerBloc>(
          create: (_) => ViewManagerBloc(kvStore: tec.Prefs.shared),
        ),
        BlocProvider<SelectionBloc>(
          create: (_) => SelectionBloc(),
        ),
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
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              tecShowAlertDialog<bool>(
                context: context,
                barrierDismissible: false,
                useRootNavigator: false,
                content: const TecText('Open View of Type?'),
                actions: <Widget>[
                  ..._generateViewTypeButtons(context),
                  TecDialogButton(
                    isDefaultAction: true,
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Iterable<Widget> _generateViewTypeButtons(BuildContext context) {
  final vm = ViewManager.shared;
  return vm.types.map<Widget>(
    (type) => TecDialogButton(
      child: Text(vm.titleForType(type)),
      onPressed: () {
        context.bloc<ViewManagerBloc>().add(ViewManagerEvent.add(type: type, data: ''));
        Navigator.of(context).maybePop(true);
      },
    ),
  );
}

class _BottomSheet extends StatefulWidget {
  final Widget child;

  const _BottomSheet({Key key, this.child}) : super(key: key);

  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> {
  PersistentBottomSheetController bottomSheet;

  @override
  void initState() {
    super.initState();
  }

  void _showBottomSheet() {
    if (bottomSheet != null) return;
    bottomSheet = Scaffold.of(context)
        .showBottomSheet<void>((context) => _BottomSheetContent(), elevation: 25)
          ..closed.whenComplete(() {
            bottomSheet = null;
          });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectionBloc, SelectionState>(
      child: widget.child,
      condition: (previous, current) => previous.isTextSelected != current.isTextSelected,
      listener: (context, state) {
        if (state.isTextSelected) {
          _showBottomSheet();
        } else {
          bottomSheet?.close();
        }
      },
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: const Center(child: Text('abc...')),
    );
  }
}

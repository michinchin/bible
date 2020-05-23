import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ViewManagerBloc(kvStore: tec.Prefs.shared),
      child: const _HomeScreen(),
    );
  }
}

var _viewId = 0;

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
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
                title: const TecText('Open View of Type?'),
                //content: const TecText('What type?'),
                actions: <Widget>[
                  ..._foo(context),
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
            // onPressed: () => context.bloc<ViewManagerBloc>().add(
            //     ViewManagerEvent.add(type: bibleChapterType, data: '${++_viewId}')),
          ),
        ],
      ),
    );
  }
}

Iterable<Widget> _foo(BuildContext context) {
  final vm = ViewManager.shared;
  return vm.types.map<Widget>((type) => TecDialogButton(
        child: Text(vm.titleForType(type)),
        onPressed: () {
          context
              .bloc<ViewManagerBloc>()
              .add(ViewManagerEvent.add(type: type, data: '${++_viewId}'));
          Navigator.of(context).maybePop(true);
        },
      ));
}

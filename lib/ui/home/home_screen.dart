import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/view_manager_bloc.dart';
import '../bible/chapter_view.dart';

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
            onPressed: () => context.bloc<ViewManagerBloc>().add(
                ViewManagerEvent.add(
                    type: bibleChapterTypeName, data: '${++_viewId}')),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/view_manager_bloc.dart';
import '../../translations.dart';

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
    const fabPadding = EdgeInsets.symmetric(vertical: 5.0);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home'.i18n),
      // ),
      body: Container(
        color: Colors.blue,
        child: SafeArea(
          bottom: false,
          right: false,
          left: false,
          child: BlocBuilder<ViewManagerBloc, ViewManagerState>(
            builder: (_, state) => ViewManagerWidget(state: state),
          ),
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: fabPadding,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => context.bloc<ViewManagerBloc>().add(
                  ViewManagerEvent.add(
                      type: ViewType.bible, data: '${++_viewId}')),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 5.0),
          //   child: FloatingActionButton(
          //     child: Icon(Icons.update),
          //     onPressed: () =>
          //         context.bloc<AppThemeBloc>().add(AppThemeEvent.toggle),
          //   ),
          // ),
        ],
      ),
    );
  }
}

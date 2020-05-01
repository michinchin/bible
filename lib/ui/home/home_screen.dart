import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/counter_bloc.dart';
import '../../translations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///2. Resolve counter bloc to update state
    //final counterBloc = context.bloc<CounterBloc>();
    final textStyle = Theme.of(context).textTheme.headline4;
    const fabPadding = EdgeInsets.symmetric(vertical: 5.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'.i18n),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'.i18n),

            ///3. Efficiently render state changes
            BlocBuilder<CounterBloc, CounterState>(
              builder: (_, state) => state.when(
                current: (value) => Text('$value', style: textStyle),
                initial: (value) => Text('$value', style: textStyle),
              ),
            )
          ],
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

              ///4. Perform increment action
              onPressed: () => context.bloc<CounterBloc>().increment(),
            ),
          ),
          Padding(
            padding: fabPadding,
            child: FloatingActionButton(
              child: Icon(Icons.remove),

              ///5. Perform decrement action
              onPressed: () => context.bloc<CounterBloc>().decrement(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.update),
              onPressed: () =>
                  context.bloc<AppThemeBloc>().add(AppThemeEvent.toggle),
            ),
          ),
        ],
      ),
    );
  }
}

/*
typedef ViewBuilder = Widget Function(BuildContext context);

class ViewManager {
  void addViewable({Size minSize, ViewBuilder viewBuilder}) {

  }
}

class TestView extends StatelessWidget with Viewable {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
    );
  }

  static Size get minSize => const Size(200, 200);

  @override
  // TODO: implement preferredHeight
  Size get preferredHeight => throw UnimplementedError();

  @override
  // TODO: implement preferredWidth
  Size get preferredWidth => throw UnimplementedError();
  
}
*/
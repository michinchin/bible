import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'blocs/app_theme_bloc.dart';
import 'blocs/counter_bloc.dart';
import 'ui/common/adaptive_scaffold.dart';
import 'ui/explore/explore_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/notes/notes_screen.dart';
import 'ui/study/study_screen.dart';

const _appTitle = 'Tecarta Bible';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load preferences.
  await tec.Prefs.shared.load();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppThemeBloc(),
      child: BlocBuilder<AppThemeBloc, ThemeData>(
        builder: (_, theme) {
          return MaterialApp(
            theme: theme,
            title: _appTitle,
            home: Adaptive(),
          );
        },
      ),
    );
  }
}

class Adaptive extends StatefulWidget {
  @override
  _AdaptiveState createState() => _AdaptiveState();
}

class _AdaptiveState extends State<Adaptive> {
  final _tabsController = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tabsController,
      builder: (context, index, child) => AdaptiveScaffold(
        tabs: [
          TabItem(
            title: 'Home',
            iconData: Icons.home,
            body: BlocProvider(
              create: (_) => CounterBloc(),
              child: const HomeScreen(),
            ),
          ),
          TabItem(
            title: 'Explore',
            iconData: Icons.explore,
            body: ExploreScreen(),
          ),
          TabItem(
            title: 'Study',
            iconData: Icons.book,
            body: StudyScreen(),
          ),
          TabItem(
            title: 'Notes',
            iconData: Icons.edit,
            body: NotesScreen(),
          ),
        ],
        selectedIndex: index,
        onSelectionChanged: (val) => _tabsController.value = val,
      ),
    );
  }
}

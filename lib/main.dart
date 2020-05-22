import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import 'blocs/app_theme_bloc.dart';
import 'blocs/view_manager_bloc.dart';
import 'ui/bible/chapter_view.dart';
import 'ui/common/test_view.dart';
import 'ui/home/home_screen.dart';

const _appTitle = 'Tecarta Bible';

///
/// main
///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await tec.Prefs.shared.load();

  _registerViewTypes();

  runApp(App());
}

///
/// Registers the view types used in the app.
///
void _registerViewTypes() {
  ViewManager.shared
    ..register(testViewTypeName, title: 'Test', builder: testViewBuilder)
    ..register(bibleChapterTypeName,
        title: 'Bible', builder: bibleChapterViewBuilder);
}

///
/// App
///
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeModeBloc(),
      child: BlocBuilder<ThemeModeBloc, ThemeMode>(
        builder: (_, themeMode) {
          return tec.BlocProvider<TecStyleBloc>(
            bloc: TecStyleBloc(
                <String, dynamic>{'dialogStyle': TecMetaStyle.material}),
            child: MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('es'), // Spanish
                Locale('ar'), // Arabic
              ],
              title: _appTitle,
              home: I18n(
                //initialLocale: const Locale('es'),
                //initialLocale: const Locale('ar', 'EG'), // Arabic, Egypt
                //child: Adaptive(),
                child: const HomeScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/*
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
            title: 'Home'.i18n,
            iconData: Icons.home,
            body: BlocProvider(
              create: (_) => CounterBloc(),
              child: const HomeScreen(),
            ),
          ),
          TabItem(
            title: 'Explore'.i18n,
            iconData: Icons.explore,
            body: ExploreScreen(),
          ),
          TabItem(
            title: 'Study'.i18n,
            iconData: Icons.book,
            body: StudyScreen(),
          ),
          TabItem(
            title: 'Notes'.i18n,
            iconData: Icons.edit,
            body: NotesScreen(),
          ),
        ],
        selectedIndex: index,
        onSelectionChanged: (val) => _tabsController.value = val,
      ),
    );
  }
} */

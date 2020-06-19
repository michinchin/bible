import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import 'blocs/app_lifecycle_bloc.dart';
import 'blocs/app_settings.dart';
import 'blocs/app_theme_bloc.dart';
import 'blocs/view_manager_bloc.dart';
import 'ui/bible/chapter_view.dart';
import 'ui/common/test_view.dart';
import 'ui/home/home_screen.dart';
import 'ui/note/note_view.dart';
import 'ui/note/notes_view.dart';

const _appTitle = 'Tecarta Bible';

///
/// main
///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await tec.Prefs.shared.load();

  VolumesRepository.shared = TecVolumesRepository(
    productsUrl: null,
    productsBundleKey: null,
    bundledProducts: [
      BundledProduct([8, 9, 32, 47, 49, 50, 51, 78, 218, 231, 250], 'assets'),
    ],
  );

  await AppSettings.load(
      appName: 'Bible', itemsToSync: [tua.UserItemType.license]);

  _registerViewTypes();

  runApp(App());
}

///
/// Registers the view types used in the app.
///
void _registerViewTypes() {
  ViewManager.shared
    ..register(testViewType, title: 'Test', builder: testViewBuilder)
    ..register(bibleChapterType,
        title: 'Bible',
        builder: bibleChapterViewBuilder,
        titleBuilder: bibleChapterTitleBuilder,
        keyMaker: bibleChapterKeyMaker)
    ..register(noteViewTypeName, title: 'Note', builder: notesViewBuilder);
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
            child: OKToast(
              child: AppLifecycleWrapper(
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
              ),
            ),
          );
        },
      ),
    );
  }
}

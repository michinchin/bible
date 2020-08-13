import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import 'blocs/app_lifecycle_bloc.dart';
import 'blocs/app_theme_bloc.dart';
import 'blocs/downloads/downloads_bloc.dart';
import 'blocs/view_manager/view_manager_bloc.dart';
import 'models/app_settings.dart';
import 'ui/bible/chapter_view.dart';
import 'ui/common/common.dart';
import 'ui/home/home_screen.dart';
import 'ui/misc/view_actions.dart';
import 'ui/note/margin_note_view.dart';
import 'ui/note/note_view.dart';
import 'ui/note/notes_view.dart';

const _appTitle = 'Tecarta Bible';

///
/// main
///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await FlutterDownloader.initialize(debug: kDebugMode);
  }

  await tec.Prefs.shared.load();

  VolumesRepository.shared = TecVolumesRepository(
    productsUrl: null,
    productsBundleKey: null,
    bundledProducts: [
      BundledProduct([8, 9, 32, 47, 49, 50, 51, 78, 218, 231, 250], 'assets'),
    ],
  );

  await VolumesRepository.shared.loadProducts();

  await AppSettings.shared.load(appName: 'Bible', itemsToSync: [
    tua.UserItemType.license,
    tua.UserItemType.highlight,
    tua.UserItemType.marginNote,
    tua.UserItemType.note,
    tua.UserItemType.prefItem
  ]);

  _registerViewTypes();

  runApp(App());
}

///
/// Registers the view types used in the app.
///
void _registerViewTypes() {
  ViewManagerState.setDefaults(bibleChapterType, bibleChapterDefaultData());
  ViewManager.shared
    ..register(
      bibleChapterType,
      title: 'Bible',
      scaffoldBuilder: bibleChapterViewBuilder,
      icon: FeatherIcons.book,
      defaultDataBuilder: bibleChapterDefaultData,
    )
    ..register(
      noteViewType,
      title: 'Note',
      bodyBuilder: notesViewBuilder,
      actionsBuilder: defaultActionsBuilder,
      icon: FeatherIcons.edit,
    )
    ..register(
      marginNoteViewType,
      title: null,
      scaffoldBuilder: marginNoteScaffoldBuilder,
      icon: TecIcons.marginNoteOutline,
    );
//    ..register(
//      testViewType,
//      title: 'Test View',
//      bodyBuilder: testViewBuilder,
//      actionsBuilder: defaultActionsBuilder,
//      icon: FeatherIcons.plusSquare,
//    );
}

///
/// App
///
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DownloadsBloc>(
          create: (context) => DownloadsBloc.create(),
        ),
        BlocProvider<ViewManagerBloc>(
          create: (context) => ViewManagerBloc(kvStore: tec.Prefs.shared),
        ),
        BlocProvider<ThemeModeBloc>(
          create: (context) => ThemeModeBloc(),
        ),
      ],
      child: BlocBuilder<ThemeModeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return tec.BlocProvider<TecStyleBloc>(
            bloc: TecStyleBloc(<String, dynamic>{'dialogStyle': TecMetaStyle.material}),
            child: OKToast(
              child: AppLifecycleWrapper(
                child: MaterialApp(
                  theme: ThemeData.light().copyWithAppTheme(),
                  darkTheme: ThemeData.dark().copyWithAppTheme(),
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

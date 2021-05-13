import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tec_bloc/tec_bloc.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

// import 'blocs/app_entry_cubit.dart';
import 'blocs/app_lifecycle_bloc.dart';
import 'blocs/app_theme_bloc.dart';
import 'blocs/content_settings.dart';
import 'blocs/downloads/downloads_bloc.dart';
import 'blocs/prefs_bloc.dart';
import 'blocs/recent_volumes_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/shared_bible_ref_bloc.dart';
import 'blocs/sheet/tab_manager_bloc.dart';
import 'models/app_settings.dart';
import 'models/const.dart';
import 'models/iap/iap.dart';
import 'models/pref_item.dart';
import 'navigation_service.dart';
import 'ui/common/common.dart';
import 'ui/home/home_screen.dart';
import 'ui/ugc/note_view.dart';
import 'ui/volume/volume_view.dart';

const _appTitle = 'Tecarta Bible';

///
/// main
///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ViewManager.defaultViewType = Const.viewTypeVolume;
  ViewManager.shared
    ..register(ViewableVolume(Const.viewTypeVolume, FeatherIcons.book))
    ..register(ViewableNote(Const.viewTypeNote, TecIcons.marginNoteOutline));

  final stopwatch = Stopwatch()..start();

  if (!kIsWeb) {
    await FlutterDownloader.initialize(debug: kDebugMode);
    await Notifications.init(
        channelInfo: ChannelInfo(id: 'tec-id', name: 'tec-name', description: 'tec-description'),
        color: Const.tecartaLightBlue);
  }

  await Prefs.shared.load();

  final product =
      TecPlatform.isWeb ? 'WebSite' : '${TecPlatform.isIOS ? 'IOS' : 'PLAY'}_TecartaBible';

  VolumesRepository.shared = TecVolumesRepository(
    productsUrl: '$cloudFrontStreamUrl/products-list/$product.json',
    productsBundleKey: 'assets/products.json',
    bundledProducts: [
      BundledProduct([9], 'assets'),
    ],
  );

  await VolumesRepository.shared.loadProducts(updateLocalVolumes: true, checkForUpdate: true);

  await AppSettings.shared.load(appName: 'Bible', itemsToSync: [
    tua.UserItemType.folder,
    tua.UserItemType.bookmark,
    tua.UserItemType.note,
    tua.UserItemType.marginNote,
    tua.UserItemType.highlight,
    tua.UserItemType.license,
    tua.UserItemType.completed,
    /* tua.UserItemType.devoPlan,
    tua.UserItemType.tag,
    tua.UserItemType.tagItem,*/
    tua.UserItemType.prefItem,
  ]);

  InAppPurchases.init();

  // items in prefs bloc can be saved in the db - userDB needs to have been initialized
  await PrefsBloc.shared.load();

  dmPrint('Main initialization took ${stopwatch.elapsed}');
  stopwatch.stop();

  runApp(const App());
}

///
/// App
///
class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DownloadsBloc.create()),
        BlocProvider(create: (context) => SharedBibleRefBloc()),
        BlocProvider(
            create: (context) => ViewManagerBloc(
                kvStore: Prefs.shared,
                clearMaximizedOffScreen:
                    PrefsBloc.getBool(PrefItemId.syncChapter, defaultValue: true))),
        BlocProvider(create: (context) => ThemeModeBloc()),
        BlocProvider(create: (context) => ContentSettingsBloc()),
        BlocProvider(create: (context) => PrefsBloc.shared),
        BlocProvider(create: (context) => SearchBloc()),
        BlocProvider(create: (context) => TabManagerBloc()),
        BlocProvider(create: (context) => RecentVolumesBloc()),
        // BlocProvider(create: (context) => AppEntryCubit())
      ],
      child: BlocBuilder<ThemeModeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return TecBlocProvider<TecStyleBloc>(
              bloc: TecStyleBloc(<String, dynamic>{'dialogStyle': TecMetaStyle.material}),
              child: OKToast(
                child: AppLifecycleWrapper(
                  child: FeatureDiscovery(
                    child: MaterialApp(
                      navigatorKey: navService.navigatorKey,
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
              ));
        },
      ),
    );
  }
}

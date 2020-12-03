import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/notifications/notifications_model.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../menu/main_menu.dart';
import '../sheet/snap_sheet.dart';
import '../ugc/ugc_view.dart';
import 'reader_fab.dart';
import 'tab_bottom_bar.dart';
import 'today.dart';
import 'votd_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _startTime = DateTime.now();

  @override
  void initState() {
    if (!kDebugMode) initNotifications();
    super.initState();
  }

  void initNotifications() {
    // TODO(abby): on cold start, doesn't open notification on iOS...why?
    // if cold start - wait longer...
    final delay =
        (DateTime.now().difference(_startTime) > const Duration(seconds: 15)) ? 500 : 1250;

    Future.delayed(Duration(milliseconds: delay), () {
      // resend the notification
      Notifications.payloadStream.listen(NotificationsModel.shared.handlePayload);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final granted = await Notifications.shared?.requestPermissions(context);
        if (granted) {
          NotificationBloc.init(NotificationsModel.shared);
          NotificationsModel.shared.bible = currentBibleFromContext(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // init the scaffold vars before we try to access them...
    if (!TecScaffoldWrapper.isMediaQueryReady(context)) {
      return Container();
    }

    return MultiBlocProvider(
        providers: [
          BlocProvider<SelectionBloc>(create: (context) => SelectionBloc()),
          BlocProvider<SelectionCmdBloc>(create: (context) => SelectionCmdBloc()),
          BlocProvider<SheetManagerBloc>(create: (context) => SheetManagerBloc()),
        ],
        child: Scaffold(
          drawer: const UGCView(),
          extendBody: true,
          backgroundColor: Theme.of(context).backgroundColor,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: TecFab(),
          body: Stack(
            children: [
              BlocBuilder<ViewManagerBloc, ViewManagerState>(
                builder: (context, state) {
                  return ViewManagerWidget(
                    state: state,
                    topRightWidget: MainMenuFab(),
                    topLeftWidget: JournalFab(),
                  );
                },
              ),
              SnapSheet(),
            ],
          ),
        ));
  }
}

class TecFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabs = [
      TabBottomBarItem(
        tab: TecTab.today,
        icon: Icons.today_outlined,
        label: 'Today',
        widget: Today(),
      ),
      const TabBottomBarItem(
        tab: TecTab.library,
        icon: FeatherIcons.book,
        label: 'Library',
        widget: LibraryScaffold(showCloseButton: false, heroPrefix: 'home'),
      ),
      TabBottomBarItem(
        tab: TecTab.plans,
        icon: Icons.next_plan_outlined,
        label: 'Plans',
        widget: Container(color: Colors.blue),
      ),
      TabBottomBarItem(
        tab: TecTab.store,
        icon: Icons.store_outlined,
        label: 'Store',
        widget: Container(color: Colors.yellow),
      )
    ];
    return BlocBuilder<SheetManagerBloc, SheetManagerState>(
      builder: (context, sheetState) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 150),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: ReaderFAB(
              elevation: (sheetState.type == SheetType.main) ? null : 0,
              backgroundColor: (sheetState.type == SheetType.main)
                  ? Const.tecartaBlue
                  : Theme.of(context).backgroundColor.withOpacity(0),
              mainIcon: Icon(
                TecIcons.tecartabiblelogo,
                color: (sheetState.type == SheetType.main)
                    ? Colors.white
                    : Colors.grey.withOpacity(0.3),
              ),
              tabs: tabs,
            ),
          ),
        );
      },
    );
  }
}

Future<void> showTabView(
        {@required BuildContext context,
        @required TecTab tab,
        @required List<TabBottomBarItem> tabs}) =>
    showScreen<void>(
        context: context,
        builder: (c) {
          return BlocProvider<TabManagerCubit>(
              create: (context) => TabManagerCubit(tab: tab),
              child: BlocBuilder<TabManagerCubit, TecTab>(buildWhen: (p, n) {
                // android needs bottom nav bar color changed in dark mode with non reader tab
                return tec.platformIs(tec.Platform.android) &&
                    Theme.of(context).brightness == Brightness.dark &&
                    (p == TecTab.reader || n == TecTab.reader) &&
                    (p != n);
              }, builder: (context, tabState) {
                var overlayStyle = AppSettings.shared.overlayStyle(context);
                if (tec.platformIs(tec.Platform.android) &&
                    Theme.of(context).brightness == Brightness.dark) {
                  if (tabState != TecTab.reader) {
                    overlayStyle = overlayStyle.copyWith(
                        systemNavigationBarColor: Theme.of(context).appBarTheme.color);
                  }
                }

                return TecSystemUiOverlayWidget(overlayStyle,
                    child: TabScaffoldWrap(
                      tabs: tabs,
                      currentTab: tabState,
                    ));
              }));
        });

class MainMenuFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
        elevation: 4,
        mini: true,
        heroTag: null,
        child: Icon(FeatherIcons.user, size: 15, color: Theme.of(context).textColor),
        backgroundColor: Theme.of(context).appBarTheme.color,
        onPressed: () => showMainMenu(context),
      );
}

class JournalFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
      elevation: 4,
      mini: true,
      heroTag: null,
      child: Icon(FeatherIcons.bookOpen, size: 15, color: Theme.of(context).textColor),
      backgroundColor: Theme.of(context).appBarTheme.color,
      onPressed: () {
        Scaffold.of(context).openDrawer();
      });
}

// chose either column or stack - making sure 1st child of column is expanded...
// class _ColumnStack extends StatelessWidget {
//   final List<Widget> children;
//
//   const _ColumnStack({Key key, this.children}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (isSmallScreen(context)) {
//       if (children.first is! Expanded) {
//         final child = children.removeAt(0);
//         children.insert(0, Expanded(child: child));
//       }
//
//       return Column(children: children);
//     } else {
//       return Stack(children: children);
//     }
//   }
// }

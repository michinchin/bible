import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/notifications/notifications_model.dart';
import '../common/common.dart';
import '../common/tec_scroll_listener.dart';
import '../library/library.dart';
import '../menu/main_menu.dart';
import '../onboarding/onboarding.dart';
import '../sheet/snap_sheet.dart';
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
    if (tec.Prefs.shared.getBool(Const.prefShowOnboarding, defaultValue: true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!kDebugMode) showOnboarding(context);
      });
    }
    super.initState();
  }

  void initNotifications() {
    // TODO(abby): on cold start, doesn't open notification on iOS...why?
    // if cold start - wait longer...

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final delay =
          (DateTime.now().difference(_startTime) > const Duration(seconds: 15)) ? 500 : 1250;

      if (mounted) {
        final granted = await Notifications.shared?.requestPermissions(context);
        if (granted) {
          NotificationBloc.init(NotificationsModel.shared);
          NotificationsModel.shared.bible = currentBibleFromContext(context);
          Future.delayed(Duration(milliseconds: delay), () {
            // resend the notification
            Notifications.payloadStream.listen(NotificationsModel.shared.handlePayload);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // init the bar padding vars before we try to access them...
    if (!context.isMediaQueryReady()) {
      return Container();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<SelectionBloc>(create: (context) => SelectionBloc()),
        BlocProvider<SelectionCmdBloc>(create: (context) => SelectionCmdBloc()),
        BlocProvider<SheetManagerBloc>(create: (context) => SheetManagerBloc()),
        BlocProvider<TabManagerBloc>(create: (context) => TabManagerBloc()),
      ],
      child: BlocBuilder<TabManagerBloc, TabManagerState>(buildWhen: (p, n) {
        // android w/gesture nav - reader needs a different overlay style
        return (context.gestureNavigation &&
            (p.tab == TecTab.reader ||
                n.tab == TecTab.reader ||
                p.hideBottomBar != n.hideBottomBar));
      }, builder: (context, tabState) {
        return BlocBuilder<SheetManagerBloc, SheetManagerState>(buildWhen: (p, n) {
          // android w/gesture nav - reader needs a different overlay style for selection sheet
          return (context.gestureNavigation &&
              tabState.tab == TecTab.reader &&
              (p.type == SheetType.selection || n.type == SheetType.selection));
        }, builder: (context, sheetState) {
          var overlayStyle = AppSettings.shared.overlayStyle(context);

          // set android gestureNavigation app bar color
          if (context.gestureNavigation &&
              (tabState.hideBottomBar ||
                  (tabState.tab == TecTab.reader && sheetState.type != SheetType.selection))) {
            overlayStyle =
                overlayStyle.copyWith(systemNavigationBarColor: Theme.of(context).backgroundColor);
          }

          return TecSystemUiOverlayWidget(
            overlayStyle,
            child: TabBottomBar(
              tabs: [
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
                ),
                TabBottomBarItem(
                  tab: TecTab.reader,
                  label: 'Bible',
                  widget: Stack(
                    children: [
                      TecScrollListener(
                        axisDirection: AxisDirection.down,
                        changedDirection: (direction) {
                          if (direction == ScrollDirection.reverse) {
                            context.read<SheetManagerBloc>().add(SheetEvent.restore);
                          } else if (direction == ScrollDirection.forward) {
                            context.read<SheetManagerBloc>().add(SheetEvent.collapse);
                          }
                        },
                        child: BlocBuilder<ViewManagerBloc, ViewManagerState>(
                          builder: (context, state) {
                            return ViewManagerWidget(
                              state: state,
                              topRightWidget: MainMenuFab(),
                              topLeftWidget: JournalFab(),
                              onSelectionChangedInViews: (views) {
                                context.read<SelectionBloc>()?.add(SelectionState(
                                    isTextSelected: views.isNotEmpty, viewsWithSelections: views));
                              },
                            );
                          },
                        ),
                      ),
                      SnapSheet(),
                    ],
                  ),
                ),
                TabBottomBarItem(
                  tab: TecTab.switcher,
                  widget: GestureDetector(
                    onTap: () {
                      context.tabManager.changeTab(TecTab.reader);
                    },
                    child: Container(
                      color: barrierColorWithContext(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      }),
    );
  }
}

class MainMenuFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
        elevation: defaultActionBarElevation,
        mini: true,
        heroTag: null,
        child: Icon(FeatherIcons.user, size: 15, color: Theme.of(context).textColor),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).appBarTheme.color
            : Theme.of(context).backgroundColor,
        onPressed: () => showMainMenu(context),
      );
}

class JournalFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
      elevation: defaultActionBarElevation,
      mini: true,
      heroTag: null,
      child: Icon(FeatherIcons.bookOpen, size: 15, color: Theme.of(context).textColor),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).appBarTheme.color
          : Theme.of(context).backgroundColor,
      onPressed: () {
        TecAutoScroll.stopAutoscroll();
        Scaffold.of(context).openDrawer();
      });
}

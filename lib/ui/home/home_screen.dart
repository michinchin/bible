import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/shared_bible_ref_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/notifications/notifications_model.dart';
import '../common/common.dart';
import '../common/tec_scroll_listener.dart';
import '../library/library.dart';
import '../menu/reorder_views.dart';
import '../onboarding/onboarding.dart';
import '../sheet/snap_sheet.dart';
import '../volume/volume_view_data.dart';
import '../volume/volume_view_data_bloc.dart';
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
    //show onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (tec.Prefs.shared.getBool(Const.prefShowOnboarding, defaultValue: true)) {
        if (!kDebugMode) {
          await showOnboarding(context);
        }
      }
      initFeatureDiscovery(
          context: context, pref: Const.prefFabTabs, steps: {Const.fabTabFeatureId});
    });
    super.initState();
  }

  void initNotifications() {
    // TODO(abby): on cold start, doesn't open notification on iOS...why?
    // if cold start - wait longer...

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final delay =
          (DateTime.now().difference(_startTime) > const Duration(seconds: 15)) ? 500 : 1250;

      if (mounted) {
        var granted = false;

        if (tec.Prefs.shared.getInt(Const.prefNotificationPermissionGranted, defaultValue: 0) !=
            -1) {
          granted = await Notifications.shared?.requestPermissions(context);
          await tec.Prefs.shared.setInt(Const.prefNotificationPermissionGranted, granted ? 1 : -1);
        }

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
        BlocProvider<DragOverlayCubit>(create: (_) => DragOverlayCubit())
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSettings.shared.overlayStyle(context),
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
                  Builder(builder: (context) {
                    // a generic builder is needed here so context in changedDirection has
                    // the SheetManagerBloc - w/o the Builder the context is the passed in
                    // context that doesn't have the above bloc providers
                    return TecScrollListener(
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
                            topLeftWidget: ChangeChapterFab(state, ChapterButton.previous),
                            topRightWidget: ChangeChapterFab(state, ChapterButton.next),
                            resizeAnimationDuration: const Duration(milliseconds: 400),
                            onSelectionChangedInViews: (views) {
                              context.read<SelectionBloc>()?.add(SelectionState(
                                  isTextSelected: views.isNotEmpty, viewsWithSelections: views));
                            },
                          );
                        },
                      ),
                    );
                  }),
                  SnapSheet(),
                ],
              ),
            ),
            TabBottomBarItem(
              tab: TecTab.switcher,
              widget: Container(
                color: barrierColorWithContext(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ChapterButton { previous, next }

class ChangeChapterFab extends StatefulWidget {
  final ViewManagerState state;
  final ChapterButton buttonType;

  const ChangeChapterFab(this.state, this.buttonType);

  @override
  _ChangeChapterFabState createState() => _ChangeChapterFabState();
}

class _ChangeChapterFabState extends State<ChangeChapterFab> {
  void _changeChapter() {
    BookChapterVerse adjustedChapter(BookChapterVerse bcv, Bible bible) {
      if (widget.buttonType == ChapterButton.previous) {
        return bcv.advancedBy(chapters: -1, bible: bible, wraparound: true);
      } else {
        return bcv.advancedBy(chapters: 1, bible: bible, wraparound: true);
      }
    }

    final viewData = widget.state.views.first.volumeDataWith(context);
    final volumeId = viewData.volumeId;
    Bible bible;

    if (volumeId != null) {
      assert(viewData != null);
      if (isBibleId(volumeId)) {
        bible = VolumesRepository.shared.bibleWithId(volumeId);
      } else if (isStudyVolumeId(volumeId)) {
        bible = VolumesRepository.shared.volumeWithId(volumeId).assocBible();
      } else {
        assert(false);
      }
    }

    if (bible != null) {
      if (viewData.useSharedRef) {
        context.read<SharedBibleRefBloc>().update(adjustedChapter(viewData.bcv, bible));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context)?.textScaleFactor ?? 1.0;

    return FloatingActionButton(
        tooltip: '${widget.buttonType == ChapterButton.previous ? 'Previous' : 'Next'} Chapter',
        elevation: defaultActionBarElevation,
        mini: true,
        heroTag: null,
        child: Icon(
            widget.buttonType == ChapterButton.previous
                ? FeatherIcons.chevronLeft
                : FeatherIcons.chevronRight,
            size: 24 * scale,
            color: Theme.of(context).textColor),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).appBarTheme.color
            : Theme.of(context).backgroundColor,
        onPressed: _changeChapter);
  }
}

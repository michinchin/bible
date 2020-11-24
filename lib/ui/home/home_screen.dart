import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/notifications/notifications_model.dart';
import 'expandable_fab.dart';
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
        child: TecSystemUiOverlayWidget(AppSettings.shared.overlayStyle(context),
            child: Container(
              color: Theme.of(context).canvasColor,
              child: TecScaffoldWrapper(
                child: BlocBuilder<ViewManagerBloc, ViewManagerState>(builder: (context, state) {
                  return Scaffold(
                      // resizeToAvoidBottomInset: false,
                      floatingActionButton: TecFab(state.views.first),
                      body: SafeArea(
                          left: false,
                          right: false,
                          bottom: false,
                          child: ViewManagerWidget(state: state)));
                }),
              ),
            )));
  }
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

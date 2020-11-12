import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/notifications/notifications_model.dart';
import '../sheet/snap_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // if (!kDebugMode)
    initNotifications();
    super.initState();
  }

  void initNotifications() {
    Notifications.payloadStream.listen(NotificationsModel.shared.handlePayload);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final granted = await Notifications.shared?.requestPermissions(context);
        if (granted) {
          NotificationBloc.init(NotificationsModel.shared);
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
      child: TecSystemUiOverlayWidget(
        AppSettings.shared.overlayStyle(context),
        child: Container(
          color: Theme.of(context).canvasColor,
          child: TecScaffoldWrapper(
            child: Scaffold(
              // resizeToAvoidBottomInset: false,
              body: SafeArea(
                left: false,
                right: false,
                bottom: false,
                child: BlocBuilder<ViewManagerBloc, ViewManagerState>(builder: (context, state) {
                  return _BottomSheet(
                    child: ViewManagerWidget(state: state),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final Widget child;

  const _BottomSheet({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectionBloc, SelectionState>(
      listenWhen: (previous, current) => previous.isTextSelected != current.isTextSelected,
      listener: (context, state) {
        if (state.isTextSelected) {
          context.tbloc<SheetManagerBloc>()..changeTypeSize(SheetType.selection, SheetSize.medium);
        } else {
          context.tbloc<SheetManagerBloc>()..changeTypeSize(SheetType.main, SheetSize.mini);
        }
      },
      child: SnapSheet(body: child),
    );
  }
}

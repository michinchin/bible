import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../models/app_settings.dart';

class AppLifecycleBloc extends Bloc<AppLifecycleState, AppLifecycleState> {
  ///
  /// The running count of times the app has been resumed (resets on app boot).
  ///
  int get appResumedCount => _appResumedCount;
  int _appResumedCount = 0;

  ///
  /// If the app is in the 'paused' state, returns the current pause duration.
  /// Otherwise returns the duration of the previous pause, or Duration.zero
  /// if the app has not yet been paused.
  ///
  Duration get pausedDuration => _pausedStopwatch.elapsed;
  final _pausedStopwatch = Stopwatch();

  @override
  AppLifecycleState get initialState => AppLifecycleState.resumed;

  @override
  Stream<AppLifecycleState> mapEventToState(AppLifecycleState event) async* {
    tec.dmPrint('App state changed to $event');
    switch (event) {
      case AppLifecycleState.resumed:
        _handleResume();
        break;
      case AppLifecycleState.paused:
        _handlePause();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Nothing to do here...
        break;
    }
    yield event ?? state;
  }
}

///
/// Provides an [AppLifecycleBloc] to the app.
///
class AppLifecycleWrapper extends StatelessWidget {
  final Widget child;

  const AppLifecycleWrapper({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppLifecycleBloc>(
      create: (_) => AppLifecycleBloc(),
      child: _AppBindingObserver(child: child),
    );
  }
}

//
// PRIVATE STUFF
//

extension on AppLifecycleBloc {
  void _handleResume() {
    if (state == AppLifecycleState.resumed) return;

    // App became active again?
    _appResumedCount++;
    _pausedStopwatch.stop();
    if (kDebugMode) {
      tec.dmPrint('App resumed after being paused for $pausedDuration');
    }

    // On Android, if you switch away from the app, then return to it,
    // the systemNavigationBarIconBrightness is not set back to what it
    // should be. This call fixes that bug.
    SystemChrome.setSystemUIOverlayStyle(darkOverlayStyle);

    // See if today changed.
    // _dayOffsetListener(dayOffset.value);

    // If a user is signed in, initiate a sync.
    if (AppSettings.shared.userAccount.isSignedIn) {
      AppSettings.shared.userAccount.syncUserDb<void>();
    }
  }

  void _handlePause() {
    if (state == AppLifecycleState.paused) return;

    _pausedStopwatch
      ..reset()
      ..start();

    // If a user is signed in, initiate a sync to only post changes (so it completes quickly).
    if (AppSettings.shared.userAccount.isSignedIn) {
      AppSettings.shared.userAccount.syncUserDb<void>(onlyPostChanges: true);
    }
  }
}

/// This widget is just for observing app events
class _AppBindingObserver extends StatefulWidget {
  final Widget child;

  const _AppBindingObserver({Key key, this.child}) : super(key: key);

  @override
  _AppBindingObserverState createState() => _AppBindingObserverState();
}

// ignore: prefer_mixin
class _AppBindingObserverState extends State<_AppBindingObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.bloc<AppLifecycleBloc>()?.add(state);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../models/app_settings.dart';

class AppLifecycleBloc extends Bloc<AppLifecycleState, AppLifecycleState> {
  @override
  AppLifecycleState get initialState => AppLifecycleState.resumed;

  @override
  Stream<AppLifecycleState> mapEventToState(AppLifecycleState event) async* {
    final newState = event;
    tec.dmPrint('App state changed to $event');

    if (newState != null && newState != state) {
      if (newState == AppLifecycleState.resumed) {
        _resume();
      } else if (newState == AppLifecycleState.paused) {
        _pause();
      }
      yield newState;
    } else {
      yield state;
    }
  }

  void _resume() {
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

  void _pause() {
    _pausedStopwatch
      ..reset()
      ..start();

    // If a user is signed in, initiate a sync to only post changes (so it completes quickly).
    if (AppSettings.shared.userAccount.isSignedIn) {
      AppSettings.shared.userAccount.syncUserDb<void>(onlyPostChanges: true);
    }
  }

  int _appResumedCount = 0;
  final _pausedStopwatch = Stopwatch();

  ///
  /// The running count of times the app has been resumed (resets on app boot).
  ///
  int get appResumedCount => _appResumedCount;

  ///
  /// If the app is in the 'paused' state, returns the current pause duration.
  /// If the app is in the 'resumed' state, returns the duration of the
  /// previous pause, or Duration.zero if it has not yet been paused.
  ///
  Duration get pausedDuration => _pausedStopwatch.elapsed;
}

///
/// Provides App Lifecycle Bloc to App
///
class AppLifecycleWrapper extends StatelessWidget {
  final Widget child;
  const AppLifecycleWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppLifecycleBloc>(
      create: (c) => AppLifecycleBloc(),
      child: AppBindingObserver(child),
    );
  }
}

///
/// This widget is just for observing app events
///
class AppBindingObserver extends StatefulWidget {
  final Widget child;
  const AppBindingObserver(this.child);
  @override
  AppBindingObserverState createState() => AppBindingObserverState();
}

// ignore: prefer_mixin
class AppBindingObserverState extends State<AppBindingObserver> with WidgetsBindingObserver {
  AppLifecycleBloc bloc() => context.bloc<AppLifecycleBloc>();

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
    bloc().add(state);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

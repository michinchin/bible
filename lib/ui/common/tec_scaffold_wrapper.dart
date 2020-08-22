import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/app_settings.dart';

class TecScaffoldWrapper extends StatefulWidget {
  final Widget child;

  const TecScaffoldWrapper({@required this.child});

  @override
  _TecScaffoldWrapperState createState() => _TecScaffoldWrapperState();

  static bool mediaQueryReady(BuildContext context) {
    if (MediaQuery.of(context).size == Size.zero) {
      return false;
    }

    if (AppSettings.shared.androidFullScreen is! bool) {
      AppSettings.shared.statusBarHeight = MediaQuery.of(context).systemGestureInsets.top;
      AppSettings.shared.navigationBarPadding =
          MediaQuery.of(context).systemGestureInsets.bottom / 2;
      AppSettings.shared.androidFullScreen =
          tec.platformIs(tec.Platform.android) && AppSettings.shared.navigationBarPadding == 16.0;
    }

    return true;
  }
}

class _TecScaffoldWrapperState extends State<TecScaffoldWrapper> {
  // returns false if MediaQuery isn't ready
  void _getStatusBarPadding(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (AppSettings.shared.androidFullScreen) {
      final landscape = size.width > size.height;
      if (math.max(size.width, size.height) < 1004) {
        // it's a phone...
        if (landscape) {
          AppSettings.shared.statusBarPadding = 0;
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
        } else {
          AppSettings.shared.statusBarPadding = AppSettings.shared.statusBarHeight;
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (!TecScaffoldWrapper.mediaQueryReady(context)) {
        return Container();
      }

      _getStatusBarPadding(context);

      return Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.color,
            height: AppSettings.shared.statusBarPadding,
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      );
    });
  }
}

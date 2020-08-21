import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/app_settings.dart';

class TecBottomSheetSafeArea extends StatefulWidget {
  final Widget child;

  const TecBottomSheetSafeArea({@required this.child});

  @override
  _TecBottomSheetSafeAreaState createState() => _TecBottomSheetSafeAreaState();
}

class _TecBottomSheetSafeAreaState extends State<TecBottomSheetSafeArea> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(bottom: AppSettings.shared.navigationBarPadding),
      child: widget.child,
    );
  }
}
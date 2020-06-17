import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'tec_modal_popup.dart';
export 'tec_page_route.dart';

class LoadingIndicator extends StatelessWidget {
  final double radius;

  const LoadingIndicator({Key key, this.radius = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(brightness: Theme.of(context).brightness),
      child: CupertinoActivityIndicator(
        radius: radius,
      ));
}

///
/// ThemeData extensions.
///
extension ExtOnThemeData on ThemeData {
  TextTheme copyOfAppBarTextThemeWithColor(Color color) =>
      appBarTheme.textTheme?.apply(bodyColor: color) ??
      primaryTextTheme?.apply(bodyColor: color) ??
      TextTheme(headline6: TextStyle(color: color));
}

///
/// AppBarTheme extensions.
///
// extension _ExtOnAppBarTheme on AppBarTheme {
//   IconThemeData copyOfActionsIconThemeWithColor(Color color) =>
//       actionsIconTheme?.copyWith(color: color) ?? IconThemeData(color: color);
//   IconThemeData copyOfIconThemeWithColor(Color color) =>
//       iconTheme?.copyWith(color: color) ?? IconThemeData(color: color);
// }

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

class IconWithNumberBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  const IconWithNumberBadge({this.icon, this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Icon(icon),
      if (value != 0)
        Positioned(
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
    ]);
  }
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

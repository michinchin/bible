import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;

import 'models/app_settings.dart';
import 'models/labels.dart';
import 'ui/common/common.dart';
import 'ui/misc/text_settings.dart';

const tecartaBlue = Color(0xff4a7dee);

Future<void> showMainMenu(BuildContext context) {
  return showTecModalPopup<void>(
    context: context,
    alignment: Alignment.topLeft,
    useRootNavigator: true,
    builder: (context) => TecPopupSheet(child: MainMenu()),
  );
}

// ignore_for_file: prefer_const_constructors
const _textMaxScaleFactor = 1.0;

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final drawerTextColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[700];

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(color: drawerTextColor),
        textTheme: TextTheme(bodyText2: TextStyle(color: drawerTextColor)),
      ),
      child: SizedBox(
        width: 235,
        child: Material(
          child: Column(
            children: [
              MenuListTile(
                icon: tec.platformIs(tec.Platform.iOS) ? FeatherIcons.share : FeatherIcons.share2,
                title: 'Share app',
                onTap: null,
              ),
              MenuListTile(
                icon: FeatherIcons.bell,
                title: 'Notifications',
                onTap: null,
              ),
              MenuListTile(
                icon: Icons.format_size,
                title: 'Text Size',
                onTap: () {
                  Navigator.of(context).pop();
                  showTextSettingsDialog(context);
                },
              ),
              Divider(),
              MenuListTile(
                  icon: FeatherIcons.user,
                  title: AppSettings.shared.userAccount.isSignedIn
                      ? '${AppSettings.shared.userAccount.user.email}'
                      : 'Account',
                  onTap: () {
                    Navigator.of(context).pop();
                    tua.showSignInDlg(
                        context: context,
                        account: AppSettings.shared.userAccount,
                        useRootNavigator: true,
                        appName: Labels.appNameForUA);
                  }),
              if (tec.platformIs(tec.Platform.iOS))
                MenuListTile(
                  icon: Icons.restore,
                  title: 'Restore Purchases',
                  onTap: null,
                ),
              MenuListTile(
                icon: FeatherIcons.helpCircle,
                title: 'Help & Feedback',
                onTap: null,
              ),
              MenuListTile(
                icon: FeatherIcons.info,
                title: 'About',
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const TextStyle _menuTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

class MenuListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool switchValue;
  final GestureTapCallback onTap;

  const MenuListTile({Key key, this.icon, this.title, this.switchValue, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Color.lerp(
        Theme.of(context).textColor, Theme.of(context).canvasColor, onTap == null ? 0.75 : 0);
    return switchValue == null
        ? ListTile(
            dense: true,
            leading: icon == null ? const Text('') : MenuIcon(iconData: icon),
            title: TecText(
              title,
              maxScaleFactor: _textMaxScaleFactor,
              style: _menuTitleStyle.copyWith(color: textColor),
            ),
            onTap: onTap,
          )
        : SwitchListTile.adaptive(
            onChanged: (b) => onTap(),
            value: switchValue,
            activeColor: tecartaBlue,
            secondary: icon == null ? const Text('') : MenuIcon(iconData: icon),
            dense: true,
            title: TecText(
              title,
              maxScaleFactor: _textMaxScaleFactor,
              style: _menuTitleStyle.copyWith(color: textColor),
            ),
          );
  }
}

class MenuIcon extends StatelessWidget {
  final IconData iconData;

  const MenuIcon({Key key, this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) => Icon(iconData, size: 20);
}

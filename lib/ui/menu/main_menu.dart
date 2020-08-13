import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/labels.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../misc/text_settings.dart';
import 'menu_model.dart';

const tecartaBlue = Color(0xff4a7dee);

Future<void> showMainMenu(BuildContext context) {
  TecAutoScroll.stopAutoscroll();

  return showTecDialog<void>(
    context: context,
    padding: const EdgeInsets.all(15),
    cornerRadius: 15,
    useRootNavigator: true,
    builder: (context) => MainMenu(menuModel: MenuModel()),
  );
}

// ignore_for_file: prefer_const_constructors
// const _textMaxScaleFactor = 1.0;

class MainMenu extends StatelessWidget {
  final MenuModel menuModel;
  const MainMenu({this.menuModel});
  @override
  Widget build(BuildContext context) {
    final drawerTextColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[700];
    final prefBloc = context.bloc<PrefItemsBloc>(); //ignore: close_sinks

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(color: drawerTextColor),
        textTheme: TextTheme(bodyText2: TextStyle(color: drawerTextColor)),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              MenuListTile(
                icon: tec.platformIs(tec.Platform.iOS) ? FeatherIcons.share : FeatherIcons.share2,
                title: 'Share app',
                onTap: () => menuModel.shareApp(context),
              ),
              MenuListTile(
                icon: FeatherIcons.bell,
                title: 'Notifications',
                onTap: null,
              ),
              MenuListTile(
                icon: Icons.lightbulb_outline,
                switchValue: () =>
                    context.bloc<ThemeModeBloc>().state == ThemeMode.dark ||
                    (context.bloc<ThemeModeBloc>().state == ThemeMode.system &&
                        WidgetsBinding.instance.window.platformBrightness == Brightness.dark),
                title: 'Dark Mode',
                onTap: () => context.bloc<ThemeModeBloc>().add(ThemeModeEvent.toggle),
              ),
              MenuListTile(
                icon: Icons.link,
                switchValue: () => prefBloc.itemBool(PrefItemId.includeShareLink),
                title: 'Include Link in Copy/Share',
                onTap: () {
                  prefBloc.add(PrefItemEvent.update(
                      prefItem: prefBloc.toggledPrefItem(PrefItemId.includeShareLink)));
                },
              ),
              MenuListTile(
                title: 'Autoscroll',
                icon: Icons.play_circle_outline,
                switchValue: TecAutoScroll.isEnabled,
                onTap: () => TecAutoScroll.setEnabled(enabled: !TecAutoScroll.isEnabled()),
              ),
              MenuListTile(
                icon: Icons.format_size,
                title: 'Text Settings',
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
                onTap: () => menuModel.emailFeedback(context),
              ),
              MenuListTile(
                icon: FeatherIcons.info,
                title: 'About',
                onTap: () => menuModel.showAboutDialog(context),
              ),
            ],
          ),
//          IconButton(
//            icon: Icon(
//              Icons.close,
//              color: Theme.of(context).textColor.withOpacity(0.5),
//            ),
//            onPressed: Navigator.of(context).maybePop,
//          )
        ],
      ),
    );
  }
}

// const TextStyle _menuTitleStyle = TextStyle(
//   fontSize: 12,
//   fontWeight: FontWeight.w600,
// );

class MenuListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool Function() switchValue;
  final GestureTapCallback onTap;

  const MenuListTile({Key key, this.icon, this.title, this.switchValue, this.onTap})
      : super(key: key);

  @override
  _MenuListTileState createState() => _MenuListTileState();
}

class _MenuListTileState extends State<MenuListTile> {
  @override
  Widget build(BuildContext context) {
    final textColor = Color.lerp(Theme.of(context).textColor, Theme.of(context).canvasColor,
        widget.onTap == null ? 0.75 : 0);
    return widget.switchValue == null
        ? ListTile(
            dense: true,
            leading: widget.icon == null ? const Text('') : MenuIcon(iconData: widget.icon),
            title: TecText(
              widget.title,
              // maxScaleFactor: _textMaxScaleFactor,
              // style: _menuTitleStyle.copyWith(color: textColor),
              style: TextStyle(color: textColor),
            ),
            onTap: widget.onTap,
          )
        : SwitchListTile.adaptive(
            onChanged: (b) {
              setState(() {
                widget.onTap();
              });
            },
            value: widget.switchValue(),
            activeColor: tecartaBlue,
            secondary: widget.icon == null ? const Text('') : MenuIcon(iconData: widget.icon),
            dense: true,
            title: TecText(
              widget.title,
              // maxScaleFactor: _textMaxScaleFactor,
              style: TextStyle(color: textColor),
              // style: _menuTitleStyle.copyWith(color: textColor),
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

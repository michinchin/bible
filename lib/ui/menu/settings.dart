import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../misc/text_settings.dart';
import 'main_menu_model.dart';

void showSettings(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (c) => SettingsView(
              menuModel: MainMenuModel(),
            )));

class SettingsView extends StatelessWidget {
  final MainMenuModel menuModel;

  const SettingsView({this.menuModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinHeightAppBar(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
      ),
      body: Container(
          color: Theme.of(context).dialogBackgroundColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                Expanded(
                  child: ListView(children: [
                    _TitleSettingTile(
                      title: 'Account',
                      icon: FeatherIcons.user,
                      trailing: FlatButton.icon(
                        icon:
                            Text('Sync now', style: TextStyle(color: Theme.of(context).textColor)),
                        label: Icon(Icons.sync, color: Theme.of(context).textColor),
                        onPressed: () => TecToast.show(context, 'Not yet implemented'),
                      ),
                    ),
                    const _TitleSettingTile(title: 'Read', icon: FeatherIcons.bookmark),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 10),
                      child: Column(children: readTiles(context)),
                    ),
                    const _TitleSettingTile(title: 'Notifications', icon: FeatherIcons.bell),
                    const _TitleSettingTile(title: 'Audio', icon: FeatherIcons.volume1),
                  ]),
                )
              ],
            ),
          )),
    );
  }
}

List<Widget> readTiles(BuildContext context) {
  final prefBloc = context.tbloc<PrefItemsBloc>(); //ignore: close_sinks
  final color = Theme.of(context).textColor;
  final textStyle = TextStyle(fontSize: 15, color: color);

  return [
    SwitchListTile.adaptive(
        dense: true,
        secondary: Icon(Icons.lightbulb_outline, color: color),
        title: Text('Dark theme', style: textStyle),
        onChanged: (_) => context.tbloc<ThemeModeBloc>().add(ThemeModeEvent.toggle),
        value: AppSettings.shared.isDarkTheme()),
    SwitchListTile.adaptive(
      dense: true,
      secondary: Icon(Icons.link, color: color),
      title: Text('Include Link in Copy/Share', style: textStyle),
      onChanged: (_) => prefBloc.add(
          PrefItemEvent.update(prefItem: prefBloc.toggledPrefItem(PrefItemId.includeShareLink))),
      value: prefBloc.itemBool(PrefItemId.includeShareLink),
    ),
    SwitchListTile.adaptive(
      dense: true,
      secondary: Icon(Icons.close, color: color),
      title: Text('Close Sheet after Copy/Share', style: textStyle),
      onChanged: (_) => prefBloc.add(
          PrefItemEvent.update(prefItem: prefBloc.toggledPrefItem(PrefItemId.closeAfterCopyShare))),
      value: prefBloc.itemBool(PrefItemId.closeAfterCopyShare),
    ),
    SwitchListTile.adaptive(
      dense: true,
      secondary: Icon(Icons.play_circle_outline, color: color),
      title: Text('Autoscroll', style: textStyle),
      onChanged: (_) => TecAutoScroll.setEnabled(enabled: !TecAutoScroll.isEnabled()),
      value: TecAutoScroll.isEnabled(),
    ),
    ListTile(
      dense: true,
      leading: Icon(Icons.format_size, color: color),
      title: Text('Text Settings', style: textStyle),
      onTap: () {
        while (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        showTextSettingsDialog(context);
      },
    )
  ];
}

class _TitleSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _TitleSettingTile({this.icon, this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: const TextStyle(fontSize: 18.0),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              Icon(
                icon,
                size: 25,
              ),
              const VerticalDivider(color: Colors.transparent),
              titleWidget,
            ],
          ),
          if (trailing != null) Padding(padding: const EdgeInsets.only(right: 15), child: trailing)
        ]),
        const Divider(indent: 40),
      ]),
    );
  }
}

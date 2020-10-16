import 'package:bible/blocs/app_theme_bloc.dart';
import 'package:bible/blocs/sheet/pref_items_bloc.dart';
import 'package:bible/models/app_settings.dart';
import 'package:bible/models/pref_item.dart';
import 'package:bible/ui/misc/text_settings.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return TecScaffoldWrapper(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            // flexibleSpace: TextField(
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(),
            //   ),
            // ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Settings',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textColor),
                ),
              ),
              Expanded(
                child: ListView(children: [
                  _TitleSettingTile(
                    title: 'Account',
                    icon: FeatherIcons.user,
                    trailing: FlatButton.icon(
                      textColor: Theme.of(context).textColor.withOpacity(0.5),
                      icon: const Text('Sync now'),
                      label: Icon(Icons.sync, color: Theme.of(context).textColor.withOpacity(0.5)),
                      onPressed: () {},
                    ),
                  ),
                  _TitleSettingTile(title: 'Read', icon: FeatherIcons.bookmark),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Column(children: readTiles(context)),
                  ),
                  _TitleSettingTile(title: 'Notifications', icon: FeatherIcons.bell),
                  _TitleSettingTile(
                    title: 'Audio',
                    icon: FeatherIcons.volume1,
                  ),
                ]),
              )
            ],
          )),
    );
  }
}

List<Widget> readTiles(BuildContext context) {
  final prefBloc = context.bloc<PrefItemsBloc>(); //ignore: close_sinks

  return [
    SwitchListTile.adaptive(
        dense: true,
        secondary: const Icon(Icons.lightbulb_outline),
        title: const Text('Dark theme'),
        onChanged: (_) => context.bloc<ThemeModeBloc>().add(ThemeModeEvent.toggle),
        value: AppSettings.shared.isDarkTheme()),
    SwitchListTile.adaptive(
      dense: true,
      secondary: const Icon(Icons.link),
      title: const Text('Include Link in Copy/Share'),
      onChanged: (_) => prefBloc.add(
          PrefItemEvent.update(prefItem: prefBloc.toggledPrefItem(PrefItemId.includeShareLink))),
      value: prefBloc.itemBool(PrefItemId.includeShareLink),
    ),
    SwitchListTile.adaptive(
      dense: true,
      secondary: Icon(Icons.close),
      title: Text('Close Sheet after Copy/Share'),
      onChanged: (_) => prefBloc.add(
          PrefItemEvent.update(prefItem: prefBloc.toggledPrefItem(PrefItemId.closeAfterCopyShare))),
      value: prefBloc.itemBool(PrefItemId.closeAfterCopyShare),
    ),
    SwitchListTile.adaptive(
      dense: true,
      secondary: Icon(Icons.play_circle_outline),
      title: Text('Autoscroll'),
      onChanged: (_) => TecAutoScroll.setEnabled(enabled: !TecAutoScroll.isEnabled()),
      value: TecAutoScroll.isEnabled(),
    ),
    ListTile(
      dense: true,
      leading: Icon(Icons.format_size),
      title: Text('Text Settings'),
      onTap: () {
        while(Navigator.canPop(context)){
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
      style: Theme.of(context).textTheme.headline5.copyWith(
          fontWeight: FontWeight.w600, color: Theme.of(context).textColor.withOpacity(0.5)),
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
                color: Theme.of(context).textColor.withOpacity(0.5),
              ),
              const VerticalDivider(color: Colors.transparent),
              titleWidget,
            ],
          ),
          if (trailing != null) Padding(padding: const EdgeInsets.only(right: 15), child: trailing)
        ]),
        Divider(indent: 40),
      ]),
    );
  }
}

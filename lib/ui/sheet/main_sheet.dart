import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../home/today.dart';
import '../library/library.dart';

class MainSheet extends StatefulWidget {
  const MainSheet({Key key}) : super(key: key);

  @override
  _MainSheetState createState() => _MainSheetState();
}

class _MainSheetState extends State<MainSheet> {
  @override
  Widget build(BuildContext context) {
    final miniViewIcons = {
      'Home': FeatherIcons.home,
      'Library': FeatherIcons.book,
      'Audio': FeatherIcons.play,
      'Notes': FeatherIcons.edit2
    };

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final key in miniViewIcons.keys)
            SheetIconButton(
              text: key,
              icon: miniViewIcons[key],
              onPressed: () {
                tec.dmPrint('Tapped button $key');
                if (key == 'Library') showLibrary(context);
                if (key == 'Notes') {
                  ViewManager.shared.makeVisibleOrAdd(context, Const.viewTypeNotes);
                }
                if (key == 'Home') showTodayScreen(context);
              },
            )
        ],
      ),
    );
  }
}

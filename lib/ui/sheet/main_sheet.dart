import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../home/home.dart';
import '../library/library.dart';
import '../note/notes.dart';

class MainSheet extends StatefulWidget {
  final SheetSize sheetSize;

  const MainSheet({this.sheetSize, Key key}) : super(key: key);

  @override
  _MainSheetState createState() => _MainSheetState();
}

class _MainSheetState extends State<MainSheet> {
  final miniViewIcons = {
    'Home': FeatherIcons.home,
    'Library': FeatherIcons.book,
    'Listen': FeatherIcons.play,
    'Notes': FeatherIcons.edit2
  };

  final buttonActions = <String, VoidCallback>{};

  @override
  Widget build(BuildContext context) {
    Widget child;
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (widget.sheetSize == SheetSize.mini) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final key in miniViewIcons.keys)
            SheetIconButton(
              text: key,
              icon: miniViewIcons[key],
              onPressed: () {
                tec.dmPrint('Tapped button $key');
                if (key == 'Library') showLibrary(context);
                if (key == 'Notes') showNotes(context);
                if (key == 'Home') showHome(context);
              },
            )
        ],
      );
    } else {
      child = GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: landscape ? 5.0 : 3.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.only(top: 0),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final key in miniViewIcons.keys)
            SheetButton(
              icon: miniViewIcons[key],
              onPressed: buttonActions[key] ??
                  () {
                    tec.dmPrint('Tapped button $key');
                    if (key == 'Library') showLibrary(context);
                    if (key == 'Notes') showNotes(context);
                  },
              text: key,
            ),
        ],
      );
    }

    return Padding(padding: const EdgeInsets.only(left: 15, right: 15), child: child);
  }
}

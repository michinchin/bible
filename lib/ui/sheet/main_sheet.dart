import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../ui/sheet/snap_sheet.dart';

class MainSheet extends StatefulWidget {
  final SheetSize sheetSize;
  const MainSheet({this.sheetSize});
  @override
  _MainSheetState createState() => _MainSheetState();
}

class _MainSheetState extends State<MainSheet> {
  final miniViewIcons = {
    'Explore': FeatherIcons.compass,
    'Libray': FeatherIcons.book,
    'Listen': FeatherIcons.play,
    'Notes': FeatherIcons.edit2
  };
  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            if (widget.sheetSize == SheetSize.mini)
              Container(
                height: 100,
                child: GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: landscape ? 2.0 : 1.0,
                  // padding: const EdgeInsets.only(top: 0),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final key in miniViewIcons.keys)
                      SheetIconButton(
                        text: key,
                        icon: miniViewIcons[key],
                        onPressed: () {},
                      )
                  ],
                ),
              )
            else
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: landscape ? 4.0 : 2.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.only(top: 0),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final key in miniViewIcons.keys)
                      SheetButton(
                        icon: miniViewIcons[key],
                        // onPressed: () {},
                        text: key,
                      ),
                  ],
                ),
              ),
          ],
        ));
  }
}

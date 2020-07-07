import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';

class WindowManagerSheet extends StatelessWidget {
  final SheetSize sheetSize;
  const WindowManagerSheet({this.sheetSize});

  @override
  Widget build(BuildContext context) {
    final state = context.bloc<SheetManagerBloc>().state;
    final iconMap = <String, IconData>{
      'Bible': FeatherIcons.book,
      'Notes': FeatherIcons.edit,
      'Test View': FeatherIcons.plusSquare
      // Icons.add,
      // Icons.add,
      // Icons.add,
    };
    Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onPressed) {
      final textColor = Theme.of(context).textColor;
      const iconSize = 30.0;
      return FlatButton(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).textColor.withOpacity(0.5),
              size: iconSize,
            ),
            const SizedBox(height: 5),
            TecText(
              title,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        onPressed: onPressed,
      );
    }

    Iterable<Widget> _generateAddMenuItems(BuildContext context, int viewUid) {
      final vm = ViewManager.shared;
      return vm.types.map<Widget>(
        (type) =>
            _menuItem(context, iconMap[vm.titleForType(type)], 'Add ${vm.titleForType(type)}', () {
          context.bloc<SheetManagerBloc>()
            ..changeType(SheetType.main)
            ..changeSize(SheetSize.collapsed);
          final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
          final position = bloc?.indexOfView(viewUid) ?? -1;
          bloc?.add(ViewManagerEvent.add(
              type: type, data: '', position: position == -1 ? null : position + 1));
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TecText(
          'Window Actions',
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Wrap(
            alignment: WrapAlignment.spaceAround,
            children: _generateAddMenuItems(context, state.viewUid).toList()
              ..add(
                _menuItem(context, Icons.close, 'Close View', () {
                  context.bloc<SheetManagerBloc>()
                    ..changeType(SheetType.main)
                    ..changeSize(SheetSize.collapsed);
                  context.bloc<ViewManagerBloc>()?.add(ViewManagerEvent.remove(state.viewUid));
                }),
              )),
      ],
    );
  }
}

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import 'snap_sheet.dart';

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
    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    final isMaximized = bloc?.state?.maximizedViewUid != 0;
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final mini = sheetSize == SheetSize.mini;

    Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onPressed) {
      // final child = FlatButton(
      //   padding: EdgeInsets.zero,
      //   child: Container(
      //     height: mini ? 50 : 100,
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         Expanded(
      //           flex: 3,
      //           child: Icon(
      //             icon,
      //             color: Theme.of(context).textColor.withOpacity(0.5),
      //           ),
      //         ),
      //         const SizedBox(height: 5),
      //         Expanded(
      //           child: TecText(
      //             title,
      //             style: TextStyle(color: textColor),
      //             autoCalcMaxLines: true,
      //             overflow: TextOverflow.ellipsis,
      //             textAlign: TextAlign.center,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      //   onPressed: onPressed,
      // );

      return GreyCircleButton(
        icon: icon,
        onPressed: onPressed,
        title: title,
      );
    }

    Iterable<Widget> _generateAddMenuItems(BuildContext context, int viewUid) {
      final vm = ViewManager.shared;

      return vm.types.map<Widget>(
        (type) =>
            _menuItem(context, iconMap[vm.titleForType(type)], 'Add ${vm.titleForType(type)}', () {
          Navigator.of(context).maybePop();
          final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
          final position = bloc?.indexOfView(viewUid) ?? -1;
          bloc?.add(const ViewManagerEvent.restore());
          bloc?.add(ViewManagerEvent.add(
              type: type, data: '', position: position == -1 ? null : position + 1));
        }),
      );
    }

    final children = _generateAddMenuItems(context, state.viewUid).toList()
      ..addAll([
        if (context.bloc<ViewManagerBloc>().state.views.length > 1) ...[
          _menuItem(context, isMaximized ? FeatherIcons.minimize2 : FeatherIcons.maximize2,
              isMaximized ? 'Restore' : 'Maximize', () {
            Navigator.of(context).maybePop();
            bloc?.add(isMaximized
                ? const ViewManagerEvent.restore()
                : ViewManagerEvent.maximize(state.viewUid));
          }),
          _menuItem(context, Icons.close, 'Close View', () {
            Navigator.of(context).maybePop();
            context.bloc<ViewManagerBloc>()?.add(ViewManagerEvent.remove(state.viewUid));
          }),
        ]
      ]);
    return Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        alignment: Alignment.topCenter,
        child: GridView.count(
          // padding: const EdgeInsets.only(top: 10),
          childAspectRatio: landscape ? (mini ? 3.0 : 2.0) : 1.0,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 0,
          crossAxisCount: 3,
          children: children,
        ));
  }
}

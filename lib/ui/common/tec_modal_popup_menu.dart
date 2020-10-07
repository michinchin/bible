import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import 'tec_modal_popup.dart';

const tecartaBlue = Color(0xff4a7dee);

Future<void> showTecModalPopupMenu({
  @required BuildContext context,
  @required List<TableRow> Function(BuildContext context) menuItemsBuilder,
  EdgeInsetsGeometry insets,
  double minWidth,
}) {
  return showTecModalPopup<void>(
    useRootNavigator: true,
    context: context,
    alignment: Alignment.topRight,
    edgeInsets: insets,
    builder: (context) => TecPopupSheet(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: minWidth == null ? null : BoxConstraints(minWidth: minWidth),
          child: BlocProvider(
            create: (context) => _RefreshBloc(),
            child: BlocBuilder<_RefreshBloc, int>(
              builder: (context, i) {
                tec.dmPrint('TecModalPopupMenu build $i');
                return Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: menuItemsBuilder(context),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

TableRow tecModalPopupMenuItem(
  BuildContext context,
  IconData icon,
  String title,
  VoidCallback onTap, {
  bool Function() getSwitchValue,
}) {
  final textScaleFactor = scaleFactorWith(context, maxScaleFactor: 1.2);
  final textColor = Theme.of(context).textColor.withOpacity(onTap == null ? 0.2 : 0.5);
  final iconSize = 24.0 * textScaleFactor;

  void Function() _onTap() => onTap == null
      ? null
      : getSwitchValue == null
          ? onTap
          : () {
              onTap();
              context.bloc<_RefreshBloc>().refresh();
            };

  return TableRow(
    children: [
      TableRowInkWell(
        onTap: _onTap(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 14, 10),
              child: icon == null
                  ? SizedBox(width: iconSize)
                  : Icon(icon, color: textColor, size: iconSize),
            ),
            // const SizedBox(width: 10),
            TecText(
              title,
              textScaleFactor: textScaleFactor,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
      TableRowInkWell(
        onTap: _onTap(),
        child: getSwitchValue == null
            ? Container(padding: const EdgeInsets.fromLTRB(0, 16, 0, 16))
            : Switch.adaptive(
                activeColor: tecartaBlue,
                value: getSwitchValue() ?? false,
                onChanged: onTap == null ? null : (_) => _onTap()?.call(),
              ),
      ),
    ],
  );
}

TableRow tecModalPopupMenuDivider(BuildContext context, [String title]) {
  return TableRow(
    children: [
      if (title?.isEmpty ?? true)
        const Divider(thickness: 1)
      else
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TecText(title,
                  style: TextStyle(
                    fontSize: 13,
                    // fontWeight: FontWeight.w600,
                    color: Theme.of(context).textColor.withOpacity(0.5),
                  )),
              const Expanded(child: Divider(indent: 10, thickness: 1))
            ],
          ),
        ),
      const Divider(thickness: 1),
    ],
  );
}

class _RefreshBloc extends Cubit<int> {
  _RefreshBloc() : super(0);
  void refresh() => emit(state + 1);
}

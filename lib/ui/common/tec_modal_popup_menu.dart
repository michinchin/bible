import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

import 'tec_modal_popup.dart';

Future<void> showTecModalPopupMenu({
  @required BuildContext context,
  @required List<TableRow> Function(BuildContext context) menuItemsBuilder,
  bool includeSwitchColumn = false,
  EdgeInsetsGeometry insets,
}) {
  return showTecModalPopup<void>(
    useRootNavigator: true,
    context: context,
    alignment: Alignment.topRight,
    edgeInsets: insets,
    builder: (context) => TecPopupSheet(
      child: Material(
        color: Colors.transparent, // Theme.of(context).scaffoldBackgroundColor,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: menuItemsBuilder(context),
        ),
      ),
    ),
  );
}

TableRow tecModalPopupMenuItem(
    BuildContext context, IconData icon, String title, VoidCallback onTap) {
  final textScaleFactor = scaleFactorWith(context, maxScaleFactor: 1.2);
  final textColor = Theme.of(context).textColor.withOpacity(onTap == null ? 0.2 : 0.5);
  final iconSize = 24.0 * textScaleFactor;

  return TableRow(
    children: [
      TableRowInkWell(
        onTap: onTap,
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
    ],
  );
}

TableRow tecModalPopupMenuDivider(BuildContext context, double width, [String title]) {
  final textColor = Theme.of(context).textColor.withOpacity(0.5);
  return TableRow(
    children: [
      SizedBox(
        width: width,
        child: title?.isEmpty ?? true
            ? const Divider()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TecText(title, style: TextStyle(fontSize: 12, color: textColor)),
                  const Expanded(child: Divider(indent: 10))
                ],
              ),
      ),
    ],
  );
}

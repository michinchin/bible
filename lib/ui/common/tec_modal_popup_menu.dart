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
  Alignment alignment = Alignment.center,
  double minWidth,
}) {
  return showTecModalPopup<void>(
    useRootNavigator: true,
    context: context,
    alignment: alignment,
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
  String subtitle,
}) {
  final scale = scaleFactorWith(context, maxScaleFactor: 1.2);
  final color = Theme.of(context).textColor.withOpacity(onTap == null ? 0.2 : 0.5);
  final iconSize = 24.0 * scale;

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
                  : Icon(icon, color: color, size: iconSize),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TecText(title, textScaleFactor: scale, style: TextStyle(color: color)),
                  if (subtitle != null)
                    TecText(subtitle, textScaleFactor: scale, style: TextStyle(color: color)),
                ],
              ),
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

TableRow tecModalPopupMenuTitle(String title, {bool showClose = true}) {
  return TableRow(
    children: [
      TecTitleBar(title: title),
      Container(),
    ],
  );
}

class _RefreshBloc extends Cubit<int> {
  _RefreshBloc() : super(0);
  void refresh() => emit(state + 1);
}

class TecTitleBar extends StatelessWidget {
  final String title;
  final TextStyle style;
  final double maxWidth;

  const TecTitleBar({Key key, this.title, this.style, this.maxWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final color = isDarkTheme ? Colors.white : Colors.grey[700];
    var textStyle = TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w500);
    if (style != null) textStyle = textStyle.merge(style);
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, textAlign: TextAlign.center, style: textStyle)),
              ],
            ),
            Positioned(
              left: 4,
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  splashRadius: 12,
                  color: color,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context, rootNavigator: true).maybePop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

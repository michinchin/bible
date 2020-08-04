import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

class TecPopupMenuButton<T> extends StatelessWidget {
  final String title;
  final LinkedHashMap<T, String> values;
  final T currentValue;
  final T defaultValue;
  final String defaultName;
  final void Function(T value) onSelectValue;

  const TecPopupMenuButton({
    Key key,
    @required this.title,
    @required this.values,
    this.currentValue,
    this.defaultValue,
    this.defaultName,
    this.onSelectValue,
  })  : assert(title != null),
        assert(values != null),
        assert(defaultValue == null || defaultName != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = textScaleFactorWith(context);
    final entryHeight = (32.0 * textScaleFactor).roundToDouble();

    final keys = values.keys.toList();
    if (defaultValue != null && !keys.contains(defaultValue)) {
      keys.insert(0, defaultValue);
    }
    final items = keys
        .map<PopupMenuEntry<String>>(
          (key) => PopupMenuItem<String>(
            height: entryHeight,
            value: values[key] ?? defaultName,
            child: TecText(
              values[key] ?? defaultName,
              textScaleFactor: textScaleFactor,
              style: TextStyle(
                fontWeight: key == currentValue ? FontWeight.bold : FontWeight.normal,
                color: key == currentValue
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87),
              ),
            ),
          ),
        )
        .toList();

    final currentName = currentValue == null ? null : values[currentValue] ?? defaultName;
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: TecText.rich(
          TextSpan(
            children: [
              TextSpan(text: title.endsWith(': ') ? title : '$title: '),
              if (tec.isNotNullOrEmpty(currentName))
                TextSpan(
                  text: currentName,
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
            ],
          ),
          textScaleFactor: textScaleFactor,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      offset: const Offset(150, 0),
      onSelected: (string) {
        final value = values.keys.firstWhere(
          (k) => values[k] == string,
          orElse: () => defaultValue,
        );
        onSelectValue?.call(value);
      },
      itemBuilder: (context) => items,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    );
  }
}

class TecTextButton extends StatelessWidget {
  final String title;
  final String tooltip;
  final void Function() onTap;

  const TecTextButton({Key key, this.title, this.tooltip, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: TecText(
            title,
            textScaleFactor: textScaleFactorWith(context),
            style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
          ),
        ),
      ),
    );
  }
}
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

const _buttonFontSize = 18.0;

///
/// An easier to use TecPopupMenuButton where the menu item strings and values
/// are the same, so just requires an iterable list of menu item strings
/// instead of a map of values and strings like TecPopupMenuButton.
///
class TecEZPopupMenuButton extends TecPopupMenuButton<String> {
  TecEZPopupMenuButton({
    Key key,
    @required String title,
    @required Iterable<String> menuItems,
    final String currentValue,
    final String defaultValue,
    final void Function(String value) onSelectValue,
    final double padding = 8.0,
  })  : assert(title != null),
        assert(menuItems != null),
        super(
          key: key,
          title: title,
          values: {for (final s in menuItems) s: s} as LinkedHashMap<String, String>,
          currentValue: currentValue,
          defaultValue: defaultValue,
          defaultName: defaultValue,
          onSelectValue: onSelectValue,
          padding: padding,
        );
}

///
/// A button that shows a popup menu when tapped.
///
class TecPopupMenuButton<T> extends StatelessWidget {
  final String title;
  final LinkedHashMap<T, String> values;
  final T currentValue;
  final T defaultValue;
  final String defaultName;
  final void Function(T value) onSelectValue;
  final double padding;

  const TecPopupMenuButton({
    Key key,
    @required this.title,
    @required this.values,
    this.currentValue,
    this.defaultValue,
    this.defaultName,
    this.onSelectValue,
    this.padding = 8.0,
  })  : assert(title != null),
        assert(values != null),
        assert(defaultValue == null || defaultName != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = textScaleFactorWith(context);
    final entryHeight = (36.0 * textScaleFactor).roundToDouble();

    final keys = values.keys.toList();
    if (defaultValue != null && !keys.contains(defaultValue)) {
      keys.insert(0, defaultValue);
    }
    final items = keys
        .map<PopupMenuEntry<String>>(
          (key) => PopupMenuItem<String>(
            height: entryHeight,
            value: values[key] ?? defaultName,
            child: Text(
              values[key] ?? defaultName,
              textScaleFactor: textScaleFactor,
              style: TextStyle(
                fontSize: _buttonFontSize,
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
        padding: EdgeInsets.all(padding ?? 8.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: title.endsWith(': ') || title.isEmpty ? title : '$title: '),
              if (tec.isNotNullOrEmpty(currentName))
                TextSpan(
                  text: currentName,
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
            ],
          ),
          textScaleFactor: textScaleFactor,
          style: const TextStyle(fontSize: _buttonFontSize),
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

///
/// A text button.
///
class TecTextButton extends StatelessWidget {
  final String title;
  final String tooltip;
  final void Function() onTap;
  final double padding;

  const TecTextButton({
    Key key,
    this.title,
    this.tooltip,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(padding ?? 8.0),
          child: Text(
            title,
            textScaleFactor: textScaleFactorWith(context),
            style: TextStyle(fontSize: _buttonFontSize, color: Theme.of(context).accentColor),
          ),
        ),
      ),
    );
  }
}

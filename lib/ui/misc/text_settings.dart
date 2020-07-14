import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_util/tec_util.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../common/common.dart';

void showTextSettingsDialog(BuildContext context) {
  showTecModalPopup<void>(
    context: context,
    alignment: Alignment.bottomCenter,
    useRootNavigator: true,
    builder: (context) => SafeArea(child: TecPopupSheet(child: _TextSettings())),
  );
}

class _TextSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Fonts>(
      future: _loadFonts(),
      builder: (context, snapshot) {
        final fonts = snapshot.hasData ? snapshot.data : null;
        if (fonts != null) {
          return _TextSettingsUI(fonts: fonts);
        } else {
          final error = snapshot.hasError ? snapshot.error : null;
          final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
          final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
          return Container(
            color: backgroundColor,
            child: Center(
              child: error == null ? const LoadingIndicator() : Text(error.toString()),
            ),
          );
        }
      },
    );
  }
}

class _TextSettingsUI extends StatefulWidget {
  final _Fonts fonts;

  const _TextSettingsUI({Key key, @required this.fonts}) : super(key: key);

  @override
  _TextSettingsUIState createState() => _TextSettingsUIState();
}

class _TextSettingsUIState extends State<_TextSettingsUI> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    updateFromWidget();
  }

  @override
  void didUpdateWidget(_TextSettingsUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateFromWidget();
  }

  @override
  void dispose() {
    // Update the recent fonts list in prefs.
    var recentFonts = widget.fonts.recent
      ..remove(_currentFont)
      ..insert(0, _currentFont);
    recentFonts = recentFonts.take(100).toList();
    Prefs.shared.setStringList('_font_settings_recent', recentFonts);
    _scrollController.dispose();

    super.dispose();
  }

  String get _currentFont {
    final font = AppSettings.shared.contentFontName.value;
    return font.isEmpty ? _Fonts._systemDefault : font;
  }

  void updateFromWidget() {
    _fontType = widget.fonts.fontType;
    _sortAlphabetically = widget.fonts.sortAlphabetically;
    _fontNames = widget.fonts.filterBy(_fontType, alphabetically: _sortAlphabetically);
  }

  void _setFontType(String type) {
    if (mounted) {
      setState(() {
        _fontType = type;
        _fontNames = widget.fonts.filterBy(_fontType, alphabetically: _sortAlphabetically);
        _scrollController.jumpTo(0);
      });
    }
  }

  void _setSortType(String sortType) {
    if (mounted) {
      setState(() {
        _sortAlphabetically = sortType == 'alphabetically';
        _fontNames = widget.fonts.filterBy(_fontType, alphabetically: _sortAlphabetically);
        _scrollController.jumpTo(0);
      });
    }
  }

  String _fontType;
  bool _sortAlphabetically;
  List<String> _fontNames;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.grey[400] : Colors.grey[800];
    final fontSize =
        textScaleFactorWith(context, forAbsoluteFontSize: true, maxScaleFactor: 1) * 25;
    return Material(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<double>(
              stream: AppSettings.shared.contentTextScaleFactor.stream,
              builder: (c, snapshot) {
                final percent = (snapshot.hasData
                    ? snapshot.data
                    : AppSettings.shared.contentTextScaleFactor.value);
                //final fontSize = 20.0 * percent;
                //tec.dmPrint('fontSize: $fontSize');
                return IntrinsicHeight(
                  child: Slider.adaptive(
                    min: 0.75,
                    max: 2.0,
                    onChanged: AppSettings.shared.contentTextScaleFactor.add,
                    value: percent,
                  ),
                );
              },
            ),
            _PopupMenuButton(
              title: TecText.rich(
                TextSpan(children: [
                  const TextSpan(text: ' Font type: '),
                  TextSpan(text: _fontType, style: TextStyle(color: Theme.of(context).accentColor)),
                ], style: Theme.of(context).textTheme.headline6),
                maxScaleFactor: _maxTextScaleFactor,
              ),
              menuItems: const [
                'recently used',
                'sans-serif',
                'serif',
                'handwriting',
                'monospace',
                'display'
              ],
              type: _fontType,
              selectType: _setFontType,
            ),
            const SizedBox(height: 8),
            _PopupMenuButton(
              title: TecText.rich(
                TextSpan(children: [
                  const TextSpan(text: ' Sort: '),
                  TextSpan(
                      text: _sortAlphabetically ? 'alphabetically' : 'by popularity',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                ], style: Theme.of(context).textTheme.headline6),
                maxScaleFactor: _maxTextScaleFactor,
              ),
              menuItems: const ['by popularity', 'alphabetically'],
              type: _sortAlphabetically ? 'alphabetically' : 'by popularity',
              selectType: _setSortType,
            ),
            Container(
              height: fontSize * 2,
              //color: Colors.red,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _fontNames.length,
                itemBuilder: (context, index) {
                  final name = _fontNames[index];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      ' $name${index == _fontNames.length - 1 ? '' : ', '}',
                      style: name == _Fonts._systemDefault
                          ? _defaultTextStyle.merge(TextStyle(fontSize: fontSize, color: textColor))
                          : GoogleFonts.getFont(name, fontSize: fontSize, color: textColor),
                    ),
                    onPressed: () => AppSettings.shared.contentFontName
                        .add(name == _Fonts._systemDefault ? '' : name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _defaultTextStyle = TextStyle(
  inherit: false,
  //fontWeight: FontWeight.normal,
);

const _defaultMenuItemHeight = 36.0;
const _maxTextScaleFactor = 1.0;

class _PopupMenuButton extends StatelessWidget {
  final Widget title;
  final String type;
  final void Function(String type) selectType;
  final List<String> menuItems;

  const _PopupMenuButton({Key key, this.title, this.type, this.selectType, this.menuItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = menuItems
        .map<PopupMenuEntry<String>>((typeName) => PopupMenuItem<String>(
              height: _defaultMenuItemHeight,
              value: typeName,
              child: TecText(
                typeName,
                maxScaleFactor: _maxTextScaleFactor,
                style: TextStyle(
                    fontWeight: typeName == type ? FontWeight.bold : FontWeight.normal,
                    color: typeName == type
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87)),
              ),
            ))
        .toList();

    // return Theme(
    //   data: Theme.of(context).copyWith(
    //     textTheme: const TextTheme(subtitle1: TextStyle(textBaseline: TextBaseline.alphabetic)),
    //   ),
    //   child:
    return PopupMenuButton<String>(
      child: title,
      offset: const Offset(150, 0),
      onSelected: (value) {
        selectType?.call(value);
      },
      itemBuilder: (context) => items,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      //),
    );
  }
}

class _Fonts {
  final List<_Font> all;

  _Fonts(this.all) : assert(all != null) {
    _filtered = filterBy(fontType, alphabetically: sortAlphabetically, forceRebuild: true);
  }

  final recent =
      Prefs.shared.getStringList('_font_settings_recent', defaultValue: [_systemDefault]);

  /// Font type to filter by.
  String get fontType => _fontType;
  String _fontType =
      Prefs.shared.getString('_font_settings_filter_type', defaultValue: 'recently used');

  /// Alphabetically (== true) or by popularity (== false).
  bool get sortAlphabetically => _alphabetically;
  bool _alphabetically =
      Prefs.shared.getBool('_font_settings_sort_alphabetically', defaultValue: false);

  static const _all = 'all';
  static const _recentlyUsed = 'recently used';
  static const _systemDefault = 'System Default';

  var _filtered = <String>[];

  List<String> filterBy(String filter, {bool alphabetically = false, bool forceRebuild = false}) {
    if (!forceRebuild && _fontType == filter && _alphabetically == alphabetically) {
      return _filtered;
    }

    if (_fontType != filter) {
      _fontType = filter;
      Prefs.shared.setString('_font_settings_filter_type', _fontType);
    }

    if (_alphabetically != alphabetically) {
      _alphabetically = alphabetically;
      Prefs.shared.setBool('_font_settings_sort_alphabetically', _alphabetically);
    }

    if (_fontType == _all) {
      _filtered = all.map((e) => e.name).toList()..insert(0, _systemDefault);
    } else if (_fontType == _recentlyUsed) {
      _filtered = List.of(recent);
    } else {
      _filtered = all.where((e) => e.type == _fontType).map((e) => e.name).toList();
      if (_fontType == 'san-serif') _filtered.insert(0, _systemDefault);
    }

    if (alphabetically) _filtered.sort();

    return _filtered;
  }
}

class _Font {
  final String name;
  final String type;
  _Font(this.name, this.type);
}

/// Given a model (e.g. 'iPhone11,8'), returns the name (e.g. 'iPhone XR').
Future<_Fonts> _loadFonts() async {
  final fontNames = GoogleFonts.asMap().keys.toSet();

  final fonts = <_Font>[];
  try {
    const bundlePath = 'assets/fonts.json';
    final text = await rootBundle.loadString(bundlePath);
    if (text != null) {
      final json = tec.parseJsonSync(text);
      if (json != null) {
        final items = tec.as<List<dynamic>>(json['items']);
        for (final item in items) {
          if (item is List<dynamic> && item.length == 2) {
            final name = tec.as<String>(item.first);
            // Make sure the font is still available in GoogleFonts.
            if (fontNames.contains(name)) {
              final type = tec.as<String>(item.last);
              assert(type?.isNotEmpty ?? false);
              fonts.add(_Font(name, type));
            } else {
              tec.dmPrint('TextSettings loadFonts font $name is no longer available.');
            }
          }
        }
      }
    }
  }
  // ignore: avoid_catches_without_on_clauses
  catch (e) {
    tec.dmPrint('TextSettings loadFonts failed with error: ${e.toString()}');
  }

  //await Future.delayed(Duration(seconds: 5), () {});

  return _Fonts(fonts);
}

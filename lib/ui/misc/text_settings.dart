import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_util/tec_util.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/content_settings.dart';
import '../../models/const.dart';
import '../common/common.dart';

void showTextSettingsDialog(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    barrierColor: Colors.black12,
    builder: (context) => _TextSettings(),
  );
}

class _TextSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TecFutureBuilder<_Fonts>(
      futureBuilder: _loadFonts,
      builder: (context, fonts, error) {
        if (fonts != null) {
          return _TextSettingsUI(fonts: fonts);
        } else {
          return Container(
            height: 100,
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
    var currentFont = tec.Prefs.shared.getString(Const.prefContentFontName, defaultValue: '');
    if (currentFont.isEmpty) currentFont = _Fonts._systemDefault;
    var recentFonts = widget.fonts.recent
      ..remove(currentFont)
      ..insert(0, currentFont);
    recentFonts = recentFonts.take(100).toList();
    Prefs.shared.setStringList('_font_settings_recent', recentFonts);
    _scrollController.dispose();

    super.dispose();
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
        _sortAlphabetically = sortType == _strAlphabetically;
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
    final padding = 16 * textScaleFactorWith(context);
    final halfPad = (padding / 2.0).roundToDouble();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.grey[400] : Colors.grey[800];
    final buttonColor = isDarkTheme ? Colors.grey[800] : Colors.grey[200];
    final textScale = textScaleFactorWith(context, dampingFactor: 0.5, maxScaleFactor: 1);
    const fontSize = 25.0;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            child: Wrap(
              spacing: padding,
              runSpacing: padding,
              children: [
                TecEZPopupMenuButton(
                  title: 'Fonts',
                  padding: 0,
                  currentValue: _fontType,
                  onSelectValue: _setFontType,
                  menuItems: const [
                    _strRecentlyUsed,
                    _strSansSerif,
                    _strSerif,
                    _strHandwriting,
                    _strMonospace,
                    _strDisplay
                  ],
                ),
                TecEZPopupMenuButton(
                  title: 'Sort',
                  padding: 0,
                  currentValue: _sortAlphabetically ? _strAlphabetically : _strByPopularity,
                  onSelectValue: _setSortType,
                  menuItems: const [_strByPopularity, _strAlphabetically],
                ),
              ],
            ),
          ),
          Container(
            height: fontSize * textScale * 2,
            // color: Colors.red,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _fontNames.length,
              itemBuilder: (context, index) {
                final name = _fontNames[index];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: padding),
                    CupertinoButton(
                      color: buttonColor,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Builder(builder: (context) {
                        final embedded = name.startsWith('embedded_');
                        final showName = (embedded) ? name.substring(9) : name;
                        return Text(
                          '$showName',
                          textScaleFactor: textScale,
                          style: name == _Fonts._systemDefault
                              ? TextStyle(fontSize: fontSize, color: textColor)
                              : embedded
                                  ? TextStyle(
                                      fontFamily: showName, fontSize: fontSize, color: textColor)
                                  : GoogleFonts.getFont(name, fontSize: fontSize, color: textColor),
                        );
                      }),
                      onPressed: () {
                        final settings = context.tbloc<ContentSettingsBloc>().state;
                        context.tbloc<ContentSettingsBloc>().updateWith(
                            settings.copyWith(fontName: name == _Fonts._systemDefault ? '' : name));
                      },
                    )
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(halfPad, halfPad, halfPad, 0),
            child: BlocBuilder<ContentSettingsBloc, ContentSettings>(
              builder: (context, settings) {
                return IntrinsicHeight(
                  child: Slider.adaptive(
                    value: settings.textScaleFactor,
                    min: 0.75,
                    max: 3.0,
                    onChanged: (newValue) {
                      context
                          .tbloc<ContentSettingsBloc>()
                          .updateWith(settings.copyWith(textScaleFactor: newValue));
                    },
                    activeColor: Theme.of(context).accentColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

const _strAlphabetically = 'alphabetically';
const _strByPopularity = 'by popularity';

const _strRecentlyUsed = 'recently used';
const _strSansSerif = 'sans-serif';
const _strSerif = 'serif';
const _strHandwriting = 'handwriting';
const _strMonospace = 'monospace';
const _strDisplay = 'display';

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
      Prefs.shared.getString('_font_settings_filter_type', defaultValue: _strSansSerif);

  /// Alphabetically (== true) or by popularity (== false).
  bool get sortAlphabetically => _alphabetically;
  bool _alphabetically =
      Prefs.shared.getBool('_font_settings_sort_alphabetically', defaultValue: false);

  static const _all = 'all';
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
    } else if (_fontType == _strRecentlyUsed) {
      _filtered = List.of(recent);
    } else {
      _filtered = all.where((e) => e.type == _fontType).map((e) => e.name).toList();
      if (_fontType == _strSansSerif) _filtered.insert(0, _systemDefault);
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

Future<_Fonts> _loadFonts() async {
  final fontNames = GoogleFonts.asMap().keys.toSet();

  final fonts = <_Font>[];
  try {
    const bundlePath = 'assets/fonts.json';
    final text = await rootBundle.loadString(bundlePath);
    if (text != null) {
      final json = tec.parseJsonSync(text);
      if (json != null) {
        // add embedded fonts
        final embeddedFonts = tec.as<List<dynamic>>(json['embedded']);
        for (final item in embeddedFonts) {
          if (item is List<dynamic> && item.length == 2) {
            final name = tec.as<String>(item.first);
            final type = tec.as<String>(item.last);
            assert(type?.isNotEmpty ?? false);
            fonts.add(_Font('embedded_$name', type));
          }
        }

        // add google fonts
        final googleFonts = tec.as<List<dynamic>>(json['google']);
        for (final item in googleFonts) {
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

  // await Future.delayed(Duration(seconds: 2), () {});

  return _Fonts(fonts);
}

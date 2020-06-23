import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/app_settings.dart';
import '../common/common.dart';

void showTextSettingsDialog(BuildContext context) {
  showTecModalPopup<void>(
    context: context,
    alignment: Alignment.topLeft,
    useRootNavigator: true,
    builder: (context) => TecPopupSheet(child: _TextSettings()),
  );
}

class _TextSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final styles = GoogleFonts.asMap();
    final fontNames = styles.keys.toList()..sort();
    return StreamBuilder<double>(
      stream: AppSettings.shared.contentTextScaleFactor.stream,
      builder: (c, snapshot) {
        final percent =
            (snapshot.hasData ? snapshot.data : AppSettings.shared.contentTextScaleFactor.value);
        final fontSize = 20.0 * percent;
        final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkTheme ? Colors.grey[400] : Colors.grey[800];
        //tec.dmPrint('fontSize: $fontSize');
        return Material(
          child: Column(
            children: [
              IntrinsicHeight(
                child: Slider.adaptive(
                  min: 0.75,
                  max: 2.0,
                  onChanged: AppSettings.shared.contentTextScaleFactor.add,
                  value: percent,
                ),
              ),
              SizedBox(
                height: fontSize * 1.75,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fontNames.length,
                  itemBuilder: (context, index) {
                    final name = fontNames[index];
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(' $name, ',
                          style: styles[name](fontSize: fontSize, color: textColor)),
                      onPressed: () => AppSettings.shared.contentFontName.add(name),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

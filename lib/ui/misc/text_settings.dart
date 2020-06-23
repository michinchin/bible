import 'package:flutter/material.dart';

import '../../models/app_settings.dart';
import '../common/common.dart';

void showTextSettingsDialog(BuildContext context) {
  showTecModalPopup<void>(
    context: context,
    alignment: Alignment.topLeft,
    useRootNavigator: true,
    builder: (context) => TecPopupSheet(child: _FontSizeSlider()),
  );
}

class _FontSizeSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: AppSettings.shared.contentTextScaleFactor.stream,
      builder: (c, snapshot) {
        final fontSize =
            (snapshot.hasData ? snapshot.data : AppSettings.shared.contentTextScaleFactor.value);
        return Material(
          child: IntrinsicHeight(
            child: Slider.adaptive(
              min: 0.75,
              max: 2.0,
              onChanged: AppSettings.shared.contentTextScaleFactor.add,
              value: fontSize,
            ),
          ),
        );
      },
    );
  }
}

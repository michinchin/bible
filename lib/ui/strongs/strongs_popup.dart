import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_bloc/tec_bloc.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/app_settings.dart';
import '../common/common.dart';
import '../volume/volume_view_data_bloc.dart';
import 'strongs_build_helper.dart';

Future<void> showStrongsPopup({
  @required BuildContext context,
  @required String title,
  @required String strongsId,
  EdgeInsetsGeometry insets,
}) {
  if (strongsId?.isEmpty ?? true) return Future.value();

  final volumeId = context.tbloc<VolumeViewDataBloc>().state.asVolumeViewData.volumeId;
  final bible = VolumesRepository.shared.volumeWithId(volumeId)?.assocBible();
  final originalContext = context;

  final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) {
        final helper = StrongsBuildHelper();
        return BlocProvider.value(
          value: originalContext.tbloc<VolumeViewDataBloc>(),
          child: Scaffold(
            backgroundColor: isDarkTheme ? Colors.black : Colors.white,
            appBar: MinHeightAppBar(
              appBar: AppBar(
                  leading: const CloseButton(), title: isNullOrEmpty(title) ? null : Text(title)),
            ),
            body: TecFutureBuilder<ErrorOrValue<String>>(
              futureBuilder: () => bible.strongsHtmlWith(strongsId),
              builder: (context, result, error) {
                final htmlFragment = result?.value;
                if (isNotNullOrEmpty(htmlFragment)) {
                  final fullHtml = strongsHtmlWithFragment(htmlFragment,
                      darkTheme: isDarkTheme,
                      fontSizePercent: (90 * contentTextScaleFactorWith(context)).toInt());
                  return SingleChildScrollView(
                    child: TecHtml(
                      fullHtml,
                      baseUrl: bible.baseUrl,
                      selectable: false,
                      tagHtmlElement: helper.tagHtmlElement,
                      spanForText: (text, style, tag) =>
                          strongsSpanForText(context, text, style, tag),
                    ),
                  );
                } else {
                  return Center(
                    child: error == null ? const LoadingIndicator() : Text(error.toString()),
                  );
                }
              },
            ),
          ),
        );
      },
    ),
  );
}

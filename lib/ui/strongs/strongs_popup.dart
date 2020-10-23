import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
// import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_data/volume_view_data.dart';
import '../common/common.dart';
//import '../common/tec_modal_popup.dart';

// ignore_for_file: cascade_invocations

Future<void> showStrongsPopup({
  @required BuildContext context,
  @required String title,
  @required String html,
  EdgeInsetsGeometry insets,
}) {
  if (html?.isEmpty ?? true) return Future.value();

  final volumeId = context.bloc<ViewDataBloc>().state.asChapterViewData.volumeId;
  final bible = VolumesRepository.shared.volumeWithId(volumeId)?.assocBible;
  final originalContext = context;
  final fullHtml = _htmlWithFragment(html);

  final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider.value(
        value: originalContext.bloc<ViewDataBloc>(),
        child: Scaffold(
          appBar: MinHeightAppBar(
            appBar: AppBar(
                leading: const CloseButton(), title: tec.isNullOrEmpty(title) ? null : Text(title)),
          ),
          body: Container(
            color: isDarkTheme ? Colors.black : Colors.white,
            child: SingleChildScrollView(
              child: TecHtml(fullHtml, baseUrl: bible.baseUrl, selectable: false),
            ),
          ),
        ),
      ),
    ),
  );
}

String _htmlWithFragment(
  String htmlFragment, {
  bool darkTheme = false,
  int fontSizePercent = 100,
  String vendorFolder,
}) {
  final s = StringBuffer()
    ..write('<!DOCTYPE html>\n'
        '<head>\n'
        '<meta charset="utf-8" />\n'
        '<meta name="viewport" content="width=device-width, '
        'initial-scale=1, maximum-scale=1, user-scalable=no" />\n'
        '<style> html { -webkit-text-size-adjust: none; } </style>\n');

  var bibleVendorCSS = '';
  if (vendorFolder != null) {
    bibleVendorCSS = vendorFolder;
    if (!vendorFolder.endsWith('/')) bibleVendorCSS += '/';
  }
  bibleVendorCSS += 'bible_vendor.css';
  s.write('<link rel="stylesheet" type="text/css" href="$bibleVendorCSS" />\n');

  s.write('<link rel="stylesheet" type="text/css" href="strongs.css" />\n');

  if (darkTheme) {
    s.write('<link rel="stylesheet" type="text/css" href="strongs_night.css" />\n');
  }

  s.write('<title></title>\n</head>\n\n');

  final color = (darkTheme ? 'black' : 'white');

  final fontSize = (fontSizePercent ?? 100);
  s.write('<body style="background-color: $color; '
      // 'margin-left: $marginLeft; margin-right: $marginRight; '
      // 'padding-top: $marginTop; padding-bottom: $marginBottom; '
      'font-size: $fontSize%;">\n');

  s.write('$htmlFragment\n\n');

  s.write('</body>\n</html>\n');

  return s.toString();
}

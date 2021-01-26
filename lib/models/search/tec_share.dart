import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/reference_ext.dart';

class TecShare {
  static Future<String> shareLink(Reference ref) async {
    var shortUrl = '';
    final bookName = ref.label().split(' ')[0];

    final params = <String, dynamic>{
      'volume': '${ref.volume}',
      'resid':
          '$bookName+${ref.chapter}:${ref.verse == ref.endVerse ? '${ref.verse}' : '${ref.verse}-${ref.endVerse}'}',
    };

    final url =
        Uri(scheme: 'https', host: 'tecartabible.com', path: '/share', queryParameters: params)
            .toString();

    shortUrl = await tec.shortenUrl(url);

    // tec.dmPrint('Share url: $url\nShort url: $shortUrl');
    return shortUrl.isNotEmpty ? '\n$shortUrl' : '';
  }

  static void copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text)).then((x) {
      TecToast.show(context, 'Successfully Copied!');
    });
  }

  static void share(String text) => Share.share(text);

  static Future<void> shareWithLink(String text, Reference ref) async =>
      Share.share('$text${await shareLink(ref)}');

  static Future<void> copyWithLink(BuildContext context, String text, Reference ref) async =>
      copy(context, '$text${await shareLink(ref)}');
}

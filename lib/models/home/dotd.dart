import 'package:flutter/foundation.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../const.dart';
import '../string_utils.dart';

///
/// DevoRes - Devotional from devo of the days
///
@immutable
class Dotd {
  final int productId;
  final int resourceId;
  final String title;
  final String intro;
  final String imageName;
  final String commands;
  final HtmlCommand command;
  final int year;
  final int ordinalDay;

  const Dotd(
      {@required this.title,
      @required this.intro,
      @required this.commands,
      @required this.imageName,
      @required this.productId,
      @required this.resourceId,
      this.command,
      this.year,
      this.ordinalDay});

  /// Returns a copy of this object with optional tweaks.
  Dotd copyWith(
      {String title,
      String intro,
      String imageName,
      String commands,
      int productId,
      int resourceId,
      HtmlCommand command,
      int year,
      int ordinalDay}) {
    return Dotd(
        title: title ?? this.title,
        intro: intro ?? this.intro,
        commands: commands ?? this.commands,
        imageName: imageName ?? this.imageName,
        productId: productId ?? this.productId,
        resourceId: resourceId ?? this.resourceId,
        command: command ?? this.command,
        year: year ?? this.year,
        ordinalDay: ordinalDay ?? this.ordinalDay);
  }

  /// Returns a new dotd from parsing devo-of-the-day JSON.
  factory Dotd.fromDotdJson(List<dynamic> json) {
    if (json.length >= 5 && json[1] is List<dynamic> && json[1].length == 2) {
      final productId = as<int>(json[1][0]);
      final resourceId = as<int>(json[1][1]);
      final imageName = as<String>(json[2]);
      final commands = as<String>(json[3]);
      final title = as<String>(json[4]);
      final intro = as<String>(json[5]);
      return Dotd(
          title: title,
          intro: intro,
          imageName: imageName,
          commands: commands,
          productId: productId,
          resourceId: resourceId);
    }
    return null;
  }

  /// Returns the hero tag for the image.
  String get heroTagForImage => '$hashCode-$imageName';

  /// Returns image url
  String get imageUrl => '$cloudFrontStreamUrl/votd/$imageName';

  Volume get volume => VolumesRepository.shared.volumeWithId(productId);

  Future<String> shortLink() async {
    String url;
    if (imageName.isNotEmpty) {
      final image = '${imageName.split('.')[0]}.html';
      url = '${Const.tecartaBibleLink}$image?volume=$productId&resid=$resourceId';
    } else {
      url = '${Const.tecartaBibleLink}share/$productId/$resourceId';
    }
    return shortenUrl(url);
  }

  Future<String> shareText() async => 'Devotional of the Day\n$title\n${await shortLink()}';

  /// Returns html, from remote or local
  Future<String> html(TecEnv env) async {
    // TODO(ron): update to new devo format and refresh devo info...
    final item = await httpRequestMap('$cloudFrontStreamUrl/$productId/items/$resourceId.json.gz');
    if (item.containsKey('filename')) {
      final html = await httpRequestString(
          '$cloudFrontStreamUrl/$productId/data/${item['filename']}');
      return formattedHtml(html, env);
    }

    /* this code worked when old devos were in the products list
    final res = await volume.resourceWithId(resourceId);
    if (res != null && res.error == null) {
      String html;
      final fileUrl = volume.fileUrlForResource(res.value);
      if (fileUrl.startsWith('http')) {
        html = await httpRequestString(fileUrl);
      } else {
        html = getTextFromFile(fileUrl);
      }
      return formattedHtml(html, env);
    }
    */
    return '';
  }

  String formattedHtml(String html, TecEnv env) {
    if (command != null) {
      var formattedHtml = html;
      for (final each in command.commands) {
        if (as<String>(each[0]) == 'html.remove') {
          if (as<List>(each).length == 3) {
            final startsWith = as<String>(each[1]);
            final endsWith = as<String>(each[2]);
            while (formattedHtml.contains(startsWith)) {
              final range =
                  formattedHtml.rangeOfDelimitedSubstring(delimiters: [startsWith, endsWith]);
              if (range != null) {
                formattedHtml = formattedHtml.replaceRange(range.start, range.end, '');
              }
            }
          }
        }
      }
      return _stylizedHtml(formattedHtml, env);
    }
    return _stylizedHtml(html, env);
  }

  String _stylizedHtml(String html, TecEnv env) {
    final s = StringBuffer();
      // ..write('<html lang="${volume.language}">\n'
      //     '<head>\n'
      //     '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n'
      //     '<meta name="viewport" content="initial-scale = 1.0,maximum-scale = 1.0">\n'
      //     '<style> html { -webkit-text-size-adjust: none; } </style>')
      // ..write('<link rel="stylesheet" type="text/css" href="bible_vendor.css" />\n')
      // ..write('<link rel="stylesheet" type="text/css" href="strongs.css" />\n')
      // ..write('</head>');

    if (html.isNotEmpty) {
      if (env.darkMode) {
        return html.replaceFirst('</head>',
            '<style> html { -webkit-text-size-adjust: none; } body { background-color: #000000; color: #bbbbbb; } </style></head>');
      } else {
        return html.replaceFirst(
            '</head>', '<style> html { -webkit-text-size-adjust: none; } </style></head>');
      }
    }
    s.write('$html\n\n');

    return s.toString();
  }

  /// Asynchronously returns a new DevoRes from a JSON list.
  factory Dotd.fromJson(List<dynamic> list) {
    final productId = as<int>(list[1][0]);
    final resourceId = as<int>(list[1][1]);
    final imageName = as<String>(list[2]);
    final commands = as<String>(list[3]);
    final title = as<String>(list[4]);
    final intro = as<String>(list[5]);

    if (isNotNullOrZero(productId) &&
        isNotNullOrZero(resourceId) &&
        isNotNullOrEmpty(imageName) &&
        isNotNullOrEmpty(commands) &&
        isNotNullOrEmpty(title) &&
        isNotNullOrEmpty(intro)) {
      return Dotd(
        title: title,
        intro: intro,
        commands: commands,
        productId: productId,
        resourceId: resourceId,
        imageName: imageName,
      );
    }
    return null;
  }
}

class HtmlCommand {
  List commands;
  HtmlCommand(this.commands);

  factory HtmlCommand.fromJson(List<dynamic> list) {
    if (list[0] == 'commands') {
      final commands = as<List>(list[1]);
      return HtmlCommand(commands);
    }
    return null;
  }
}

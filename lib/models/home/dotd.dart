import 'package:flutter/foundation.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart' as tec;
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
      final productId = tec.as<int>(json[1][0]);
      final resourceId = tec.as<int>(json[1][1]);
      final imageName = tec.as<String>(json[2]);
      final commands = tec.as<String>(json[3]);
      final title = tec.as<String>(json[4]);
      final intro = tec.as<String>(json[5]);
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
  String get imageUrl => '${tec.streamUrl}/votd/$imageName';

  Volume get volume => VolumesRepository.shared.volumeWithId(productId);

  Future<String> shortLink() async {
    String url;
    if (imageName.isNotEmpty) {
      final image = '${imageName.split('.')[0]}.html';
      url = '${Const.tecartaBibleLink}$image?volume=$productId&resid=$resourceId';
    } else {
      url = '${Const.tecartaBibleLink}share/$productId/$resourceId';
    }
    return tec.shortenUrl(url);
  }

  Future<String> shareText() async => 'Devotional of the Day\n$title\n${await shortLink()}';

  /// Returns html, from remote or local
  Future<String> html(TecEnv env) async {
    final res = await volume.resourceWithId(resourceId);
    if (res != null && res.error == null) {
      String html;
      final fileUrl = volume.fileUrlForResource(res.value);
      if (fileUrl.startsWith('http')) {
        html = await tec.utf8StringFromHttpRequest(tec.HttpRequestType.get, url: fileUrl);
      } else {
        html = tec.getTextFromFile(fileUrl);
      }
      return formattedHtml(html, env);
    }
    return '';
  }

  String formattedHtml(String html, TecEnv env) {
    if (command != null) {
      var formattedHtml = html;
      for (final each in command.commands) {
        if (tec.as<String>(each[0]) == 'html.remove') {
          if (tec.as<List>(each).length == 3) {
            final startsWith = tec.as<String>(each[1]);
            final endsWith = tec.as<String>(each[2]);
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
    if (html.isNotEmpty) {
      if (env.darkMode) {
        return html.replaceFirst('</head>',
            '<style> html { -webkit-text-size-adjust: none; } body { background-color: #000000; color: #bbbbbb; } </style></head>');
      } else {
        return html.replaceFirst(
            '</head>', '<style> html { -webkit-text-size-adjust: none; } </style></head>');
      }
    }
    return html;
  }

  /// Asynchronously returns a new DevoRes from a JSON list.
  factory Dotd.fromJson(List<dynamic> list) {
    final productId = tec.as<int>(list[1][0]);
    final resourceId = tec.as<int>(list[1][1]);
    final imageName = tec.as<String>(list[2]);
    final commands = tec.as<String>(list[3]);
    final title = tec.as<String>(list[4]);
    final intro = tec.as<String>(list[5]);

    if (tec.isNotNullOrZero(productId) &&
        tec.isNotNullOrZero(resourceId) &&
        tec.isNotNullOrEmpty(imageName) &&
        tec.isNotNullOrEmpty(commands) &&
        tec.isNotNullOrEmpty(title) &&
        tec.isNotNullOrEmpty(intro)) {
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
      final commands = tec.as<List>(list[1]);
      return HtmlCommand(commands);
    }
    return null;
  }
}

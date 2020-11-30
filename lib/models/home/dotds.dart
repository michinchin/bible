import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'dotd.dart';

/// Devotional-of-the-day data.
@immutable
class Dotds {
  Dotds({
    @required List<Dotd> data,
    @required Map<int, Dotd> specials,
    @required Map<String, HtmlCommand> commands,
  })  : assert(data != null),
        assert(specials != null),
        assert(commands != null),
        specials = Map<int, Dotd>.unmodifiable(specials),
        commands = Map<String, HtmlCommand>.unmodifiable(commands),
        data = List<Dotd>.unmodifiable(data);

  ///
  /// Ordered list of devotionals for the whole year.
  ///
  final List<Dotd> data;
  final Map<int, Dotd> specials;
  final Map<String, HtmlCommand> commands;

  /// Returns a Dotd object from parsing the given JSON.
  factory Dotds.fromJson(Map<String, dynamic> json) {
    String formatCommandString(String commands) {
      final c = commands.replaceAll(RegExp('[{}]+'), '');
      var command = '';
      if (c.contains('shared')) {
        final index = c.indexOf('.');
        command = c.substring(index + 1, c.length);
      }
      return command;
    }

    final data = tec.as<List<dynamic>>(json['data']);
    final specials = tec.as<Map<String, dynamic>>(json['specials']);
    final commands = tec.as<Map<String, dynamic>>(json['shared']);

    // commands
    final commandMap = <String, HtmlCommand>{};
    for (final c in commands.keys) {
      final command = tec.as<List<dynamic>>(commands[c]);
      if (command != null) {
        commandMap[c] = HtmlCommand.fromJson(command);
      }
    }

    // data
    final devos = <Dotd>[];
    for (final d in data) {
      if (d is List<dynamic>) {
        final devo = Dotd.fromJson(d);
        if (devo != null) {
          final c = formatCommandString(devo.commands);
          final command = commandMap[c];
          if (command != null) {
            devos.add(devo.copyWith(command: command));
          } else {
            devos.add(devo);
          }
        }
      }
    }

    // specials
    final sDevos = <int, Dotd>{};
    for (final s in specials.keys) {
      final special = tec.as<List<dynamic>>(specials[s]);
      sDevos[int.parse(s)] = Dotd.fromJson(special);
    }

    return Dotds(data: devos, specials: sDevos, commands: commandMap);
  }

  /// Fetches the devotional-of-the-day data.
  static Future<Dotds> fetch({int year}) async {
    final y = year ?? DateTime.now().year;
    final fileName = 'devo-$y.json';
    final hostAndPath = '${tec.streamUrl}/home';
    final json = await TecCache.shared.jsonFromUrl(
        url: '$hostAndPath/$fileName',
        cachedPath: '${hostAndPath.replaceAll('https://', '')}/$fileName',
        bundlePath: 'assets/$fileName');
    if (json != null) {
      return Dotds.fromJson(json);
    } else {
      return Dotds(data: const [], specials: const {}, commands: const {});
    }
  }

  /// Returns the devotional for the given date.
  Dotd devoForDate(DateTime date) {
    if (date != null && tec.isNotNullOrEmpty(data)) {
      final i = indexForDate(date);
      if (specials.containsKey(i + 1)) {
        return specials[i + 1];
      }
      return data[i].copyWith(year: date.year, ordinalDay: i);
    }
    return null;
  }

  /// Returns the index into `data` for the given date.
  int indexForDate(DateTime date) {
    if (date != null) {
      return tec.indexForDay(tec.dayOfTheYear(date), year: date.year, length: data.length);
    }
    return -1;
  }

  /// Returns the devotional with the given product ID and resource ID,
  /// or null if none.
  Dotd findDevoWith({@required int productId, @required int resourceId}) =>
      // ignore: avoid_bool_literals_in_conditional_expressions
      data?.firstWhere((devo) => (devo.productId == productId && devo.resourceId == resourceId),
          orElse: () => null);
}

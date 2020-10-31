import 'package:flutter/foundation.dart';
import 'package:tec_util/tec_util.dart' as tec;

class Day {
  int bitValue;
  int bitField;
  final int dayValue;
  bool isSelected;
  String shortName;
  String longName;

  Day({@required this.dayValue, this.bitField = tec.everyDay}) {
    bitValue = tec.bitValueOfWeekday(dayValue);
    shortName = tec.shortNameOfWeekday(dayValue);
    longName = tec.nameOfWeekday(dayValue);
    isSelected = tec.isWeekdayInBitField(dayValue, bitField);
  }
}

class Week {
  List<Day> days;
  int bitField;

  Week({this.bitField = tec.everyDay}) {
    days = [
      Day(dayValue: DateTime.sunday, bitField: bitField),
      Day(dayValue: DateTime.monday, bitField: bitField),
      Day(dayValue: DateTime.tuesday, bitField: bitField),
      Day(dayValue: DateTime.wednesday, bitField: bitField),
      Day(dayValue: DateTime.thursday, bitField: bitField),
      Day(dayValue: DateTime.friday, bitField: bitField),
      Day(dayValue: DateTime.saturday, bitField: bitField),
    ];
  }

  int get currentBitfield => bitField;

  /// From list of [days], calculate bit field based on selection
  int _calculateBitField() {
    final selectedDays = days.where((d) => d.isSelected).toList();
    final weekdays = <int>[];
    for (final d in selectedDays) {
      weekdays.add(d.dayValue);
    }
    return tec.bitFieldFromWeekdayList(weekdays);
  }

  /// Given [bitField] (i.e. everyday=127, weekdays, etc), update [days]'s
  /// [bitField] to match
  void _updateWithBitField(int bitField) {
    days = days.map((d) {
      d.bitField = bitField;
      return d;
    }).toList();
  }

  /// Grab bit field and update [days] and [bitField] to match
  void update() {
    final bitField = _calculateBitField();
    _updateWithBitField(bitField);
    this.bitField = bitField;
  }
}

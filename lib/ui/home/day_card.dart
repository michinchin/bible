import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:tec_util/tec_util.dart' as tec;

class DayCard extends StatelessWidget {
  final DateTime date;
  final String title;
  final String imageUrl;
  final String body;
  final VoidCallback onTap;
  const DayCard(
      {@required this.date,
      @required this.title,
      @required this.imageUrl,
      @required this.onTap,
      this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: TecCard(
          onTap: onTap,
          color: Theme.of(context).cardColor,
          builder: (c) => Row(children: [
                TecImage(
                  width: 100,
                  height: double.infinity,
                  url: imageUrl,
                ),
                Expanded(child: Text('${tec.shortDate(date)}:\n$title'))
              ])),
    );
  }
}

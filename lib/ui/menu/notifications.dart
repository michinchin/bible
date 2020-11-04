import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/notifications/notification_bloc.dart';
import '../../models/notifications/days_of_week.dart';
import '../../models/notifications/local_notification.dart';

void showNotifications(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (c) =>
            BlocProvider.value(value: NotificationBloc.shared, child: NotificationsView())));

class NotificationsView extends StatelessWidget {
  // final fakeNotifications = <LocalNotification>[
  //   LocalNotification.blank().copyWith(title: 'verse of the day'),
  //   LocalNotification.blank().copyWith(title: 'devo of the day'),
  //   LocalNotification.blank().copyWith(title: 'scripture break'),
  // ];
  @override
  Widget build(BuildContext context) {
    return TecScaffoldWrapper(
        child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final n = state.notifications ?? [];
          return ListView.builder(
              itemCount: n.length, itemBuilder: (c, i) => _NotificationTile(n[i]));
        },
      ),
    ));
  }
}

class _NotificationTile extends StatelessWidget {
  LocalNotification notification;
  _NotificationTile(this.notification);
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: TecText.rich(TextSpan(children: [
        TextSpan(
            text: '${tec.hourMinuteDescription(notification.time)}\n',
            style: Theme.of(context).textTheme.headline4),
        TextSpan(text: '${notification.title}\n'),
        TextSpan(text: tec.shortNamesOfWeekdays(notification.week.bitField)),
      ])),
      children: [
        Row(
          children: [
            for (final weekday in Week(bitField: tec.everyDay).days)
              ButtonTheme(
                minWidth: 40,
                child: OutlineButton(
                    shape: const CircleBorder(),
                    onPressed: () {},
                    child: Text(weekday.shortName[0])),
              )
          ],
        )
      ],
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: Switch.adaptive(value: true, onChanged: (_) {})),
          const Spacer(),
          const Expanded(child: Icon(Icons.keyboard_arrow_down))
        ],
      ),
    );
  }
}

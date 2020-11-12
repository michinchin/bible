import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/notifications/notifications_model.dart';

Future<void> showNotifications(BuildContext context) async {
  final allowed = await Notifications.shared?.requestPermissions(context) ?? false;
  if (allowed) {
    NotificationBloc.init(NotificationsModel());
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (c) =>
            BlocProvider.value(value: NotificationBloc.shared, child: NotificationsView())));
  }
}

class NotificationsView extends StatefulWidget {
  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<LocalNotification> initialNotifications;
  @override
  void initState() {
    initialNotifications =
        List<LocalNotification>.from(NotificationBloc.shared.state.notifications);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TecScaffoldWrapper(
        child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Notifications'),
        leading: BackButton(
          onPressed: () async {
            const le = ListEquality<LocalNotification>();
            if (!le.equals(initialNotifications, NotificationBloc.shared.state.notifications)) {
              final update = NotificationBloc.shared
                  .updateNotifications(NotificationBloc.shared.state.notifications);
              await tecShowProgressDlg(
                  context: context, future: update, title: 'Saving Notifications');
            }
            await Navigator.of(context).maybePop();
          },
        ),
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

class _NotificationTile extends StatefulWidget {
  final LocalNotification notification;
  const _NotificationTile(this.notification);

  @override
  __NotificationTileState createState() => __NotificationTileState();
}

class __NotificationTileState extends State<_NotificationTile> {
  bool _isExpanded;

  @override
  void initState() {
    _isExpanded = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (b) => setState(() => _isExpanded = b),
      title: TecText.rich(
        TextSpan(children: [
          WidgetSpan(
            child: FlatButton(
              padding: EdgeInsets.zero,
              minWidth: double.infinity,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () async {
                final selectedTime = await showTimePicker(
                    context: context,
                    builder: (context, child) {
                      return TimePickerTheme(
                        data: TimePickerTheme.of(context).copyWith(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: child,
                      );
                    },
                    initialTime: TimeOfDay.fromDateTime(widget.notification.time));
                if (selectedTime != null) {
                  context.tbloc<NotificationBloc>().update(
                      widget.notification,
                      widget.notification
                          .copyWith(time: widget.notification.time.applied(selectedTime)));
                }
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${tec.hourMinuteDescription(widget.notification.time)}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
          ),
          TextSpan(text: '${NotificationConsts.titles[widget.notification.type]}\n'),
          TextSpan(text: tec.shortNamesOfWeekdays(widget.notification.week.bitField)),
        ]),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final day in Week(bitField: tec.everyDay).days)
                Flexible(
                  child: ButtonTheme(
                    minWidth: 40,
                    child: OutlineButton(
                        visualDensity: VisualDensity.comfortable,
                        shape: CircleBorder(
                            side: BorderSide(
                                color: tec
                                        .weekdayListFromBitField(widget.notification.week.bitField)
                                        .contains(day.dayValue)
                                    ? Theme.of(context).accentColor
                                    : Theme.of(context).textColor)),
                        onPressed: () {
                          final i = widget.notification.week.days
                              .indexWhere((d) => d.dayValue == day.dayValue);
                          widget.notification.week.toggleDay(widget.notification.week.days[i]);
                          context.tbloc<NotificationBloc>().update(
                              widget.notification,
                              widget.notification.copyWith(
                                  week: Week(bitField: widget.notification.week.bitField)));
                        },
                        textColor: tec
                                .weekdayListFromBitField(widget.notification.week.bitField)
                                .contains(day.dayValue)
                            ? Theme.of(context).accentColor
                            : Theme.of(context).textColor,
                        child: Text(day.shortName[0])),
                  ),
                )
            ],
          ),
        )
      ],
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Switch.adaptive(
                  value: widget.notification.enabled,
                  onChanged: (b) {
                    if (b != widget.notification.enabled) {
                      context
                          .tbloc<NotificationBloc>()
                          .update(widget.notification, widget.notification.copyWith(enabled: b));
                    }
                  })),
          const Spacer(),
          Expanded(child: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down))
        ],
      ),
    );
  }
}

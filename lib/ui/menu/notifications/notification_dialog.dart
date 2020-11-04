import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // backgroundColor: devoColors[1].withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        'Notifications',
        textAlign: TextAlign.center,
        maxLines: 1,
        style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 20.0),
      ),
      content: const Text(
        'Would you like to receive notifications?',
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('No'),
          onPressed: () async {
            Navigator.of(context).pop(false);
          },
        ),
        FlatButton(
          child: const Text('Yes'),
          onPressed: () async {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

class NotificationPermDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Please give notification '
          'permissions through settings'
          ' to access page'),
      actions: <Widget>[
        FlatButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

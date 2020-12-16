import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateNoteFolder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('Select types to search'),
          ),
          FlatButton(
            child: const Text('DONE'),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}
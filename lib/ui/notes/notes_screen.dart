import 'package:flutter/material.dart';

import '../../translations.dart';

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //centerTitle: false,
        title: Text('Notes'.i18n),
      ),
      body: Container(),
    );
  }
}

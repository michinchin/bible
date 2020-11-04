import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/home/votd.dart';
import '../common/common.dart';

void showHome(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _HomeScreen(),
    ),
  );
}

class _HomeScreen extends StatefulWidget {
  @override
  __HomeScreenState createState() => __HomeScreenState();
}

class __HomeScreenState extends State<_HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: FutureBuilder<VOTD>(
        future: VOTD.fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                TecCard(
                  builder: (c) => Stack(alignment: Alignment.center, children: [
                    TecImage(
                      url: snapshot.data.url,
                      colorBlendMode: BlendMode.softLight,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white24,
                    ),
                  ]),
                ),
                Text('VOTD: ${snapshot.data.refs}')
              ],
            );
          }
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }
}

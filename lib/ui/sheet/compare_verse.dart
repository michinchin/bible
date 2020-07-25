import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../../models/compare_results.dart';

class CompareVerseScreen extends StatelessWidget {
  final String title;
  final CompareResults results;
  const CompareVerseScreen({this.results, this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        textTheme: Theme.of(context).textTheme,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(title),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
          itemCount: results.data.length,
          itemBuilder: (c, i) => ListTile(
                title: Text(results.data[i].a),
                subtitle: Text(results.data[i].text),
                trailing: IconButton(
                  iconSize: 20,
                  icon: const Icon(FeatherIcons.share2),
                  onPressed: () =>
                      Share.share('$title ${results.data[i].a}\n${results.data[i].text}'),
                ),
              )),
    );
  }
}

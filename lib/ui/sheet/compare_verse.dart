import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/prefs_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/pref_item.dart';
import '../../models/reference_ext.dart';
import '../../models/search/compare_results.dart';
import '../common/common.dart';

Future<int> showCompareSheet(BuildContext c, Reference ref) async {
  final compareResults = await CompareResults.fetch(
      book: ref.book,
      chapter: ref.chapter,
      verse: ref.verse,
      translations: PrefsBloc.getString(PrefItemId.translationsFilter));

  return showModalBottomSheet<int>(
    shape: bottomSheetShape,
    context: c,
    useRootNavigator: true,
    isScrollControlled: true,
    enableDrag: true,
    builder: (c) => SizedBox(
      height: 3 * MediaQuery.of(c).size.height / 4,
      child: CompareVerseScreen(
        results: compareResults,
        title: ref.label(),
      ),
    ),
  );
}

class CompareVerseScreen extends StatelessWidget {
  final String title;
  final CompareResults results;

  const CompareVerseScreen({Key key, this.results, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        textTheme: Theme.of(context).textTheme,
        iconTheme: Theme.of(context).iconTheme,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 5,
              width: 50,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Text(title),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
          itemCount: results.data.length,
          itemBuilder: (c, i) => ListTile(
                title: Text(
                  results.data[i].a,
                  textScaleFactor: contentTextScaleFactorWith(context),
                ),
                onTap: () {
                  Navigator.of(context).pop(results.data[i].id);
                },
                subtitle: Text(
                  results.data[i].text,
                  textScaleFactor: contentTextScaleFactorWith(context),
                ),
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

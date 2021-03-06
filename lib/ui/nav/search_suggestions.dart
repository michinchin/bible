import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/search/nav_bloc.dart';

class SearchSuggestionsView extends StatelessWidget {
  final Function({String query}) onSubmit;
  final TextEditingController searchController;
  const SearchSuggestionsView({Key key, @required this.onSubmit, @required this.searchController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.tbloc<NavBloc>();
    final bible = VolumesRepository.shared.bibleWithId(9);
    final wordSuggestions = bloc.state.wordSuggestions ?? [];
    final bookSuggestions = bloc.state.bookSuggestions ?? [];
    void updateSearch(String s) => searchController
      ..text = s
      ..selection = TextSelection.collapsed(offset: s.length);

    return SingleChildScrollView(
      child: Column(
        children: [
          for (final book in bookSuggestions)
            ListTile(
                leading: const Icon(FeatherIcons.bookOpen),
                title: Text(bible.nameOfBook(book)),
                onTap: () {
                  final search = '${bible.nameOfBook(book)} ';
                  updateSearch(search);
                  bloc.add(NavEvent.onSearchChange(search: search));
                }),
          for (final word in wordSuggestions)
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(word),
              onTap: () {
                final a = word;
                var query = bloc.state.search;
                if (' '.allMatches(query).length < 4 &&
                    query.substring(query.length - 1, query.length) == ' ') {
                  query += '$a ';
                  updateSearch(query);
                  bloc.add(NavEvent.onSearchChange(search: query));
                } else {
                  final words = query.split(' ')..last = a;
                  query = words.join(' ');
                  updateSearch(query);
                  onSubmit(query: query);
                }
              },
            ),
        ],
      ),
    );
  }
}

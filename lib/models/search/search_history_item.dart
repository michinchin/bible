import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart';

class SearchHistoryItem extends Equatable {
  final String search;
  final String volumesFiltered;
  final String booksFiltered;
  final int index;
  final DateTime modified;

  const SearchHistoryItem({
    @required this.search,
    @required this.volumesFiltered,
    @required this.booksFiltered,
    @required this.index,
    @required this.modified,
  }) : assert(search != null &&
            volumesFiltered != null &&
            booksFiltered != null &&
            index != null &&
            modified != null);

  @override
  List<Object> get props => [search, volumesFiltered, booksFiltered, index, modified];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'search': search,
        'volumes': volumesFiltered,
        'books': booksFiltered,
        'index': index,
        'modified': dbIntFromDateTime(modified),
      };

  factory SearchHistoryItem.fromJson(Object json) {
    String search;
    String volumes;
    String books;
    int index;
    int modified;

    final jsonMap = json is String ? parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      search = as<String>(jsonMap['search']);
      volumes = as<String>(jsonMap['volumes']);
      books = as<String>(jsonMap['books']);
      index = as<int>(jsonMap['index']);
      modified = as<int>(jsonMap['modified']);
    }

    if (search != null && volumes != null && books != null && index != null && modified != null) {
      return SearchHistoryItem(
          search: search,
          volumesFiltered: volumes,
          booksFiltered: books,
          index: index,
          modified: dateTimeFromDbInt(modified));
    }

    return null;
  }
}

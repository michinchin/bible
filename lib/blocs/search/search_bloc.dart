import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/search_result.dart';

part 'search_bloc.freezed.dart';

@freezed
abstract class SearchEvent with _$SearchEvent {
  const factory SearchEvent.request({String search}) = _Requested;
}

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    String search,
    List<SearchResult> searchResults,
    List<int> defaultTranslations,
    bool loading,
    bool error,
  }) = _SearchState;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  @override
  SearchState get initialState => const SearchState(
      search: '', searchResults: [], defaultTranslations: [], loading: false, error: false);

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is _Requested) {
      yield state.copyWith(loading: true);
      try {
        final res = await SearchResults.fetch(words: event.search, translationIds: '51');
        yield state.copyWith(searchResults: res, loading: false, search: event.search);
      } catch (_) {
        yield state.copyWith(error: true, loading: false, search: event.search);
      }
    }
  }
}

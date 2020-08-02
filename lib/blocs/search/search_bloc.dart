// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:tec_volumes/tec_volumes.dart';

// @freezed
// abstract class SearchEvent with _$SearchEvent {
//   const factory SearchEvent.loadSearchResults({String search}) = _LoadSearchResults;

// }

// @freezed
// abstract class SearchState with _$SearchState {
//   const factory SearchState({
//   String search,
//   List<Reference> searchResults,
//   List<int> defaultTranslations,
//   }) = _SearchState;
// }


// class SearchBloc extends Bloc<SearchEvent, SearchState> {

//   @override
//   SearchState get initialState => SearchState(search: '');

//   @override
//   Stream<SearchState> mapEventToState(SearchEvent event) async* {
//     final newState = event.when( loadSearchResults: );
//     // tec.dmPrint('$newState');
//     yield newState;
//   }

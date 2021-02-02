import 'package:bloc/bloc.dart';
import 'zendesk_api.dart';

class SearchHelpState {
  final List<ZendeskArticle> articles;
  final bool isLoading;
  final bool hasError;
  SearchHelpState({this.articles, this.isLoading, this.hasError});

  factory SearchHelpState.initial() => SearchHelpState(articles: [], isLoading: false);
  factory SearchHelpState.loading() => SearchHelpState(articles: [], isLoading: true);
  factory SearchHelpState.success(List<ZendeskArticle> articles) =>
      SearchHelpState(articles: articles, isLoading: false);
  factory SearchHelpState.error() =>
      SearchHelpState(articles: [], isLoading: false, hasError: true);
}

class SearchHelpEvent {
  final String query;
  SearchHelpEvent(this.query);
}

class SearchHelpBloc extends Bloc<SearchHelpEvent, SearchHelpState> {
  SearchHelpBloc() : super(SearchHelpState.initial());

  @override
  Stream<SearchHelpState> mapEventToState(SearchHelpEvent event) async* {
    yield SearchHelpState.loading();
    try {
      final articles = await ZendeskApi.fetchSearch(event.query);
      yield SearchHelpState.success(articles);
    } catch (_) {
      yield SearchHelpState.error();
    }
  }
}

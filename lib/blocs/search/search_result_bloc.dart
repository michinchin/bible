import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/search/context.dart';
import '../../models/search/search_result.dart';
import '../../models/search/tec_share.dart';
part 'search_result_bloc.freezed.dart';

@freezed
abstract class SearchResultEvent with _$SearchResultEvent {
  const factory SearchResultEvent.share() = _Share;
  const factory SearchResultEvent.copy({BuildContext context}) = _Copy;
  const factory SearchResultEvent.openInTB({BuildContext context}) = _OpenInTb;
  const factory SearchResultEvent.showContext() = _ShowInContext;
  const factory SearchResultEvent.onTranslationChange({int idx}) = _OnTranslationChange;
}

@freezed
abstract class SearchResultState with _$SearchResultState {
  const factory SearchResultState({
    SearchResult res,
    int verseIndex, // which of the available translations was chosen
    Map<int, Context> contextMap, // key: verseIndex, value: context text
    bool isSelected,
    bool contextShown,
    bool contextLoading,
    bool contextError,
    String label,
    String url,
  }) = _SearchResultState;
}

class SearchResultBloc extends Bloc<SearchResultEvent, SearchResultState> {
  final SearchResult result;
  final bool shareUrl;
  SearchResultBloc(this.result, {this.shareUrl = true});
  @override
  SearchResultState get initialState => SearchResultState(
      res: result,
      verseIndex: 0,
      contextMap: {},
      url: '',
      isSelected: false,
      contextShown: false,
      contextError: false,
      contextLoading: false,
      label: '${result.ref} ${result.verses[0].a}');

  String get label => state.contextShown
      ? '${state.res.ref.split(':')[0]}:'
          '${state.contextMap[state.verseIndex].initialVerse}-${state.contextMap[state.verseIndex].finalVerse}'
          ' ${state.res.verses[state.verseIndex].a}'
      : '${state.res.ref} ${state.res.verses[state.verseIndex].a}';

  String get currentText => state.contextShown
      ? state.contextMap[state.verseIndex]?.text ?? ''
      : state.res.verses[state.verseIndex].verseContent;

  String get _textToShare => '$label\n$currentText';

  @override
  Stream<SearchResultState> mapEventToState(SearchResultEvent event) async* {
    if (event is _OnTranslationChange) {
      // if text is null on translation change then update context map
      if (state.contextShown) {
        yield state.copyWith(contextLoading: true);
        try {
          yield await _loadContext(event.idx);
        } catch (_) {
          yield state.copyWith(contextError: true, contextLoading: false);
        }
      }
    }

    if (event is _OnTranslationChange || state.url.isEmpty) {
      if (shareUrl) {
        final url = await TecShare.loadUrl(
            Reference.fromHref(state.res.href, volume: state.res.verses[state.verseIndex].id));
        yield state.copyWith(url: url);
      }
    }

    if (event is _ShowInContext) {
      yield state.copyWith(contextLoading: true);
      try {
        yield await _showInContext();
      } catch (_) {
        yield state.copyWith(contextError: true, contextLoading: false);
      }
    } else {
      final newState = event.maybeWhen(
          share: _share,
          copy: _copy,
          openInTB: _openInTB,
          onTranslationChange: _onTranslationChange,
          orElse: () => null);
      if (newState != null) {
        yield newState;
      }
    }
    yield state.copyWith(label: label);
  }

  SearchResultState _copy(BuildContext context) {
    TecShare.copy(context, '$_textToShare${state.url}');
    return state;
  }

  SearchResultState _share() {
    TecShare.share('$_textToShare${state.url}');
    tec.dmPrint('Sharing verse: ${state.res.href} ');
    return state;
  }

  SearchResultState _openInTB(BuildContext context) {
    Navigator.of(context)
        .pop(Reference.fromHref(state.res.href, volume: state.res.verses[state.verseIndex].id));
    tec.dmPrint('Navigating to verse: ${state.res.href}');
    return state;
  }

  Future<SearchResultState> _showInContext() async {
    final newState = await _loadContext(state.verseIndex);
    final showContext = !newState.contextShown;

    return newState.copyWith(contextShown: showContext);
  }

  Future<SearchResultState> _loadContext(int idx) async {
    final cMap = Map<int, Context>.from(state.contextMap);

    tec.dmPrint('Showing context for: ${state.res.href}');

    if (!cMap.containsKey(idx)) {
      final context = await Context.fetch(
        translation: state.res.verses[idx].id,
        book: state.res.bookId,
        chapter: state.res.chapterId,
        verse: state.res.verseId,
        content: state.res.verses[idx].verseContent,
      );
      cMap[idx] = context;
    }

    return state.copyWith(contextMap: cMap, contextLoading: false, contextError: false);
  }

  SearchResultState _onTranslationChange(int i) {
    tec.dmPrint('Switch translation to: ${state.res.verses[i].a}');
    return state.copyWith(verseIndex: i);
  }
}

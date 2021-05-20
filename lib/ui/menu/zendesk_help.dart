import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_bloc/tec_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/const.dart';
import '../../models/help/search_help_bloc.dart';
import '../../models/help/zendesk_api.dart';
import '../common/common.dart';
import 'main_menu_model.dart';

void showZendeskHelp(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (c) => BlocProvider(create: (c) => SearchHelpBloc(), child: const ZendeskHelp())));

class ZendeskHelp extends StatefulWidget {
  const ZendeskHelp({Key key}) : super(key: key);

  @override
  _ZendeskHelpState createState() => _ZendeskHelpState();
}

class _ZendeskHelpState extends State<ZendeskHelp> {
  TextEditingController _searchController;
  Timer _debounceTimer;
  Future<List<ZendeskSection>> _future;
  List<ZendeskSection> _sections;

  @override
  void initState() {
    _searchController = TextEditingController(text: '')..addListener(_searchListener);
    _future = ZendeskApi.fetchSections();
    super.initState();
  }

  void _searchListener() {
    if (!mounted) return;
    if (_debounceTimer?.isActive ?? false) _debounceTimer.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          // dmPrint('search string: ${_textEditingController.text.trim()}');
          final searchBloc = context.tbloc<SearchHelpBloc>();

          // only initiate a search if the query has changed...
          if (searchBloc != null && _searchController.text != searchBloc.state.query) {
            searchBloc.add(SearchHelpEvent(_searchController.text));
          }
        }
      },
    );
  }

  Future<void> _loadArticles(ZendeskSection section) async {
    _sections[_sections.indexOf(section)] =
        section.copyWith(articles: await ZendeskApi.fetchArticles(sectionId: section.id));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Help Desk'),
      ),
      body: FutureBuilder<List<ZendeskSection>>(
          future: _future,
          builder: (c, s) {
            final data = s?.data ?? [];
            _sections = data;
            if (s.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(padding: EdgeInsets.all(10), child: LoadingIndicator()));
            }
            return SingleChildScrollView(
                child: Column(
              children: [
                TecSearchField(textEditingController: _searchController),
                BlocBuilder<SearchHelpBloc, SearchHelpState>(builder: (c, state) {
                  if (_searchController.text.isEmpty) {
                    return Column(children: [
                      for (final s in _sections)
                        ExpansionTile(
                          leading: const Icon(Icons.article),
                          title: Text(s.name),
                          onExpansionChanged: (_) => _loadArticles(s),
                          children: [
                            if (s.articles == null)
                              const Padding(padding: EdgeInsets.all(10), child: LoadingIndicator())
                            else
                              for (final a in s?.articles ?? <ZendeskArticle>[])
                                ListTile(
                                  title: Text(
                                    a.title,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  onTap: () => showArticlePage(c, a),
                                )
                          ],
                        )
                    ]);
                  } else {
                    if (state.isLoading) {
                      return const Center(
                        child: LoadingIndicator(),
                      );
                    }
                    return Column(children: [
                      for (final a in state.articles)
                        ListTile(
                          leading: const Icon(Icons.search),
                          title: Text(
                            a.title,
                          ),
                          onTap: () => showArticlePage(c, a),
                        )
                    ]);
                  }
                }),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Feedback'),
                  onTap: () => MainMenuModel().emailFeedback(context),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Reset Feature Discovery'),
                  onTap: () async {
                    await resetFeatureDiscoveries([Const.prefFabRead, Const.prefFabTabs]);
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    // initFeatureDiscovery(
                    //     context: context, pref: Const.prefFabTabs, steps: [Const.fabTabFeatureId]);
                    // initFeatureDiscovery(
                    //     context: context, pref: Const.prefFabRead, steps: [Const.fabReadFeatureId]);
                    TecToast.show(context, 'Success!');
                  },
                )
              ],
            ));
          }),
    );
  }
}

void showArticlePage(BuildContext c, ZendeskArticle article) => Navigator.of(c, rootNavigator: true)
    .push(MaterialPageRoute<void>(builder: (c) => ZendeskArticlePage(article)));

class ZendeskArticlePage extends StatelessWidget {
  final ZendeskArticle article;

  const ZendeskArticlePage(this.article, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TecText(article.title, autoSize: true, maxLines: 2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: TecHtml(
            article.body,
            baseUrl: '',
          ),
        ),
      ),
    );
  }
}

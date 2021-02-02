import 'dart:async';

import 'package:bible/models/help/search_help_bloc.dart';
import 'package:bible/models/help/zendesk_api.dart';
import 'package:bible/ui/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_html/tec_html.dart';
import 'main_menu_model.dart';

void showZendeskHelp(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (c) => BlocProvider(create: (c) => SearchHelpBloc(), child: ZendeskHelp())));

class ZendeskHelp extends StatefulWidget {
  @override
  _ZendeskHelpState createState() => _ZendeskHelpState();
}

class _ZendeskHelpState extends State<ZendeskHelp> {
  TextEditingController _searchController;
  Timer _debounceTimer;
  Future<List<ZendeskSection>> _sections;

  @override
  void initState() {
    _searchController = TextEditingController(text: '')..addListener(_searchListener);
    _sections = ZendeskApi.fetchSections();
    super.initState();
  }

  void _searchListener() {
    if (!mounted) return;
    if (_debounceTimer?.isActive ?? false) _debounceTimer.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          // tec.dmPrint('search string: ${_textEditingController.text.trim()}');
          context.tbloc<SearchHelpBloc>()?.add(SearchHelpEvent(_searchController.text));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Help Desk'),
      ),
      body: FutureBuilder<List<ZendeskSection>>(
          future: _sections,
          builder: (c, s) {
            final data = s?.data ?? [];
            if (s.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }
            return SingleChildScrollView(
                child: Column(
              children: [
                TecSearchField(textEditingController: _searchController),
                BlocBuilder<SearchHelpBloc, SearchHelpState>(builder: (c, state) {
                  if (_searchController.text.isEmpty) {
                    return Column(children: [
                      for (final d in data)
                        ExpansionTile(
                          leading: const Icon(Icons.article),
                          title: Text(d.name),
                          children: [
                            for (final a in d.articles)
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
  const ZendeskArticlePage(this.article);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(article.title),
      ),
      body: SingleChildScrollView(
        child: TecHtml(
          article.body,
          baseUrl: '',
        ),
      ),
    );
  }
}

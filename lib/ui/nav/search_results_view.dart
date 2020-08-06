import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/search_bloc.dart';
import '../../models/search_result.dart';

class SearchResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchBloc = context.bloc<SearchBloc>(); // ignore: close_sinks
    return BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
      if (state.loading) {
        return const Center(child: CupertinoActivityIndicator());
      } else if (state.error) {}
      return SafeArea(
        bottom: false,
        child: ListView.builder(
          itemCount: searchBloc.state.searchResults.length + 1,
          itemBuilder: (c, i) {
            if (i == 0) {
              return _SearchResultsLabel(searchBloc.state.searchResults);
            }
            i--;
            final res = searchBloc.state.searchResults[i];
            return _SearchResultCard(res);
          },
        ),
      );
    });
  }
}

class _SearchResultCard extends StatefulWidget {
  final SearchResult res;
  const _SearchResultCard(this.res);

  @override
  __SearchResultCardState createState() => __SearchResultCardState();
}

class __SearchResultCardState extends State<_SearchResultCard> {
  void _onCopy() => Clipboard.setData(const ClipboardData(text: 'widget.res.href')).then((x) {
        TecToast.show(context, 'Successfully Copied!');
      });

  void _onShare() => Share.share(widget.res.href);
  void _openInTB() => Navigator.of(context).pop(Reference.fromHref(widget.res.href));
  void _showContext() => () {};

  @override
  Widget build(BuildContext context) {
    return TecCard(
      color: Theme.of(context).cardColor,
      builder: (c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Theme(
            data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                accentColor: Theme.of(context).textColor,
                iconTheme:
                    Theme.of(context).iconTheme.copyWith(color: Theme.of(context).textColor)),
            child: ExpansionTile(
                title: Text(
                  widget.res.ref,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                childrenPadding: EdgeInsets.zero,
                subtitle: TecText.rich(TextSpan(
                    children: searchResTextSpans(widget.res.verses[0].verseContent,
                        context.bloc<SearchBloc>().state.search))),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(FeatherIcons.code),
                          onPressed: _showContext,
                        ),
                        ButtonBar(
                          children: [
                            IconButton(
                              icon: const Icon(FeatherIcons.copy),
                              onPressed: _onCopy,
                            ),
                            IconButton(
                              icon: const Icon(FeatherIcons.share),
                              onPressed: _onShare,
                            ),
                            IconButton(
                              icon: const Icon(TecIcons.tbOutlineLogo),
                              onPressed: _openInTB,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ])),
      ),
    );
  }
}

class _SearchResultsLabel extends StatelessWidget {
  final List<SearchResult> results;

  const _SearchResultsLabel(this.results);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TecText.rich(
            TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                TextSpan(
                  text:
                      'Showing ${results.length} verse${results.length > 1 ? 's' : ''} containing ',
                ),
                TextSpan(
                    text: '${context.bloc<SearchBloc>().state.search}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                // if (vm.filterOn)
                //   if (vm.showOTLabel)
                //     const TextSpan(text: ' in the Old Testament')
                //   else if (vm.showNTLabel)
                //     const TextSpan(text: ' in the New Testament')
                //   else if (vm.booksSelected.length <= 5)
                //     TextSpan(
                //       text: ' in ${vm.booksSelected.map((b) {
                //         return b.name;
                //       }).join(', ')}',
                //     )
                //   else
                //     const TextSpan(text: ' in current filter')
              ],
            ),
          ),
        ));
  }
}

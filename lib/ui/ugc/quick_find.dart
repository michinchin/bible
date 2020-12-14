import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickFind extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: TextField(
          // onEditingComplete: onSubmit,
          // focus text field when no current search results but coming from magnifying glass
          // autofocus: widget.searchView && ss.searchResults.isEmpty,
          style: Theme.of(context).appBarTheme.textTheme.bodyText1,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_outlined),
            border: InputBorder.none,
            suffixIcon: Icon(Icons.cancel_outlined),
            // suffixIcon: s == NavViewState.searchSuggestions
            //     ? IconButton(
            //         color: Theme.of(context).appBarTheme.actionsIconTheme.color,
            //         icon: const Icon(Icons.cancel_outlined),
            //         onPressed: () {
            //           _searchController.clear();
            //           navBloc().add(const NavEvent.onSearchChange(search: ''));
            //         })
            //     : Container(width: 1),
            hintText: 'Search notes',
            // hintStyle: Theme.of(context)
            //     .appBarTheme
            //     .textTheme
            //     .bodyText1
            //     .copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }
}
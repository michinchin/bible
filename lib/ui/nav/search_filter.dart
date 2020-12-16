import 'dart:collection';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/search/search_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/const.dart';
import '../../models/language_utils.dart' as l;
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../library/volumes_bloc.dart';

Future<List<List<int>>> showFilter(BuildContext context,
        {VolumesFilter filter,
        Iterable<int> selectedVolumes,
        Iterable<int> filteredBooks,
        TextEditingController searchController}) =>
    showModalBottomSheet<List<List<int>>>(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (c) => SizedBox(
              height: MediaQuery.of(c).size.height / 2,
              child: _SearchFilterView(
                  filter: filter,
                  selectedVolumes: selectedVolumes,
                  selectedBooks: filteredBooks,
                  searchController: searchController),
            ));

class _SearchFilterView extends StatefulWidget {
  final VolumesFilter filter;
  final Iterable<int> selectedVolumes;
  final Iterable<int> selectedBooks;
  final TextEditingController searchController;

  const _SearchFilterView(
      {this.filter, this.selectedVolumes, this.selectedBooks, this.searchController});

  @override
  __SearchFilterViewState createState() => __SearchFilterViewState();
}

class __SearchFilterViewState extends State<_SearchFilterView> with SingleTickerProviderStateMixin {
  Set<int> _selectedVolumes;
  Set<int> _filteredBooks;
  bool _booksInGridView;
  bool _volumesInGridView;
  TabController _tabController;
  String _currFilter;
  bool _showPriorityTranslations;

  PrefItemsBloc prefsBloc() => context.tbloc<PrefItemsBloc>();

  final bookTitle = 'Book';
  final translationTitle = 'Translation';
  final priorityTranslationTitle = 'Priority Translation';

  @override
  void initState() {
    _currFilter = bookTitle;
    _showPriorityTranslations = false;
    _tabController = TabController(initialIndex: 0, vsync: this, length: 2)
      ..addListener(() {
        if (_tabController.previousIndex != _tabController.index) {
          setState(() {
            _currFilter = _tabController.index == 1 ? translationTitle : bookTitle;
            // take out of priority translation mode if in it
            _showPriorityTranslations = false;
          });
        }
      });
    _booksInGridView = prefsBloc().itemBool(PrefItemId.searchFilterBookGridView);
    _volumesInGridView = prefsBloc().itemBool(PrefItemId.searchFilterTranslationGridView);
    _selectedVolumes = widget.selectedVolumes?.toSet();
    _filteredBooks = widget.selectedBooks?.toSet();
    super.initState();
  }

  @override
  void deactivate() {
    if (_booksInGridView != prefsBloc().itemBool(PrefItemId.searchFilterBookGridView)) {
      prefsBloc().add(PrefItemEvent.update(
          prefItem: prefsBloc().toggledPrefItem(PrefItemId.searchFilterBookGridView)));
    }
    if (_volumesInGridView != prefsBloc().itemBool(PrefItemId.searchFilterTranslationGridView)) {
      prefsBloc().add(PrefItemEvent.update(
          prefItem: prefsBloc().toggledPrefItem(PrefItemId.searchFilterTranslationGridView)));
    }

    _updateSearch();
    super.deactivate();
  }

  void _updateSearch() {
    final books = _filteredBooks.toList();
    final volumes = _selectedVolumes.toList();

    if (volumes != null && !tec.areEqualSets(_selectedVolumes, widget.selectedVolumes.toSet())) {
      final prefItem =
          prefsBloc().infoChangedPrefItem(PrefItemId.translationsFilter, volumes.join('|'));
      prefsBloc().add(PrefItemEvent.update(prefItem: prefItem));
      if (widget.searchController.text.isNotEmpty) {
        context
            .tbloc<SearchBloc>()
            .add(SearchEvent.request(search: widget.searchController.text, translations: volumes));
      }
    }
    if (books != null && !tec.areEqualSets(_filteredBooks, widget.selectedBooks.toSet())) {
      // excluded books
      context.tbloc<SearchBloc>().add(SearchEvent.filterBooks(books));
    }
  }

  void _changeFilter(String s) {
    setState(() {
      _currFilter = s;
    });

    _tabController.animateTo(_currFilter == bookTitle ? 0 : 1);
  }

  void _togglePriorityTranslations() {
    setState(() {
      _showPriorityTranslations = !_showPriorityTranslations;
    });
  }

  void _gridViewToggle() {
    setState(() {
      _currFilter == bookTitle
          ? _booksInGridView = !_booksInGridView
          : _volumesInGridView = !_volumesInGridView;
    });
  }

  bool get _gridView => _currFilter == bookTitle ? _booksInGridView : _volumesInGridView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 5,
            width: 50,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                        mainAxisAlignment: _showPriorityTranslations
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.start,
                        children: [
                          if (_currFilter == 'Translation' && !_showPriorityTranslations)
                            IconButton(
                              icon: const Icon(Icons.error_outline),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _togglePriorityTranslations();
                                if (_showPriorityTranslations) {
                                  TecToast.show(context, 'select up to 3 translations');
                                }
                              },
                            ),
                          Text(
                              '${_showPriorityTranslations ? priorityTranslationTitle : _currFilter} filter'),
                          if (_showPriorityTranslations)
                            FlatButton(
                              child: const Text('Done'),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                _togglePriorityTranslations();
                                if (_showPriorityTranslations) {
                                  TecToast.show(context, 'select up to 3 translations');
                                }
                              },
                            ),
                        ]),
                  ),
                  if (!_showPriorityTranslations)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _gridView ? Icons.format_list_bulleted : FeatherIcons.grid,
                          ),
                          onPressed: _gridViewToggle,
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).textColor),
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: DropdownButton<String>(
                                isDense: true,
                                value: _currFilter,
                                underline: const SizedBox(),
                                iconSize: 15,
                                style: Theme.of(context).textTheme.caption,
                                icon: const Icon(Icons.expand_more),
                                items: <String>[
                                  'Book',
                                  'Translation',
                                ].map((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: _changeFilter)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ]),
      ),
      body: TabBarView(controller: _tabController, children: [
        _BookFilter(_filteredBooks ?? {}, gridView: _gridView),
        _VolumeFilter(widget.filter, _selectedVolumes ?? {},
            gridView: _gridView, priorityTranslationMode: _showPriorityTranslations),
      ]),
    );
  }
}

class _VolumeFilter extends StatefulWidget {
  final VolumesFilter filter;
  final Set<int> selectedVolumes;
  final bool gridView;
  final bool priorityTranslationMode;

  const _VolumeFilter(this.filter, this.selectedVolumes,
      {this.gridView, this.priorityTranslationMode = false});

  @override
  __VolumeFilterState createState() => __VolumeFilterState();
}

class __VolumeFilterState extends State<_VolumeFilter> {
  List<int> _priorityTranslationList;

  PrefItemsBloc prefBloc() => context.tbloc<PrefItemsBloc>();

  @override
  void deactivate() {
    final priorityTranslations =
        context.tbloc<PrefItemsBloc>().itemWithId(PrefItemId.priorityTranslations).info;
    final pt = (priorityTranslations?.split('|')?.map(int.tryParse)?.toList() ?? [])
      ..removeWhere((p) => p == null);
    if (pt != _priorityTranslationList) {
      prefBloc().add(PrefItemEvent.update(
          prefItem: prefBloc().infoChangedPrefItem(
              PrefItemId.priorityTranslations, _priorityTranslationList.join('|'))));
      context.tbloc<SearchBloc>().refresh();
    }
    super.deactivate();
  }

  @override
  void initState() {
    final priorityTranslations =
        context.tbloc<PrefItemsBloc>().itemWithId(PrefItemId.priorityTranslations).info;
    final pt = (priorityTranslations?.split('|')?.map(int.tryParse)?.toList() ?? [])
      ..removeWhere((p) => p == null);
    _priorityTranslationList = pt.toList();
    super.initState();
  }

  void _refresh([VoidCallback fn]) {
    if (mounted) setState(fn ?? () {});
  }

  void _toggle(int id) {
    _refresh(() {
      if (widget.priorityTranslationMode) {
        if (_priorityTranslationList.contains(id)) {
          _priorityTranslationList.remove(id);
        } else {
          if (_priorityTranslationList.length >= 3) {
            TecToast.show(context, 'Cannot select more than 3');
          } else {
            _priorityTranslationList.add(id);
          }
        }
      } else {
        if (!widget.selectedVolumes.remove(id)) widget.selectedVolumes.add(id);
      }
    });
  }

  Map<String, List<Volume>> _mapByLanguage(List<Volume> volumes) {
    final map = <String, List<Volume>>{};

    for (final volume in volumes) {
      map[volume.language] = map[volume.language] ?? []
        ..add(volume);
    }
    return map;
  }

  bool _selected(Volume v) {
    if (widget.priorityTranslationMode) {
      return _priorityTranslationList.contains(v.id);
    }
    return widget.selectedVolumes.contains(v.id);
  }

  String _title(Volume v) {
    if (widget.gridView) {
      var title = v.abbreviation;
      if (widget.priorityTranslationMode && _priorityTranslationList.contains(v.id)) {
        title = '${_priorityTranslationList.indexOf(v.id) + 1}. $title';
      }
      return title;
    }
    return v.name;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VolumesBloc>(
        create: (context) => VolumesBloc(
              defaultFilter: widget.filter,
            )..refresh(),
        child: BlocBuilder<VolumesBloc, VolumesState>(builder: (context, state) {
          final translations = state.volumes ?? [];
          final map = _mapByLanguage(translations);

          return SafeArea(
              child: ListView(
            children: [
              for (final lang in map.keys) ...[
                ListLabel(l.languageNameFromCode(lang)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: widget.gridView || widget.priorityTranslationMode
                        ? Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final v in map[lang])
                                ButtonTheme(
                                  minWidth: 50,
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  layoutBehavior: ButtonBarLayoutBehavior.constrained,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)),
                                      color: _selected(v)
                                          ? Theme.of(context).accentColor
                                          : Theme.of(context).brightness == Brightness.dark
                                              ? Theme.of(context).cardColor
                                              : Colors.grey[200],
                                      onPressed: () => _toggle(v.id),
                                      child: Text(
                                        _title(v),
                                        style: TextStyle(
                                            color: _selected(v)
                                                ? Colors.white
                                                : Theme.of(context).textColor.withOpacity(0.8)),
                                      )),
                                )
                            ],
                          )
                        : Column(
                            children: [
                              for (final v in map[lang])
                                ListTile(
                                  onTap: () => _toggle(v.id),
                                  leading: _selected(v)
                                      ? const Icon(Icons.check_circle, color: Colors.blue)
                                      : const Icon(Icons.panorama_fish_eye),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(_title(v)),
                                )
                            ],
                          )),
              ],
            ],
          ));
        }));
  }
}

class _BookFilter extends StatefulWidget {
  final Set<int> selectedBooks;
  final bool gridView;

  const _BookFilter(this.selectedBooks, {this.gridView});

  @override
  __BookFilterState createState() => __BookFilterState();
}

class __BookFilterState extends State<_BookFilter> {
  bool _otSelected = true;
  bool _ntSelected = true;
  final otLabel = 'Old Testament';
  final ntLabel = 'New Testament';
  final otId = -2;
  final ntId = -1;

  List<SearchResultInfo> searchResults;

  // ignore: prefer_collection_literals
  final bookNames = LinkedHashMap<int, String>();

  // ignore: prefer_collection_literals
  final bookResults = LinkedHashMap<int, int>();
  Bible bible;
  List<int> _ot;
  List<int> _nt;
  int _otCount = 0;
  int _ntCount = 0;

  @override
  void initState() {
    searchResults = context.tbloc<SearchBloc>().state.searchResults;
    _initBible();
    super.initState();
  }

  void _initBible() {
    bible = VolumesRepository.shared.bibleWithId(Const.defaultBible);
    var book = bible.firstBook;
    while (book != 0) {
      bookNames[book] = bible.nameOfBook(book);
      final nextBook = bible.bookAfter(book);
      book = (nextBook == book ? 0 : nextBook);
    }

    if (searchResults.isNotEmpty) {
      var book = bible.firstBook;
      while (book != 0) {
        bookResults[book] = searchResults.where((sr) => sr.searchResult.bookId == book).length;
        final nextBook = bible.bookAfter(book);
        book = (nextBook == book ? 0 : nextBook);
      }
    }

    // bool hasSearchResults(int book) => searchResults.isNotEmpty && bookResults[book] != 0;

    _ot = bookNames.keys.takeWhile(bible.isOTBook).toList();
    _nt = bookNames.keys.where(bible.isNTBook).toList();
  }

  void _refresh([VoidCallback fn]) {
    if (mounted) setState(fn ?? () {});
  }

  void _toggle(int id) {
    if (id < 0) {
      // ot or nt selection
      _refresh(() => selectTestament(id));
    } else {
      // book selection
      if (widget.selectedBooks.isEmpty ||
          (_otSelected && _ot.contains(id)) ||
          (_ntSelected && _nt.contains(id))) {
        _refresh(() => selectOneAndDeselectRest(id));
      } else {
        _refresh(() => addOrRemove(id));
      }
    }
  }

  void selectTestament(int id) {
    if (id == otId) {
      _otSelected = !_otSelected;
      for (final o in _ot) {
        _otSelected ? widget.selectedBooks.remove(o) : widget.selectedBooks.add(o);
      }
    } else if (id == ntId) {
      _ntSelected = !_ntSelected;
      for (final n in _nt) {
        _ntSelected ? widget.selectedBooks.remove(n) : widget.selectedBooks.add(n);
      }
    }
  }

  void selectOneAndDeselectRest(int id) {
    if (_ot.contains(id)) {
      // deselect all of ot but book
      for (final o in _ot) {
        if (o != id) widget.selectedBooks.add(o);
      }
    } else if (_nt.contains(id)) {
      // deselect all of nt but book
      for (final n in _nt) {
        if (n != id) widget.selectedBooks.add(n);
      }
    }
  }

  void addOrRemove(int id) {
    if (!widget.selectedBooks.remove(id)) widget.selectedBooks.add(id);
  }

  void _checkSelection() {
    // grab ot books and take only ones with search results
    _otCount = 0;
    var allSelected = true;
    // get total count of search results in ot
    for (final o in _ot) {
      if (widget.selectedBooks.contains(o)) {
        allSelected = false;
      }
      _otCount += bookResults[o];
    }
    _otSelected = allSelected;

    // grab nt books and take only ones with search results
    allSelected = true;
    _ntCount = 0;
    // get total count of search results in nt
    for (final n in _nt) {
      if (widget.selectedBooks.contains(n)) {
        allSelected = false;
      }
      _ntCount += bookResults[n];
    }
    _ntSelected = allSelected;
  }

  bool _testSelected(String s) => s == otLabel ? _otSelected : _ntSelected;

  @override
  Widget build(BuildContext context) {
    if (bookResults.isNotEmpty) _checkSelection();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    Widget list(List<int> books) => widget.gridView
        ? Padding(
            padding: const EdgeInsets.only(left: 25, right: 10),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final b in books)
                  if (bookResults[b] != 0)
                    ButtonTheme(
                      height: 30,
                      minWidth: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      layoutBehavior: ButtonBarLayoutBehavior.constrained,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: FlatButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: !widget.selectedBooks.contains(b)
                              ? Theme.of(context).accentColor
                              : isDarkTheme
                                  ? Theme.of(context).cardColor
                                  : Colors.grey[200],
                          onPressed: () => _toggle(b),
                          child: Text(
                            '${bookNames[b]}${searchResults.isNotEmpty ? ' (${bookResults[b]})' : ''}',
                            style: TextStyle(
                                color: !widget.selectedBooks.contains(b)
                                    ? Colors.white
                                    : Theme.of(context).textColor.withOpacity(0.8)),
                          )),
                    )
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                for (final b in books)
                  if (bookResults[b] != 0)
                    ListTile(
                      onTap: () => _toggle(b),
                      leading: !widget.selectedBooks.contains(b)
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const Icon(Icons.panorama_fish_eye),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                          '${bookNames[b]} ${searchResults.isNotEmpty ? '(${bookResults[b]})' : ''}'),
                    )
              ],
            ),
          );

    Widget label(String s) => widget.gridView
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlatButton(
                    height: 30,
                    minWidth: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    color: _testSelected(s)
                        ? Theme.of(context).accentColor
                        : isDarkTheme
                            ? Theme.of(context).cardColor
                            : Colors.grey[200],
                    onPressed: () => _toggle(s == otLabel ? otId : ntId),
                    child: Text(
                      '$s ${searchResults.isNotEmpty ? '(${s == otLabel ? _otCount : _ntCount})' : ''}',
                      style: TextStyle(
                          color: _testSelected(s)
                              ? Colors.white
                              : Theme.of(context).textColor.withOpacity(0.8)),
                    )),
              ],
            ),
          )
        : ListTile(
            onTap: () => _toggle(s == otLabel ? otId : ntId),
            leading: _testSelected(s)
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.panorama_fish_eye),
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(
                '$s ${searchResults.isNotEmpty ? '(${s == otLabel ? _otCount : _ntCount})' : ''}'),
          );

    return ListView(children: [label(otLabel), list(_ot), label(ntLabel), list(_nt)]);
  }
}

import 'dart:async';
import 'dart:math';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/color_utils.dart';
import '../../models/reference_ext.dart';
import '../../models/ugc/recent_count.dart';
import '../common/common.dart';
import '../common/tec_search_result.dart';
import 'bread_crumb_row.dart';
import 'create_note_folder.dart';
import 'quick_find.dart';

class _DividerItem {}

class _DateItem {
  final DateTime date;

  const _DateItem(this.date);
}

class UGCView extends StatefulWidget {
  static const folderHome = 1;
  static const folderRecent = -20;
  static const folderBookmarks = -1;
  static const folderNotes = -2;
  static const folderMarginNotes = -3;
  static const folderHighlights = -4;
  static const folderLicenses = -5;
  static const folderSearchResults = -6;
  static const filterSeparator = 'zZzZ';

  const UGCView({Key key}) : super(key: key);

  @override
  _UGCViewState createState() => _UGCViewState();

  bool willPop(State<StatefulWidget> state) {
    if (state is _UGCViewState && state.mounted && state.breadCrumbs.length > 1) {
      state.breadCrumbs.length = state.breadCrumbs.length - 1;
      state._load(state.breadCrumbs.last, poppingView: true);
      return true;
    }

    return false;
  }
}

Map<int, UserItem> _folders;
int _folderUserId;

class _UGCViewState extends State<UGCView> {
  List<BreadCrumb> breadCrumbs;
  int currentFolderId;
  List items;
  List<String> searchWords;
  ScrollController listScrollController;
  StreamSubscription<UserDbChange> _userDbChangeSubscription;
  final recentDate = DateTime.now().add(const Duration(days: -31));
  final recentTypes = [
    UserItemType.note,
    UserItemType.bookmark,
    UserItemType.marginNote,
    UserItemType.highlight
  ];
  int numBreadCrumbs;
  bool _poppingView;

  @override
  void initState() {
    super.initState();
    items = <dynamic>[];
    numBreadCrumbs = 0;
    _poppingView = false;
    breadCrumbs = [];

    asyncInit();
  }

  Future<void> asyncInit() async {
    breadCrumbs = await BreadCrumb.load();

    await _load(breadCrumbs.last);

    _userDbChangeSubscription = AppSettings.shared.userAccount.userDb.changeStream.listen((change) {
      _load(breadCrumbs.last, reloadFolders: true);
    });
  }

  @override
  void dispose() {
    BreadCrumb.save(breadCrumbs);
    _userDbChangeSubscription?.cancel();
    _userDbChangeSubscription = null;
    listScrollController?.dispose();
    super.dispose();
  }

  String _searchTypes(List<UserItemType> searchTypes) {
    final types = StringBuffer();

    for (final type in searchTypes) {
      if (types.isNotEmpty) {
        types.write('-');
      }
      types.write(type.index);
    }

    return types.toString();
  }

  String _folderTitle(int folderId) {
    switch (folderId) {
      case UGCView.folderRecent:
        return 'Recent';
      case UGCView.folderBookmarks:
        return 'Bookmarks';
      case UGCView.folderNotes:
        return 'Notes';
      case UGCView.folderMarginNotes:
        return 'Margin notes';
      case UGCView.folderHighlights:
        return 'Highlights';
      case UGCView.folderLicenses:
        return 'Licenses';
      case UGCView.folderSearchResults:
        return _folders[UGCView.folderHome].title;
    }

    return _folders[folderId].title;
  }

  Future<void> _search(String search, List<UserItemType> searchTypes,
      {double scrollOffset = 0}) async {
    final words = TecSearchResult.getLFormattedKeywords(search);

    if (words.isEmpty) {
      if (breadCrumbs.last.id == UGCView.folderSearchResults) {
        breadCrumbs.length = breadCrumbs.length - 1;
        unawaited(_load(breadCrumbs.last));
      }
      return;
    }

    final _items = await AppSettings.shared.userAccount.userDb
        .findItemsContaining(words, ofTypes: searchTypes);

    if (breadCrumbs.last.id == UGCView.folderSearchResults) {
      if (_items.isEmpty) {
        breadCrumbs.length = breadCrumbs.length - 1;

        setState(() {
          searchWords = <String>[];
          items = <dynamic>[];
        });
      } else {
        breadCrumbs.last.folderName =
            '$search${UGCView.filterSeparator}${_searchTypes(searchTypes)}';
      }
    } else {
      breadCrumbs.last.scrollOffset = listScrollController.offset;
      breadCrumbs.add(BreadCrumb(UGCView.folderSearchResults,
          '$search${UGCView.filterSeparator}${_searchTypes(searchTypes)}'));
    }

    if (_items.isNotEmpty) {
      setState(() {
        searchWords = words;
        items = _items;
      });

      listScrollController.jumpTo(scrollOffset);
    } else {
      TecToast.show(context, 'No results found!');
    }
  }

  Future<void> _load(BreadCrumb crumb,
      {bool poppingView = false, bool reloadFolders = false}) async {
    _poppingView = poppingView;

    if (_folders == null ||
        _folderUserId != AppSettings.shared.userAccount.user.userId ||
        reloadFolders) {
      _folderUserId = AppSettings.shared.userAccount.user.userId;
      _folders = {};

      // this view can be loaded multiple times... only load folders when necessary
      if (_folders.isEmpty) {
        for (final ui
            in await AppSettings.shared.userAccount.userDb.getItemsOfTypes([UserItemType.folder])) {
          _folders.putIfAbsent(ui.id, () => ui);
        }

        _folders.putIfAbsent(
            1, () => UserItem(id: 1, title: 'Journal', type: UserItemType.folder.index));
      }
    }

    // every load gets a new scroll controller since we're using animated switcher
    // old and new view coexist on transition
    listScrollController?.dispose();
    listScrollController = ScrollController();

    // maintain scroll position...
    listScrollController.addListener(() {
      breadCrumbs.last.scrollOffset = listScrollController.offset;
    });

    if (crumb.id == UGCView.folderSearchResults) {
      final index = crumb.folderName.indexOf(UGCView.filterSeparator);
      if (index > 0) {
        final search = crumb.folderName.substring(0, index);
        final searchTypes = <UserItemType>[];
        for (final type in crumb.folderName.substring(index + 4).split('-')) {
          searchTypes.add(UserItemType.values[int.parse(type)]);
        }

        unawaited(_search(search, searchTypes, scrollOffset: crumb.scrollOffset));
      } else {
        unawaited(_loadFolder(UGCView.folderHome));
      }
    } else {
      unawaited(_loadFolder(crumb.id, scrollOffset: crumb.scrollOffset));
    }
  }

  Future<void> _loadFolder(int folderId, {double scrollOffset = 0}) async {
    currentFolderId = folderId;
    final _items = <dynamic>[];

    if (currentFolderId > 0 && !_folders.containsKey(currentFolderId)) {
      // we've referenced a non existent folder
      // drop the crumbs and load the top
      breadCrumbs.length = 1;
      currentFolderId = breadCrumbs.last.id;
    }

    switch (currentFolderId) {
      case UGCView.folderHome:
        // get the recent count
        _items.add(RecentCount(await AppSettings.shared.userAccount.userDb
            .getRecentItemCountModifiedAfter(recentDate, ofTypes: recentTypes)));

        // get type totals
        final ofTypes = [
          UserItemType.note,
          UserItemType.bookmark,
          UserItemType.marginNote,
          UserItemType.highlight,
        ];

        final totals = await AppSettings.shared.userAccount.userDb.getCountOfTypes(ofTypes);

        if (totals.length == ofTypes.length) {
          _items.addAll(totals);
        } else {
          // add results + missing
          for (final ofType in ofTypes) {
            var foundItem = CountItem(ofType, 0);
            for (final total in totals) {
              if (total.itemType == ofType) {
                foundItem = total;
                break;
              }
            }
            _items.add(foundItem);
          }
        }

        // get the folders
        final folders = await AppSettings.shared.userAccount.userDb
            .getItemsWithParent(UGCView.folderHome, ofTypes: [UserItemType.folder]);

        if (folders.isNotEmpty) {
          _items
            ..add(_DividerItem())
            ..addAll(folders);
        }
        break;

      case UGCView.folderRecent:
        // add recent items with date separators...
        var date = DateTime(1900);

        for (final item in await AppSettings.shared.userAccount.userDb
            .getRecentItemsModifiedAfter(recentDate, ofTypes: recentTypes)) {
          if (!item.modifiedDT.isSameDate(date)) {
            date = item.modifiedDT;
            _items.add(_DateItem(date));
          }
          _items.add(item);
        }
        break;

      default:
        if (currentFolderId > 0) {
          // get the items in this folder
          final folderItems =
              await AppSettings.shared.userAccount.userDb.getItemsWithParent(currentFolderId);

          final folders = <UserItem>[];
          final bookmarks = <UserItem>[];
          final notes = <UserItem>[];

          for (final fi in folderItems) {
            if (fi.type == UserItemType.folder.index) {
              folders.add(fi);
            } else if (fi.type == UserItemType.bookmark.index) {
              bookmarks.add(fi);
            } else if (fi.type == UserItemType.note.index) {
              notes.add(fi);
            }
          }

          _items..addAll(folders)..addAll(bookmarks)..addAll(notes);
        } else {
          // folder id is -type... get the items of that type
          _items.addAll(await AppSettings.shared.userAccount.userDb
              .getItemsOfTypes([UserItemType.values[-currentFolderId]]));
        }

        break;
    }

    setState(() {
      searchWords = <String>[];
      items = _items;
    });

    if (items.isEmpty) {
      TecToast.show(context, '${_folderTitle(currentFolderId)} is empty!');
    }

    unawaited(_scrollWhenReady(scrollOffset));
  }

  Future<void> _scrollWhenReady(double scrollOffset, {int tries = 0}) async {
    // the animated switcher for sliding in may delay the scroll connection on start...
    if (listScrollController.hasClients) {
      listScrollController.jumpTo(scrollOffset);
    } else if (tries < 5) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollWhenReady(scrollOffset, tries: tries + 1);
      });
    }
  }

  void _itemTap(dynamic item) {
    UserItem folder;

    if (item is UserItem && item.itemType == UserItemType.folder) {
      folder = item;

      if (breadCrumbs.last.id != folder.parentId) {
        // folder tap from search ... need to add parent breadcrumbs...
        var parent = _folders[folder.parentId];
        while (parent != null && parent.id != 1) {
          breadCrumbs.insert(1, BreadCrumb(parent.id, parent.title));
          parent = _folders[parent.parentId];
        }
      }
    } else if (item is RecentCount) {
      if (item.count == 0) {
        TecToast.show(context, 'No recently created items');
        return;
      }
      folder = UserItem(id: UGCView.folderRecent, title: 'Recent', type: UserItemType.folder.index);
    } else if (item is CountItem) {
      int folderId;

      if (item.itemType == UserItemType.bookmark) {
        folderId = UGCView.folderBookmarks;
      } else if (item.itemType == UserItemType.note) {
        folderId = UGCView.folderNotes;
      } else if (item.itemType == UserItemType.marginNote) {
        folderId = UGCView.folderMarginNotes;
      } else if (item.itemType == UserItemType.highlight) {
        folderId = UGCView.folderHighlights;
      }

      if (folderId != null) {
        if (item.count == 0) {
          TecToast.show(context, 'No ${_folderTitle(folderId).toLowerCase()} created yet');
          return;
        }

        folder =
            UserItem(id: folderId, title: _folderTitle(folderId), type: UserItemType.folder.index);
      }
    }

    if (folder != null) {
      breadCrumbs.last.scrollOffset = listScrollController.offset;
      breadCrumbs.add(BreadCrumb(folder.id, folder.title));
      _load(breadCrumbs.last);
    }
  }

  String _getInitSearch() {
    if (breadCrumbs.last.id == UGCView.folderSearchResults &&
        breadCrumbs.last.folderName.contains(UGCView.filterSeparator)) {
      return breadCrumbs.last.folderName
          .substring(0, breadCrumbs.last.folderName.indexOf(UGCView.filterSeparator));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    const maxWidth = 428.0;

    // temp list to shorten consecutive hls of same color
    List<UserItem> hls;

    return SizedBox(
      width: min(maxWidth, MediaQuery.of(context).size.width),
      child: ClipRect(
        child: AnimatedSwitcher(
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              children: <Widget>[
                if (currentChild != null && _poppingView) currentChild,
                ...previousChildren,
                if (currentChild != null && !_poppingView) currentChild,
              ],
              alignment: Alignment.center,
            );
          },
          transitionBuilder: (child, animation) {
            final inOutAnimation =
                Tween<Offset>(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
                    .animate(animation);
            final stillAnimation =
                Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 0.0))
                    .animate(animation);

            Animation<Offset> slideAnimation;

            if ((child.key as ValueKey<int>).value == null) {
              // drawer is opening - first view is not ready
              slideAnimation = stillAnimation;
            } else if ((child.key as ValueKey<int>).value == currentFolderId) {
              // current view
              if (currentFolderId == 1 && !_poppingView) {
                // drawer opening - first view ready
                slideAnimation = stillAnimation;
              } else if (breadCrumbs.length > numBreadCrumbs) {
                slideAnimation = inOutAnimation;
              } else {
                // going back or same view repainting this view should not slide...
                slideAnimation = stillAnimation;
              }
              numBreadCrumbs = breadCrumbs.length;
            } else {
              // view to remove...
              if (breadCrumbs.length < numBreadCrumbs) {
                slideAnimation = inOutAnimation;
              } else {
                slideAnimation = stillAnimation;
              }
            }

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
          duration: const Duration(milliseconds: 200),
          child: Builder(
              key: ValueKey(currentFolderId),
              builder: (context) {
                if (currentFolderId == null) {
                  return Container();
                }

                return Scaffold(
                    resizeToAvoidBottomInset: false,
                    floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
                    floatingActionButton: Padding(
                      padding: EdgeInsets.only(bottom: context.fullBottomBarPadding),
                      child: FloatingActionButton(
                        child: const Icon(Icons.add),
                        tooltip: 'Create note or folder',
                        onPressed: () {
                          showCreateNoteFolder(context, _folders[currentFolderId]);
                        },
                        heroTag: null,
                      ),
                    ),
                    appBar: MinHeightAppBar(
                      appBar: AppBar(
                        elevation: 0,
                        centerTitle: true,
                        title: Text(_folderTitle(currentFolderId)),
                        leading: const BackButton(),
                      ),
                    ),
                    body: Container(
                      color: Theme.of(context).backgroundColor,
                      child: SafeArea(
                        bottom: false,
                        child: Material(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                height: 1,
                                color: Theme.of(context).textColor.withOpacity(0.6),
                              ),
                              if (breadCrumbs.length == 1 ||
                                  breadCrumbs.last.id == UGCView.folderSearchResults)
                                QuickFind(
                                  onSearch: _search,
                                  search: _getInitSearch(),
                                ),
                              if (breadCrumbs.length > 1 &&
                                  breadCrumbs.last.id != UGCView.folderSearchResults)
                                BreadCrumbRow(
                                    breadCrumbs: breadCrumbs,
                                    onTap: (crumbNumber) {
                                      breadCrumbs.length = crumbNumber + 1;
                                      _load(breadCrumbs.last, poppingView: true);
                                    }),
                              Expanded(
                                child: ListView.builder(
                                    controller: listScrollController,
                                    itemCount: items.length + 1,
                                    itemBuilder: (c, i) {
                                      IconData iconData;
                                      String title, description;
                                      Color iconColor;

                                      if (i == items.length) {
                                        return const Padding(padding: EdgeInsets.only(bottom: 20));
                                      }

                                      if (items[i] is CountItem) {
                                        switch ((items[i] as CountItem).itemType) {
                                          case UserItemType.bookmark:
                                            iconData = FeatherIcons.bookmark;
                                            title = 'Bookmarks';
                                            break;
                                          case UserItemType.note:
                                            iconData = FeatherIcons.edit2;
                                            title = 'Notes';
                                            break;
                                          case UserItemType.marginNote:
                                            iconData = TecIcons.marginNoteOutline;
                                            title = 'Margin Notes';
                                            break;
                                          case UserItemType.highlight:
                                            iconData = Icons.view_agenda_outlined;
                                            title = 'Highlights';
                                            break;
                                          default:
                                            break;
                                        }
                                      } else if (items[i] is RecentCount) {
                                        iconData = Icons.history;
                                        title = 'Recent';
                                      } else if (items[i] is UserItem) {
                                        final ui = items[i] as UserItem;
                                        switch (ui.itemType) {
                                          case UserItemType.folder:
                                            iconData = Icons.folder_outlined;
                                            title = ui.title;
                                            break;
                                          case UserItemType.note:
                                            iconData = Icons.edit_outlined;
                                            title = ui.title;
                                            // TODO(mike): when we save new format need to update this info assignment...
                                            description =
                                                ui.info.substring(ui.title.length).trimLeft();
                                            break;
                                          case UserItemType.bookmark:
                                            iconData = FeatherIcons.bookmark;
                                            title = ui.title;
                                            description = ui.description;
                                            break;
                                          case UserItemType.marginNote:
                                            iconData = TecIcons.marginNoteOutline;
                                            title = Reference(
                                                    volume: ui.volumeId,
                                                    book: ui.book,
                                                    chapter: ui.chapter,
                                                    verse: ui.verse)
                                                .label();
                                            // TODO(mike): when we save new format need to update this info assignment...
                                            description = ui.info;
                                            break;
                                          case UserItemType.highlight:
                                            // is this highlight continued...
                                            if (i + 1 < items.length &&
                                                items[i + 1] is UserItem &&
                                                items[i + 1].itemType == UserItemType.highlight) {
                                              final uiNext = items[i + 1] as UserItem;
                                              if (ui.volumeId == uiNext.volumeId &&
                                                  ui.color == uiNext.color &&
                                                  ui.book == uiNext.book &&
                                                  ui.chapter == uiNext.chapter) {
                                                if (ui.verse == (uiNext.verse - 1)) {
                                                  if (hls == null) {
                                                    hls = <UserItem>[ui, uiNext];
                                                  } else {
                                                    hls.add(uiNext);
                                                  }
                                                  return Container();
                                                } else if (ui.verse == (uiNext.verse + 1)) {
                                                  // db query returned in reverse order...
                                                  if (hls == null) {
                                                    hls = <UserItem>[uiNext, ui];
                                                  } else {
                                                    hls.insert(0, uiNext);
                                                  }
                                                  return Container();
                                                }
                                                // else uiNext is in a different range...
                                              }
                                            }

                                            iconData = Icons.view_agenda;

                                            title = Reference(
                                                    volume: ui.volumeId,
                                                    book: ui.book,
                                                    chapter: ui.chapter,
                                                    verse: (hls != null) ? hls.first.verse : ui.verse,
                                                    endVerse:
                                                        (hls != null) ? hls.last.verse : ui.verse)
                                                .label();

                                            // clear any hl range...
                                            hls = null;

                                            // final highlightType =
                                            // (ui.color == 5 || (ui.color >> 24 > 0)) ? HighlightType.underline : HighlightType.highlight;

                                            final color = (ui.color <= 5)
                                                ? defaultColorIntForIndex(ui.color)
                                                : 0xFF000000 | (ui.color & 0xFFFFFF);

                                            iconColor = isDarkTheme
                                                ? textColorWith(Color(color), isDarkMode: isDarkTheme)
                                                : highlightColorWith(Color(color),
                                                    isDarkMode: isDarkTheme);

                                            // we have reached the end of consecutive hls, clear the list
                                            hls = null;
                                            break;
                                          default:
                                            break;
                                        }
                                      } else if (items[i] is _DividerItem) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 4.0, left: 16.0, right: 16.0),
                                          child: Divider(
                                            height: 1,
                                            color: Theme.of(context).textColor,
                                          ),
                                        );
                                      } else if (items[i] is _DateItem) {
                                        final di = items[i] as _DateItem;
                                        return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0, bottom: 4.0, left: 16.0, right: 16.0),
                                            child: Text(tec.longDate(di.date),
                                                style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w500)));
                                      }

                                      final button = InkWell(
                                        onTap: () => _itemTap(items[i]),
                                        child: Padding(
                                          padding: (currentFolderId == UGCView.folderHome ||
                                                  (items[i] is UserItem &&
                                                      items[i].itemType == UserItemType.folder))
                                              ? const EdgeInsets.all(8.0)
                                              : const EdgeInsets.only(
                                                  left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0, left: 10.0, right: 10.0),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 13.0),
                                                    child: Icon(iconData, color: iconColor),
                                                  ),
                                                  if (description != null)
                                                    Expanded(
                                                        child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        TecSearchResult(
                                                          textScaleFactor: 0.9 *
                                                              contentTextScaleFactorWith(context),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.ellipsis,
                                                          text: description,
                                                          title: title,
                                                          lFormattedKeywords: searchWords,
                                                        ),
                                                        if (items[i] is UserItem)
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 4.0),
                                                            child: Row(
                                                              children: [
                                                                if ((items[i] as UserItem).parentId >
                                                                    0)
                                                                  Row(
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            right: 3.0),
                                                                        child: Icon(
                                                                            Icons.folder_outlined,
                                                                            size: 16,
                                                                            color: Colors.blue),
                                                                      ),
                                                                      Text(
                                                                        _folders[items[i].parentId]
                                                                            .title,
                                                                        style: const TextStyle(
                                                                            fontSize: 14.0),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                if (currentFolderId !=
                                                                    UGCView.folderRecent)
                                                                  Expanded(
                                                                      child: Text(
                                                                    tec.shortDate(
                                                                        (items[i] as UserItem)
                                                                            .modifiedDT),
                                                                    textAlign: TextAlign.end,
                                                                    style: const TextStyle(
                                                                        fontSize: 14.0),
                                                                  )),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ))
                                                  else if (title != null)
                                                    Expanded(
                                                      child: TecSearchResult(
                                                        textScaleFactor:
                                                            0.9 * contentTextScaleFactorWith(context),
                                                        maxLines: 3,
                                                        overflow: TextOverflow.ellipsis,
                                                        text: title,
                                                        lFormattedKeywords: searchWords,
                                                      ),
                                                    ),
                                                  if (items[i] is CountItem ||
                                                      items[i] is RecentCount)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 16.0),
                                                      child: Text(items[i].count.toString(),
                                                          style: const TextStyle(fontSize: 18.0)),
                                                    ),
                                                  if (items[i] is UserItem &&
                                                      items[i].itemType == UserItemType.folder)
                                                    const Icon(
                                                      Icons.navigate_next,
                                                    )
                                                ]),
                                          ),
                                        ),
                                      );

                                      if (items[i] is UserItem) {
                                        var message = '';
                                        if (items[i].type == UserItemType.folder.index) {
                                          message +=
                                              'EVERYTHING stored in this folder will also be deleted. ';
                                        }
                                        message += 'This action cannot be undone.';
                                        return Dismissible(
                                          key: ValueKey((items[i] as UserItem).id),
                                          confirmDismiss: (direction) async {
                                            return tecShowSimpleAlertDialog<bool>(
                                                context: context,
                                                title: 'Delete $title?',
                                                content: message,
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop(true);
                                                        await AppSettings.shared.userAccount.userDb
                                                            .deleteItem(items[i] as UserItem);
                                                      },
                                                      child: const Text('Delete')),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false);
                                                      },
                                                      child: const Text('Cancel'))
                                                ]);
                                          },
                                          direction: DismissDirection.endToStart,
                                          background: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            alignment: Alignment.centerRight,
                                            child: const Icon(
                                              FeatherIcons.trash2,
                                              color: Colors.red,
                                            ),
                                          ),
                                          onDismissed: (direction) async {
                                            setState(() {
                                              items.removeAt(i);
                                            });
                                          },
                                          child: button,
                                        );
                                      } else {
                                        return button;
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
              }),
        ),
      ),
    );
  }
}

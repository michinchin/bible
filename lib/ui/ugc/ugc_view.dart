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
import '../../models/ugc/recent_count.dart';
import '../common/common.dart';
import 'bread_crumb_row.dart';
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

  const UGCView({Key key}) : super(key: key);

  @override
  _UGCViewState createState() => _UGCViewState();
}

Map<int, UserItem> _folders;

class _UGCViewState extends State<UGCView> {
  List<BreadCrumb> breadCrumbs;
  int currentFolderId;
  List items;
  final recentDate = DateTime.now().add(const Duration(days: -31));
  final recentTypes = [
    UserItemType.note,
    UserItemType.bookmark,
    UserItemType.marginNote,
    UserItemType.highlight
  ];

  @override
  void initState() {
    super.initState();
    items = <dynamic>[];
    breadCrumbs = <BreadCrumb>[BreadCrumb(UGCView.folderHome, 'Top')];
    _load(UGCView.folderHome);
  }

  Future<void> _search(String s) async {
    if (s.isEmpty) {
      unawaited(_load(currentFolderId));
      return;
    }

    final _items = <dynamic>[];

    // clear any current view...
    setState(() {
      items = _items;
    });
  }

  Future<void> _load(int folderId) async {
    currentFolderId = folderId;
    final _items = <dynamic>[];

    // clear any current view...
    setState(() {
      items = _items;
    });

    _folders ??= <int, UserItem>{};

    // this view can be loaded multiple times... only load folders when necessary
    if (_folders.isEmpty) {
      for (final ui
          in await AppSettings.shared.userAccount.userDb.getItemsOfTypes([UserItemType.folder])) {
        _folders.putIfAbsent(ui.id, () => ui);
      }

      _folders.putIfAbsent(
          1, () => UserItem(id: 1, title: 'Journal', type: UserItemType.folder.index));
    }

    switch (folderId) {
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
          _items.add(_DividerItem());
          // ignore: cascade_invocations
          _items.addAll(folders);
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
        if (folderId > 0) {
          // get the items in this folder
          final folderItems =
              await AppSettings.shared.userAccount.userDb.getItemsWithParent(folderId);

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

          _items.addAll(folders);
          // ignore: cascade_invocations
          _items.addAll(bookmarks);
          // ignore: cascade_invocations
          _items.addAll(notes);
        } else {
          // folder id is -type... get the items of that type
          _items.addAll(await AppSettings.shared.userAccount.userDb
              .getItemsOfTypes([UserItemType.values[-folderId]]));
        }

        break;
    }

    setState(() {
      items = _items;
    });
  }

  void _itemTap(dynamic item) {
    UserItem folder;

    if (item is UserItem && item.itemType == UserItemType.folder) {
      folder = item;
    } else if (item is RecentCount) {
      folder = UserItem(id: UGCView.folderRecent, title: 'Recent', type: UserItemType.folder.index);
    } else if (item is CountItem) {
      if (item.itemType == UserItemType.bookmark) {
        folder = UserItem(
            id: UGCView.folderBookmarks, title: 'Bookmarks', type: UserItemType.folder.index);
      }
      if (item.itemType == UserItemType.bookmark) {
        folder = UserItem(
            id: UGCView.folderBookmarks, title: 'Bookmarks', type: UserItemType.folder.index);
      } else if (item.itemType == UserItemType.note) {
        folder = UserItem(id: UGCView.folderNotes, title: 'Notes', type: UserItemType.folder.index);
      } else if (item.itemType == UserItemType.marginNote) {
        folder = UserItem(
            id: UGCView.folderMarginNotes, title: 'Margin Notes', type: UserItemType.folder.index);
      } else if (item.itemType == UserItemType.highlight) {
        folder = UserItem(
            id: UGCView.folderHighlights, title: 'Highlights', type: UserItemType.folder.index);
      }
    }

    if (folder != null) {
      breadCrumbs.add(BreadCrumb(folder.id, folder.title));
      _load(folder.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // temp list to shorten consecutive hls of same color
    List<UserItem> hls;

    return SizedBox(
      width: min(420, MediaQuery.of(context).size.width),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: MinHeightAppBar(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: const Text('Journal'),
              leading: InkWell(
                child: const Icon(Icons.close),
                onTap: () => Navigator.of(context).pop(),
              ),
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
                    if (breadCrumbs.length == 1) QuickFind(onSearch: _search),
                    if (breadCrumbs.length > 1)
                      BreadCrumbRow(
                          breadCrumbs: breadCrumbs,
                          onTap: (crumbNumber) {
                            breadCrumbs.length = crumbNumber + 1;
                            _load(breadCrumbs[crumbNumber].id);
                          }),
                    Expanded(
                      child: ListView.builder(
                          itemCount: items.length + 1,
                          itemBuilder: (c, i) {
                            IconData iconData;
                            String title, subtitle;
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
                                  subtitle = ui.description;
                                  break;
                                case UserItemType.bookmark:
                                  iconData = FeatherIcons.bookmark;
                                  title = ui.title;
                                  subtitle = ui.description;
                                  break;
                                case UserItemType.marginNote:
                                  iconData = TecIcons.marginNoteOutline;
                                  title = Reference(
                                          volume: ui.volumeId,
                                          book: ui.book,
                                          chapter: ui.chapter,
                                          verse: ui.verse)
                                      .label();
                                  subtitle = ui.info;
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
                                          endVerse: (hls != null) ? hls.last.verse : ui.verse)
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
                                      : highlightColorWith(Color(color), isDarkMode: isDarkTheme);

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
                                          fontWeight: FontWeight.w500))
                                  // isSmallScreen(context)
                                  //     ? Text(tec.longDate(di.date),
                                  //         style: const TextStyle(
                                  //             fontSize: 18.0,
                                  //             fontStyle: FontStyle.italic,
                                  //             fontWeight: FontWeight.w500))
                                  //     : Column(
                                  //         crossAxisAlignment: CrossAxisAlignment.start,
                                  //         children: [
                                  //           Divider(
                                  //             height: 1,
                                  //             color: Theme.of(context).textColor,
                                  //           ),
                                  //           Padding(
                                  //             padding: const EdgeInsets.only(top: 12.0),
                                  //             child: Text(tec.longDate(di.date),
                                  //                 style: const TextStyle(
                                  //                     fontSize: 18.0,
                                  //                     fontStyle: FontStyle.italic,
                                  //                     fontWeight: FontWeight.w500)),
                                  //           ),
                                  //         ],
                                  //       ),
                                  );
                            }

                            return InkWell(
                              onTap: () => _itemTap(items[i]),
                              child: Padding(
                                padding: (currentFolderId == UGCView.folderHome ||
                                        (items[i] is UserItem &&
                                            items[i].itemType == UserItemType.folder))
                                    ? const EdgeInsets.all(8.0)
                                    : const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                                  child: Row(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 13.0),
                                      child: Icon(iconData, color: iconColor),
                                    ),
                                    if (subtitle != null)
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title,
                                              maxLines: 1, style: const TextStyle(fontSize: 18.0)),
                                          Container(height: 3.0),
                                          Text(subtitle,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 15.0)),
                                          if (items[i] is UserItem)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Row(
                                                children: [
                                                  if ((items[i] as UserItem).parentId > 0)
                                                    Row(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(right: 3.0),
                                                          child: Icon(Icons.folder_outlined,
                                                              size: 16, color: Colors.blue),
                                                        ),
                                                        Text(
                                                          _folders[items[i].parentId].title,
                                                          style: const TextStyle(fontSize: 14.0),
                                                        ),
                                                      ],
                                                    ),
                                                  if (currentFolderId != UGCView.folderRecent)
                                                    Expanded(
                                                        child: Text(
                                                      tec.shortDate(
                                                          (items[i] as UserItem).modifiedDT),
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(fontSize: 14.0),
                                                    )),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ))
                                    else if (title != null)
                                      Expanded(
                                          child:
                                              Text(title, style: const TextStyle(fontSize: 18.0))),
                                    if (items[i] is CountItem || items[i] is RecentCount)
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
                          }),
                    ),
                  ],
                ),
              ),
            ),
          )
          // body: ListView.separated(
          //     itemCount: items.length + 1,
          //     separatorBuilder: (c, i) => const Divider(),
          //     itemBuilder: (c, i) {
          //       if (i == 0) {
          //         return ListTile(
          //           title: const Text('Add Note'),
          //           leading: const Icon(Icons.add),
          //           onTap: () => Navigator.of(context).push(
          //             TecPageRoute<NoteView>(
          //               builder: (c) => noteViewBuilder(c, items.length),
          //             ),
          //           ),
          //         );
          //       }
          //       i--;
          //       return Dismissible(
          //         key: UniqueKey(),
          //         background: Container(
          //           color: Colors.red,
          //           child: const Icon(Icons.delete),
          //         ),
          //         onDismissed: (direction) {
          //           // bloc.remove(i);
          //         },
          //         child: ListTile(
          //           // first line of note is made to be the title
          //           title: const Text('title goes here'),
          //           onTap: () => Navigator.of(context).push(TecPageRoute<NoteView>(
          //             builder: (c) => noteViewBuilder(c, i),
          //           )),
          //         ),
          //       );
          //     }),
          ),
    );
  }
}

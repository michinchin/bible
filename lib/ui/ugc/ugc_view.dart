import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/color_utils.dart';
import '../../models/ugc/recent_count.dart';
import '../../models/ugc/ugc_view_data.dart';
import '../common/common.dart';
import '../menu/view_actions.dart';

class ViewableUGC extends Viewable {
  ViewableUGC(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return _UGCView(state, size);
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) => 'Notes';

  @override
  Future<ViewData> dataForNewView({BuildContext context, int currentViewId}) =>
      Future.value(const UGCViewData(UGCViewData.folderHome));
}

class _DividerItem {}

class _UGCView extends StatefulWidget {
  final UserItem folder;
  final ViewState state;
  final Size size;

  const _UGCView(this.state, this.size, {this.folder});

  @override
  _UGCViewState createState() => _UGCViewState();
}

Map<int, UserItem> _folders;

class _UGCViewState extends State<_UGCView> {
  int folderId;
  String folderName;
  List items;
  final recentDate = DateTime.now().add(const Duration(days: -30));
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
    _folders ??= <int, UserItem>{};

    if (widget.folder != null) {
      folderId = widget.folder.id;
      folderName = widget.folder.title;
    } else {
      folderId = UGCViewData.fromContext(context, widget.state.uid).folderId;
      folderName = 'My Content';
    }

    _load();
  }

  Future<void> _load() async {
    final _items = <dynamic>[];

    if (_folders.isEmpty) {
      for (final ui
          in await AppSettings.shared.userAccount.userDb.getItemsOfTypes([UserItemType.folder])) {
        _folders.putIfAbsent(ui.id, () => ui);
      }

      _folders.putIfAbsent(
          1, () => UserItem(id: 1, title: 'My Content', type: UserItemType.folder.index));
    }

    switch (folderId) {
      case UGCViewData.folderHome:
        // get the recent count
        _items.add(RecentCount(await AppSettings.shared.userAccount.userDb
            .getRecentItemCountModifiedAfter(recentDate, ofTypes: recentTypes)));

        // get type totals
        final ofTypes = [
          UserItemType.note,
          UserItemType.bookmark,
          UserItemType.marginNote,
          UserItemType.highlight,
          UserItemType.license,
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

        _items.add(_DividerItem());

        // get the folders
        _items.addAll(await AppSettings.shared.userAccount.userDb
            .getItemsWithParent(UGCViewData.folderHome, ofTypes: [UserItemType.folder]));
        break;

      case UGCViewData.folderRecent:
        _items.addAll(await AppSettings.shared.userAccount.userDb
            .getRecentItemsModifiedAfter(recentDate, ofTypes: recentTypes));
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
      folder =
          UserItem(id: UGCViewData.folderRecent, title: 'Recent', type: UserItemType.folder.index);
    } else if (item is CountItem) {
      if (item.itemType == UserItemType.bookmark) {
        folder = UserItem(
            id: UGCViewData.folderBookmarks, title: 'Bookmarks', type: UserItemType.folder.index);
      }
      if (item.itemType == UserItemType.bookmark) {
        folder = UserItem(
            id: UGCViewData.folderBookmarks, title: 'Bookmarks', type: UserItemType.folder.index);
      } else if (item.itemType == UserItemType.note) {
        folder =
            UserItem(id: UGCViewData.folderNotes, title: 'Notes', type: UserItemType.folder.index);
      } else if (item.itemType == UserItemType.marginNote) {
        folder = UserItem(
            id: UGCViewData.folderMarginNotes,
            title: 'Margin Notes',
            type: UserItemType.folder.index);
      } else if (item.itemType == UserItemType.highlight) {
        folder = UserItem(
            id: UGCViewData.folderHighlights, title: 'Highlights', type: UserItemType.folder.index);
      }
    }

    if (folder != null) {
      Navigator.of(context).push(TecPageRoute<_UGCView>(
          builder: (c) => _UGCView(widget.state, widget.size, folder: folder)));
    }
  }

  List<Widget> _actions(BuildContext context) {
    if (widget.state != null) {
      return defaultActionsBuilder(context, widget.state, widget.size);
    } else {
      return defaultActionsBuilder(context, widget.state, widget.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final halfColor = Theme.of(context).textColor.withOpacity(0.5);
    final color = Theme.of(context).textColor;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // temp list to shorten consecutive hls of same color
    List<UserItem> hls;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MinHeightAppBar(
          appBar: AppBar(
            centerTitle: true,
            title: Text(folderName, style: TextStyle(color: halfColor)),
            actions: _actions(context),
            iconTheme: Theme.of(context).iconTheme.copyWith(color: halfColor),
          ),
        ),
        body: Container(
          color: isDarkTheme ? Colors.black : Colors.white,
          child: ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (c, i) {
                if (i == items.length) {
                  // padding at the end of the list...
                  return Container(height: 80);
                }

                IconData iconData;
                String title, subtitle;
                var iconColor = color;

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
                    case UserItemType.license:
                      iconData = Icons.local_library_outlined;
                      title = 'Licenses';
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
                          } else if (ui.verse == (uiNext.verse + 1)) {
                            // db query returned in reverse order...
                            if (hls == null) {
                              hls = <UserItem>[uiNext, ui];
                            } else {
                              hls.insert(0, uiNext);
                            }
                          }
                          return Container();
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
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0, left: 16.0, right: 16.0),
                    child: Divider(
                      height: 1,
                      color: color,
                    ),
                  );
                }

                return InkWell(
                  onTap: () => _itemTap(items[i]),
                  child: Padding(
                    padding: (folderId == UGCViewData.folderHome ||
                            (items[i] is UserItem && items[i].itemType == UserItemType.folder))
                        ? const EdgeInsets.all(8.0)
                        : const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                      child: Row(children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(iconData, color: iconColor),
                        ),
                        if (subtitle != null)
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    // fontWeight: FontWeight.bold,
                                    color: color,
                                  )),
                              Container(height: 3.0),
                              Text(subtitle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 15.0, color: color)),
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
                                              style: TextStyle(fontSize: 14.0, color: color),
                                            ),
                                          ],
                                        ),
                                      Expanded(
                                          child: Text(
                                        tec.shortDate((items[i] as UserItem).modifiedDT),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(fontSize: 14.0, color: color),
                                      )),
                                    ],
                                  ),
                                ),
                            ],
                          ))
                        else if (title != null)
                          Expanded(
                              child: Text(title,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    // fontWeight: FontWeight.bold,
                                    color: color,
                                  ))),
                        if (items[i] is CountItem || items[i] is RecentCount)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(items[i].count.toString(),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  // fontWeight: FontWeight.bold,
                                  color: color,
                                )),
                          ),
                        if (items[i] is UserItem && items[i].itemType == UserItemType.folder)
                          Icon(
                            Icons.navigate_next,
                            color: color,
                          )
                      ]),
                    ),
                  ),
                );
              }),
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
        );
  }
}

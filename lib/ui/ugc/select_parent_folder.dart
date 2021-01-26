import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../common/common.dart';

Future<UserItem> selectParentFolder(BuildContext context, int currentFolderId) async {
  return showTecDialog<UserItem>(
      context: context,
      useRootNavigator: true,
      padding: EdgeInsets.zero,
      maxWidth: 500,
      maxHeight: max(500.0, (MediaQuery.of(context)?.size?.height ?? 700) - 40),
      makeScrollable: false,
      builder: (context) => _SelectParentFolder(
            initFolderId: currentFolderId,
          ));
}

class _SelectParentFolder extends StatefulWidget {
  final int initFolderId;

  const _SelectParentFolder({Key key, this.initFolderId}) : super(key: key);

  @override
  __SelectParentFolderState createState() => __SelectParentFolderState();
}

class __SelectParentFolderState extends State<_SelectParentFolder> {
  UserItem currentFolder;
  List<UserItem> subFolders;

  @override
  Widget build(BuildContext context) {
    if (subFolders == null) {
      return Container();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: MinHeightAppBar(
        appBar: AppBar(
          title: Text('Create in: ${currentFolder.title}'),
          leading: currentFolder.id == 1
              ? const CloseButton()
              : BackButton(
                  onPressed: () {
                    _load(currentFolder.parentId);
                  },
                ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            if (subFolders.isEmpty)
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 14.0),
                child: Text(
                  'There are no sub folders in ${currentFolder.title}. Tap select to create in this folder.',
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              )),
            if (subFolders.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: subFolders?.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 14.0),
                      child: InkWell(
                        child: Row(children: [
                          const Icon(Icons.folder_outlined),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              subFolders[index].title,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ]),
                        onTap: () {
                          _load(subFolders[index].id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ButtonBar(
              children: [
                FlatButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    }),
                FlatButton(
                    child: const Text('Select'),
                    onPressed: () {
                      Navigator.of(context).pop(currentFolder);
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load(widget.initFolderId);
  }

  Future<void> _load(int folderId) async {
    UserItem folder;
    List<UserItem> folders;

    if (folderId == 1) {
      folder = UserItem(id: 1, title: 'Journal', type: UserItemType.folder.index);
    } else {
      folder = await AppSettings.shared.userAccount.userDb.getItem(folderId);
    }

    folders = await AppSettings.shared.userAccount.userDb
        .getItemsWithParent(folderId, ofTypes: [UserItemType.folder]);

    if (folder.id == 1 && folders.isEmpty) {
      TecToast.show(context, 'No folders created yet');
      Navigator.of(context).pop();
    } else {
      setState(() {
        currentFolder = folder;
        subFolders = folders;
      });
    }
  }
}

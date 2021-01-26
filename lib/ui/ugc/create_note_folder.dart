import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import 'folder_bloc.dart';
import 'select_parent_folder.dart';

void showCreateNoteFolder(BuildContext context, UserItem currentFolder) {
  tecShowSimpleAlertDialog<void>(
    context: context,
    content: 'New folder or note?',
    actions: [
      FlatButton(
          child: const Text('Folder'),
          onPressed: () {
            Navigator.of(context).pop();
            _showCreateFolder(context, currentFolder);
          }),
      FlatButton(
          child: const Text('Note'),
          onPressed: () {
            Navigator.of(context).pop();
            TecToast.show(context, 'create note not implemented yet.');
          }),
    ],
  );
}

Future<void> _showCreateFolder(BuildContext context, UserItem parentFolder) async {
  final newFolder = await showDialog<FolderState>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (builder) {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
        content: BlocProvider<FolderBloc>(
          create: (context) => FolderBloc(FolderState(name: '', parent: parentFolder)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20, right: 20, bottom: 24),
                  child: CreateNoteFolder(),
                ),
                ButtonBar(children: [
                  FlatButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      }),
                  FlatButton(
                      child: const Text('Create'),
                      onPressed: () {
                        final name = BlocProvider.of<FolderBloc>(context).state.name.trim();
                        if (name.isEmpty) {
                          TecToast.show(context, 'No folder name');
                          return;
                        }

                        Navigator.of(context).pop(BlocProvider.of<FolderBloc>(context).state);
                      }),
                ])
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      );
    },
  );

  if (newFolder != null && newFolder.name.isNotEmpty) {
    // create the folder
    await AppSettings.shared.userAccount.userDb.saveItem(
        UserItem.from(
            type: UserItemType.folder, parentId: newFolder.parent.id, title: newFolder.name),
        appendPosition: true);
  }
}

class CreateNoteFolder extends StatefulWidget {
  const CreateNoteFolder({Key key}) : super(key: key);

  @override
  _CreateNoteFolderState createState() => _CreateNoteFolderState();
}

class _CreateNoteFolderState extends State<CreateNoteFolder> {
  UserItem parentFolder;
  bool foldersExist;
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    parentFolder = BlocProvider.of<FolderBloc>(context).state.parent;
    foldersExist = false;
    controller = TextEditingController();
    getFolderCount();
  }

  Future<void> getFolderCount() async {
    final folders =
        await AppSettings.shared.userAccount.userDb.getItemsOfTypes([UserItemType.folder]);
    if (folders.length > 1 || (folders.length == 1 && folders[0].id != 1)) {
      setState(() {
        foldersExist = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1.color;
    var style = Theme.of(context).textTheme.subtitle1;

    if (foldersExist) {
      style = style.copyWith(color: Theme.of(context).primaryColor);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Create new folder in:', style: Theme.of(context).textTheme.subtitle1),
            FlatButton(
                minWidth: 0,
                padding: const EdgeInsets.only(left: 8, top: 10, right: 14, bottom: 10),
                onPressed: foldersExist
                    ? () async {
                        final newParent = await selectParentFolder(context, parentFolder.id);
                        if (newParent != null && newParent.id != parentFolder.id) {
                          setState(() {
                            parentFolder = newParent;
                          });
                        }
                      }
                    : null,
                child: Text(parentFolder.title, style: style)),
          ],
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).textTheme.bodyText1.color.withOpacity(.1),
              borderRadius: BorderRadius.circular(5.0)),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  onSubmitted: (value) {
                    // when submitted - assume completed - either create or cancel
                    Navigator.of(context)
                        .pop(FolderState(name: value.trim(), parent: parentFolder));
                  },
                  autofocus: true,
                  controller: controller,
                  style: Theme.of(context).appBarTheme.textTheme.bodyText1,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.folder_outlined, color: textColor),
                    border: InputBorder.none,
                    hintText: 'Name',
                    hintStyle: Theme.of(context).appBarTheme.textTheme.bodyText1.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodyText1.color.withOpacity(.7)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

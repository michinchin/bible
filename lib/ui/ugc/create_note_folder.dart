import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

void showCreateNoteFolder(BuildContext context) {
  tecShowSimpleAlertDialog<void>(
    context: context,
    content: 'New folder or note?',
    actions: [
      FlatButton(
          child: const Text('Folder'),
          onPressed: () {
            Navigator.of(context).pop();
            _showCreateFolder(context);
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

void _showCreateFolder(BuildContext context) {
  tecShowAlertDialog<void>(
    barrierDismissible: true,
    scrollContentAndActions: true,
    context: context,
    content: CreateNoteFolder(),
    actions: [
      FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      FlatButton(
          child: const Text('Create'),
          onPressed: () {
            Navigator.of(context).pop();
          }),
    ],
  );
}

class CreateNoteFolder extends StatefulWidget {
  @override
  _CreateNoteFolderState createState() => _CreateNoteFolderState();
}

class _CreateNoteFolderState extends State<CreateNoteFolder> {
  String parentFolder;

  @override
  void initState() {
    super.initState();
    parentFolder = 'Top';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1.color;
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
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                child: Text(parentFolder,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Theme.of(context).primaryColor))),
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
                  // focusNode: _focusNode,
                  // controller: _controller,
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

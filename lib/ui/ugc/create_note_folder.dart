import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../common/tec_dialog.dart';

void showCreateNoteFolder(BuildContext context) {
  tecShowSimpleAlertDialog<void>(
    context: context,
    content: 'New folder or note?',
    actions: [
      FlatButton(
          child: const Text('Folder'),
          onPressed: () {
            Navigator.of(context).pop();
            showTecDialog<void>(
                maxWidth: 320,
                maxHeight: 300,
                padding: const EdgeInsets.only(top: 14),
                context: context,
                builder: (c) => CreateNoteFolder());
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
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text('New folder', style: Theme.of(context).textTheme.headline6),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 14),
          child: Container(
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
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Text('Parent folder:'),
            ),
            DropdownButton<String>(
              value: parentFolder,
              // icon: Icon(Icons.arrow_downward, color: Theme.of(context).primaryColor),
              iconSize: 0,
              elevation: 16,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Theme.of(context).primaryColor),
              underline: Container(
                height: 0,
              ),
              onChanged: (String newValue) {
                setState(() {
                  parentFolder = newValue;
                });
              },
              items: <String>['One', 'Top', 'Two', 'Free', 'Four', 'One1', 'Top1', 'Two1', 'Free1', 'Four1', 'One2', 'Top2', 'Two2', 'Free2', 'Four2', 'One3', 'Top3', 'Two3', 'Free3', 'Four3']
                  .map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FlatButton(
                textTheme: ButtonTextTheme.primary,
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                child: const Text('Cancel')),
            FlatButton(
                textTheme: ButtonTextTheme.primary,
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                child: const Text('Create')),
          ],
        ),
      ],
    );
  }
}

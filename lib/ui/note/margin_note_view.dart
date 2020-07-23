import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:zefyr/zefyr.dart';

import '../../blocs/margin_notes/margin_note.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../misc/view_actions.dart';
import 'tec_image_delegate.dart';

const marginNoteViewTypeName = 'MarginNoteView';

Widget marginNoteScaffoldBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
    _MarginNoteView(key: bodyKey, state: state, size: size);

class _MarginNoteView extends StatefulWidget {
  final ViewState state;
  final Size size;

  const _MarginNoteView({Key key, this.state, this.size}) : super(key: key);

  @override
  __MarginNoteScreenState createState() => __MarginNoteScreenState();
}

class __MarginNoteScreenState extends State<_MarginNoteView> {
  NotusDocument doc;
  UserItem item;
  var _editMode = false;
  var _restoreSize = false;
  ViewManagerBloc viewManagerBloc;
  SheetManagerBloc sheetManagerBloc;

  Future<void> load() async {
    viewManagerBloc = context.bloc<ViewManagerBloc>();
    sheetManagerBloc = context.bloc<SheetManagerBloc>();

    item = await AppSettings.shared.userAccount.userDb
        .getItem(int.parse(widget.state.data));

    if (item?.type == UserItemType.marginNote.index) {
      Delta delta;

      // we're showing an existing marginNote
      if (item.info.startsWith('QuillDelta')) {} else {
        // old margin note - create a delta
        delta = Delta();
        for (final s in item.info.trim().split('\n')) {
          if (s.isNotEmpty) {
            delta.insert(s);
          }
          delta.insert('\n');
        }
      }

      setState(() {
        doc = NotusDocument.fromDelta(delta);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void _toggleEditMode() {
    final maximized = viewManagerBloc?.state?.maximizedViewUid == widget.state.uid;

    if (!_editMode && !maximized) {
      // going into edit mode - make sure window is maximized
      _restoreSize = true;
      viewManagerBloc?.add(ViewManagerEvent.maximize(widget.state.uid));
      // give the window manager some time to maximize
      Future.delayed(const Duration(milliseconds: 250), _toggleEditMode);
      return;
    }

    setState(() {
      _editMode = !_editMode;
    });

    if (_editMode) {
      sheetManagerBloc?.changeType(SheetType.collapsed);
    } else {
      sheetManagerBloc?.toDefaultView();

      if (maximized && _restoreSize) {
        // coming out of edit mode and window was forced into maximize mode - restore it
        _restoreSize = false;

        // let the keyboard drop then...
        Future.delayed(const Duration(milliseconds: 250), () {
          viewManagerBloc?.add(const ViewManagerEvent.restore());
        });
      }

      _restoreSize = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ManagedViewAppBar(
        appBar: AppBar(
          title: (doc == null) ? null : Text(MarginNote.getTitle(item)),
          leading: (!_editMode) ? null : IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'End editing',
            onPressed: () => { _toggleEditMode() },
          ),
          actions: marginNoteActionsBuilder(widget.key, widget.size),
        ),
      ),
      body: bodyBuilder(),
    );
  }

  Widget bodyBuilder() {
    if (doc == null) {
      return Container();
    }

    if (_editMode) {
      return EditScreen(doc);
    } else {
      return GestureDetector(
        onTap: _toggleEditMode,
        child: ViewScreen(doc),
      );
    }
  }

  List<Widget> marginNoteActionsBuilder(Key bodyKey, Size size) {
    if (_editMode) {
      return [
        IconButton(
            icon: const Icon(FeatherIcons.trash2),
            tooltip: 'Delete Note',
            onPressed: () {
              // delete the note
              tecShowSimpleAlertDialog<void>(
                  context: context,
                  content: 'Delete note?',
                  useRootNavigator: true,
                  actions: <Widget>[
                    TecDialogButton(
                      child: const TecText('Delete'),
                      onPressed: () async {
                        await Navigator.of(context, rootNavigator: true).maybePop();

                        // delete this margin note
                        await AppSettings.shared.userAccount.userDb.deleteItem(item);

                        // close the note view
                        viewManagerBloc?.add(ViewManagerEvent.remove(widget.state.uid));
                      },
                    ),
                    TecDialogButton(
                      child: const TecText('Cancel'),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).maybePop();
                      },
                    ),
                  ]);
            }),
      ];
    } else {
      return defaultActionsBuilder(context, bodyKey, widget.state, size);
    }
  }
}

//const doc =
//    r'[{"insert":"Zefyr"},{"insert":"\n","attributes":{"heading":1}},{"insert":"Soft and gentle rich text editing for Flutter applications.","attributes":{"i":true}},{"insert":"\n"},{"insert":"​","attributes":{"embed":{"type":"image","source":"asset://assets/breeze.jpg"}}},{"insert":"\n"},{"insert":"Photo by Hiroyuki Takeda.","attributes":{"i":true}},{"insert":"\nZefyr is currently in "},{"insert":"early preview","attributes":{"b":true}},{"insert":". If you have a feature request or found a bug, please file it at the "},{"insert":"issue tracker","attributes":{"a":"https://github.com/memspace/zefyr/issues"}},{"insert":'
//    r'".\nDocumentation"},{"insert":"\n","attributes":{"heading":3}},{"insert":"Quick Start","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/quick_start.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Data Format and Document Model","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/data_and_document.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Style Attributes","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/attr'
//    r'ibutes.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Heuristic Rules","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/heuristics.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"FAQ","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/faq.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Clean and modern look"},{"insert":"\n","attributes":{"heading":2}},{"insert":"Zefyr’s rich text editor is built with simplicity and fle'
//    r'xibility in mind. It provides clean interface for distraction-free editing. Think Medium.com-like experience.\nMarkdown inspired semantics"},{"insert":"\n","attributes":{"heading":2}},{"insert":"Ever needed to have a heading line inside of a quote block, like this:\nI’m a Markdown heading"},{"insert":"\n","attributes":{"block":"quote","heading":3}},{"insert":"And I’m a regular paragraph"},{"insert":"\n","attributes":{"block":"quote"}},{"insert":"Code blocks"},{"insert":"\n","attributes":{"headin'
//    r'g":2}},{"insert":"Of course:\nimport ‘package:flutter/material.dart’;"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"import ‘package:zefyr/zefyr.dart’;"},{"insert":"\n\n","attributes":{"block":"code"}},{"insert":"void main() {"},{"insert":"\n","attributes":{"block":"code"}},{"insert":" runApp(MyZefyrApp());"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"}"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"\n\n\n"}]';
//
//Delta getDelta() {
//  return Delta.fromJson(json.decode(doc) as List);
//}
//final doc = NotusDocument.fromDelta(getDelta());

class EditScreen extends StatefulWidget {
  final NotusDocument doc;

  const EditScreen(this.doc);

  @override
  _EditScreen createState() => _EditScreen();
}

class _EditScreen extends State<EditScreen> {
  FocusNode _focusNode;
  ZefyrController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ZefyrController(widget.doc);
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return ZefyrScaffold(
      child: ZefyrEditor(
        padding: const EdgeInsets.all(16),
        controller: _controller,
        focusNode: _focusNode,
        imageDelegate: TecImageDelegate(),
      ),
    );
  }
}

class ViewScreen extends StatefulWidget {
  final NotusDocument doc;

  const ViewScreen(this.doc);

  @override
  _ViewScreen createState() => _ViewScreen();
}

class _ViewScreen extends State<ViewScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ZefyrView(
            document: widget.doc,
            imageDelegate: TecImageDelegate(),
          ),
        )
      ],
    );
  }
}

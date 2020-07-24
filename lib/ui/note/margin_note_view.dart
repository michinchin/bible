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

Widget marginNoteScaffoldBuilder(BuildContext context, ViewState state, Size size) =>
    _MarginNoteView(state: state, size: size);

class _MarginNoteView extends StatefulWidget {
  final ViewState state;
  final Size size;

  const _MarginNoteView({Key key, this.state, this.size}) : super(key: key);

  @override
  __MarginNoteScreenState createState() => __MarginNoteScreenState();
}

class ToolbarDelegate implements ZefyrToolbarDelegate {
  static const kDefaultButtonIcons = {
    ZefyrToolbarAction.bold: Icons.format_bold,
    ZefyrToolbarAction.italic: Icons.format_italic,
    ZefyrToolbarAction.heading: Icons.format_size,
    ZefyrToolbarAction.bulletList: Icons.format_list_bulleted,
    ZefyrToolbarAction.numberList: Icons.format_list_numbered,
    ZefyrToolbarAction.quote: Icons.format_quote,
  };

  static const kIgnoreButtonIcons = {
    ZefyrToolbarAction.link: Icons.link,
    ZefyrToolbarAction.unlink: Icons.link_off,
    ZefyrToolbarAction.clipboardCopy: Icons.content_copy,
    ZefyrToolbarAction.horizontalRule: Icons.remove,
    ZefyrToolbarAction.openInBrowser: Icons.open_in_new,
    ZefyrToolbarAction.code: Icons.code,
    ZefyrToolbarAction.image: Icons.photo,
    ZefyrToolbarAction.cameraImage: Icons.photo_camera,
    ZefyrToolbarAction.galleryImage: Icons.photo_library,
    ZefyrToolbarAction.hideKeyboard: Icons.keyboard_hide,
    ZefyrToolbarAction.close: Icons.close,
    ZefyrToolbarAction.confirm: Icons.check,
  };

  static const kSpecialIconSizes = {
    ZefyrToolbarAction.unlink: 20.0,
    ZefyrToolbarAction.clipboardCopy: 20.0,
    ZefyrToolbarAction.openInBrowser: 20.0,
    ZefyrToolbarAction.close: 20.0,
    ZefyrToolbarAction.confirm: 20.0,
  };

  static const kDefaultButtonTexts = {
    ZefyrToolbarAction.headingLevel1: 'H1',
    ZefyrToolbarAction.headingLevel2: 'H2',
    ZefyrToolbarAction.headingLevel3: 'H3',
  };

  @override
  Widget buildButton(BuildContext context, ZefyrToolbarAction action, {VoidCallback onPressed}) {
    if (kDefaultButtonIcons.containsKey(action)) {
      final icon = kDefaultButtonIcons[action];
      final size = kSpecialIconSizes[action];
      return ZefyrButton.icon(
        action: action,
        icon: icon,
        iconSize: size,
        onPressed: onPressed,
      );
    } else if (kDefaultButtonTexts.containsKey(action)) {
      final theme = Theme.of(context);
      final style = theme.textTheme.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 14.0);
      return ZefyrButton.text(
        action: action,
        text: kDefaultButtonTexts[action],
        style: style,
        onPressed: onPressed,
      );
    } else {
      return Container();
    }
  }
}

class __MarginNoteScreenState extends State<_MarginNoteView> {
  UserItem _item;
  var _editMode = false;
  var _selecting = false;
  FocusNode _focusNode;
  ZefyrController _controller;
  ViewManagerBloc viewManagerBloc;
  SheetManagerBloc sheetManagerBloc;

  Future<void> load() async {
    _item = await AppSettings.shared.userAccount.userDb.getItem(int.parse(widget.state.data));

    if (_item?.type == UserItemType.marginNote.index) {
      Delta delta;

      // we're showing an existing marginNote
      if (_item.info.startsWith('QuillDelta')) {
      } else {
        // old margin note - create a delta
        delta = Delta();
        for (final s in _item.info.trim().split('\n')) {
          if (s.isNotEmpty) {
            delta.insert(s);
          }
          delta.insert('\n');
        }
      }

      setState(() {
        _editMode = false;
        _controller = ZefyrController(NotusDocument.fromDelta(delta))..addListener(_zephyrListener);
        _focusNode = FocusNode();
      });
    }
  }

  void _zephyrListener() {
    if (_editMode) {
      debugPrint('editing');
    } else {
      if (_controller.selection.baseOffset == _controller.selection.extentOffset) {
        // tap
        if (_selecting) {
          _selecting = false;
        } else {
          _toggleEditMode();
          debugPrint('edit at ${_controller.selection.baseOffset}');
        }
      } else {
        _selecting = true;
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_zephyrListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    viewManagerBloc = context.bloc<ViewManagerBloc>();
    sheetManagerBloc = context.bloc<SheetManagerBloc>();

    load();
  }

  void _toggleEditMode() {
    // final maximized = viewManagerBloc?.state?.maximizedViewUid == widget.state.uid;

    if (_editMode) {
      viewManagerBloc?.releasingKeyboardFocusInView(widget.state.uid);
    } else {
      viewManagerBloc?.requestingKeyboardFocusInView(widget.state.uid);
    }

    setState(() {
      _editMode = !_editMode;
    });

    if (_editMode) {
      sheetManagerBloc?.changeType(SheetType.collapsed);
    } else {
      sheetManagerBloc?.toDefaultView();
    }
  }

  void _deleteNoteDialog() {
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
              await AppSettings.shared.userAccount.userDb.deleteItem(_item);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ManagedViewAppBar(
        appBar: AppBar(
          title: (_item == null) ? null : Text(MarginNote.getTitle(_item)),
          leading: (!_editMode)
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  tooltip: 'End editing',
                  onPressed: () => {_toggleEditMode()},
                ),
          actions: _editMode
              ? [
                  IconButton(
                    icon: const Icon(FeatherIcons.trash2),
                    tooltip: 'Delete Note',
                    onPressed: _deleteNoteDialog,
                  ),
                ]
              : defaultActionsBuilder(context, widget.state, widget.size),
        ),
      ),
      body: (_controller == null)
          ? Container()
          : ZefyrScaffold(
              child: ZefyrEditor(
                padding: const EdgeInsets.all(16),
                controller: _controller,
                focusNode: _focusNode,
                toolbarDelegate: ToolbarDelegate(),
                mode: _editMode ? ZefyrMode.edit : ZefyrMode.select,
                imageDelegate: TecImageDelegate(),
              ),
            ),
    );
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

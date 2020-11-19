import 'dart:async';
import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';
import 'package:zefyr/zefyr.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../common/common.dart';
import '../menu/view_actions.dart';

class ViewableMarginNote extends Viewable {
  ViewableMarginNote(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) =>
      _MarginNoteView(state: state, size: size);

  @override
  String menuTitle({BuildContext context, ViewState state}) {
    if (state?.uid != null) {
      final json = context.viewManager?.dataWithView(state.uid);
      final jsonMap = json is String ? tec.parseJsonSync(json) : json;
      if (jsonMap is Map<String, dynamic>) {
        return tec.as<String>(jsonMap['title']);
      }
    }

    return null;
  }

  @override
  Future<ViewData> dataForNewView(
          {BuildContext context, int currentViewId, Map<String, dynamic> options}) =>
      Future.value(const ViewData());
}

class _MarginNoteView extends StatefulWidget {
  final ViewState state;
  final Size size;

  const _MarginNoteView({Key key, this.state, this.size}) : super(key: key);

  @override
  __MarginNoteScreenState createState() => __MarginNoteScreenState();
}

// class ToolbarDelegate implements ZefyrToolbarDelegate {
//   static const kDefaultButtonIcons = {
//     ZefyrToolbarAction.bold: Icons.format_bold,
//     ZefyrToolbarAction.italic: Icons.format_italic,
//     ZefyrToolbarAction.heading: Icons.format_size,
//     ZefyrToolbarAction.bulletList: Icons.format_list_bulleted,
//     ZefyrToolbarAction.numberList: Icons.format_list_numbered,
//     ZefyrToolbarAction.quote: Icons.format_quote,
//   };
//
//   static const kIgnoreButtonIcons = {
//     ZefyrToolbarAction.link: Icons.link,
//     ZefyrToolbarAction.unlink: Icons.link_off,
//     ZefyrToolbarAction.clipboardCopy: Icons.content_copy,
//     ZefyrToolbarAction.horizontalRule: Icons.remove,
//     ZefyrToolbarAction.openInBrowser: Icons.open_in_new,
//     ZefyrToolbarAction.code: Icons.code,
//     ZefyrToolbarAction.image: Icons.photo,
//     ZefyrToolbarAction.cameraImage: Icons.photo_camera,
//     ZefyrToolbarAction.galleryImage: Icons.photo_library,
//     ZefyrToolbarAction.hideKeyboard: Icons.keyboard_hide,
//     ZefyrToolbarAction.close: Icons.close,
//     ZefyrToolbarAction.confirm: Icons.check,
//   };
//
//   static const kSpecialIconSizes = {
//     ZefyrToolbarAction.unlink: 20.0,
//     ZefyrToolbarAction.clipboardCopy: 20.0,
//     ZefyrToolbarAction.openInBrowser: 20.0,
//     ZefyrToolbarAction.close: 20.0,
//     ZefyrToolbarAction.confirm: 20.0,
//   };
//
//   static const kDefaultButtonTexts = {
//     ZefyrToolbarAction.headingLevel1: 'H1',
//     ZefyrToolbarAction.headingLevel2: 'H2',
//     ZefyrToolbarAction.headingLevel3: 'H3',
//   };
//
//   @override
//   Widget buildButton(BuildContext context, ZefyrToolbarAction action, {VoidCallback onPressed}) {
//     if (kDefaultButtonIcons.containsKey(action)) {
//       final icon = kDefaultButtonIcons[action];
//       final size = kSpecialIconSizes[action];
//       return ZefyrButton.icon(
//         action: action,
//         icon: icon,
//         iconSize: size,
//         onPressed: onPressed,
//       );
//     } else if (kDefaultButtonTexts.containsKey(action)) {
//       final theme = Theme.of(context);
//       final style = theme.textTheme.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 14.0);
//       return ZefyrButton.text(
//         action: action,
//         text: kDefaultButtonTexts[action],
//         style: style,
//         onPressed: onPressed,
//       );
//     } else {
//       return Container();
//     }
//   }
// }

class __MarginNoteScreenState extends State<_MarginNoteView> {
  UserItem _item;
  var _editMode = false;
  var _selecting = false;
  FocusNode _focusNode;
  ZefyrController _controller;
  ViewManagerBloc viewManagerBloc;
  SheetManagerBloc sheetManagerBloc;
  StreamSubscription<bool> keyboardListener;
  Timer _saveTimer;
  String _title;
  static const oldAppPrefix = 'You\'re using an old app.';
  StreamSubscription<UserDbChange> _userDbChangeSubscription;
  int _userId;

  Future<void> load() async {
    final data = viewManagerBloc?.dataWithView(widget.state?.uid);
    final mnData = jsonDecode(data) as Map<String, dynamic>;
    _title = mnData['title'] as String;
    _item = await AppSettings.shared.userAccount.userDb.getItem(mnData['id'] as int);

    if (_item?.type == UserItemType.marginNote.index) {
      NotusDocument doc;
      var info = _item.info;

      if (info.startsWith(oldAppPrefix)) {
        info = info.substring(oldAppPrefix.length);
      }

      // we're showing an existing marginNote
      try {
        doc = NotusDocument.fromJson(json.decode(info) as List);
      } catch (_) {
        // old margin note - create a delta
        final delta = Delta();
        for (final s in info.trim().split('\n')) {
          if (s.isNotEmpty) {
            delta.insert(s);
          }
          delta.insert('\n');
        }
        doc = NotusDocument.fromDelta(delta);
      }

      setState(() {
        _editMode = false;
        _controller = ZefyrController(doc)..addListener(_zephyrListener);
        _controller.document.changes.listen((_) => _documentChange());
        _focusNode = FocusNode();
      });
    }
  }

  void _documentChange() {
    if (_saveTimer != null) {
      _saveTimer.cancel();
    }
    _saveTimer = Timer(const Duration(seconds: 2), _saveDocument);
  }

  Future<void> _saveDocument() async {
    _saveTimer = null;
    _item = _item.copyWith(info: '$oldAppPrefix${jsonEncode(_controller.document)}');
    await AppSettings.shared.userAccount.userDb.saveItem(_item);
  }

  void _zephyrListener() {
    if (!_editMode) {
      if (_controller.selection.baseOffset == _controller.selection.extentOffset) {
        // tap
        if (_selecting) {
          _selecting = false;
        } else {
          _toggleEditMode();
        }
      } else {
        _selecting = true;
      }
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    await keyboardListener?.cancel();

    if (_saveTimer != null) {
      _saveTimer.cancel();
      _saveTimer = null;
      await _saveDocument();
    }

    _controller?.removeListener(_zephyrListener);

    await _userDbChangeSubscription?.cancel();
    _userDbChangeSubscription = null;
  }

  @override
  void initState() {
    super.initState();

    viewManagerBloc = context.viewManager;
    sheetManagerBloc = context.tbloc<SheetManagerBloc>();

    _userId = AppSettings.shared.userAccount.user.userId;

    // Start listening for changes to the db.
    _userDbChangeSubscription =
        AppSettings.shared.userAccount.userDbChangeStream.listen(_userDbChangeListener);

    load();
  }

  void _userDbChangeListener(UserDbChange change) {
    // just check the userId.  If it's different - close this view w/o saving...
    if (_userId != AppSettings.shared.userAccount.user.userId) {
      // need to close the view...
      viewManagerBloc?.add(ViewManagerEvent.remove(widget.state.uid));
    }
  }

  void _toggleEditMode() {
    // final maximized = viewManagerBloc?.state?.maximizedViewUid == widget.state.uid;

    if (_editMode) {
      viewManagerBloc?.releasingKeyboardFocusInView(widget.state.uid);
    } else {
      viewManagerBloc?.requestingKeyboardFocusInView(widget.state.uid);
    }

    if (_editMode) {
      sheetManagerBloc?.add(SheetEvent.restore);
    } else {
      sheetManagerBloc?.add(SheetEvent.collapse);
    }

    setState(() {
      _editMode = !_editMode;
    });

    if (_editMode) {
      keyboardListener = KeyboardVisibility.onChange.listen(
        (visible) {
          if (!visible) {
            _toggleEditMode();
          }
        },
      );
    } else {
      keyboardListener?.cancel();
      keyboardListener = null;
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
      resizeToAvoidBottomInset: false,
      appBar: MinHeightAppBar(
        appBar: AppBar(
          centerTitle: false,
          title: (_item == null)
              ? null
              : Text(_title),
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
          ? null
          : Column(
              children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: _editMode ? 0 : 85),
                    child: ZefyrEditor(
                      controller: _controller,
                      focusNode: _focusNode,
                      // autofocus: _editMode,
                      // toolbarDelegate: ToolbarDelegate(),
                      readOnly: !_editMode,
                      showCursor: _editMode,
                      // expands: true,
                      // imageDelegate: TecImageDelegate(),
                    ),
                  ),
                ),
                if (_editMode)
                  ZefyrToolbar(children: [
                    ToggleStyleButton(
                      attribute: NotusAttribute.bold,
                      icon: Icons.format_bold,
                      controller: _controller,
                    ),
                    const SizedBox(width: 1),
                    ToggleStyleButton(
                      attribute: NotusAttribute.italic,
                      icon: Icons.format_italic,
                      controller: _controller,
                    ),
                    VerticalDivider(indent: 16, endIndent: 16, color: Colors.grey.shade400),
                    // SelectHeadingStyleButton(controller: _controller),
                    // VerticalDivider(indent: 16, endIndent: 16, color: Colors.grey.shade400),
                    ToggleStyleButton(
                      attribute: NotusAttribute.block.numberList,
                      controller: _controller,
                      icon: Icons.format_list_numbered,
                    ),
                    ToggleStyleButton(
                      attribute: NotusAttribute.block.bulletList,
                      controller: _controller,
                      icon: Icons.format_list_bulleted,
                    ),
                    // ToggleStyleButton(
                    //   attribute: NotusAttribute.block.code,
                    //   controller: _controller,
                    //   icon: Icons.code,
                    // ),
                    VerticalDivider(indent: 16, endIndent: 16, color: Colors.grey.shade400),
                    ToggleStyleButton(
                      attribute: NotusAttribute.block.quote,
                      controller: _controller,
                      icon: Icons.format_quote,
                    ),
                    VerticalDivider(indent: 16, endIndent: 16, color: Colors.grey.shade400),
                    // LinkStyleButton(controller: _controller),
                    // InsertEmbedButton(
                    //   controller: _controller,
                    //   icon: Icons.horizontal_rule,
                    // ),
                  ]),
              ],
            ),
    );
  }
}

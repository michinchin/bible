import 'dart:async';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../common/tec_dialog.dart';

List<UserItemType> _searchTypes;

class QuickFind extends StatefulWidget {
  final Function(String words, List<UserItemType> ofTypes) onSearch;
  final String search;

  const QuickFind({Key key, this.onSearch, this.search}) : super(key: key);

  @override
  _QuickFindState createState() => _QuickFindState();
}

class _QuickFindState extends State<QuickFind> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuffix;
  Timer _searchTimer;
  String _lastSearch;

  @override
  void initState() {
    super.initState();
    _showSuffix = false;

    _searchTypes ??= [
      UserItemType.folder,
      UserItemType.note,
      UserItemType.bookmark,
      UserItemType.marginNote,
    ];

    _focusNode.addListener(() {
      setState(() {
        _showSuffix = _focusNode.hasFocus || _controller.value.text.isNotEmpty;
      });
    });

    _controller
      ..addListener(() {
        if (_searchTimer != null) {
          _searchTimer.cancel();
          _searchTimer = null;
        }

        _searchTimer = Timer(const Duration(milliseconds: 500), () {
          if (widget.onSearch != null) {
            _search();
          }
        });
      });

    if (widget.search != null) {
      _lastSearch = widget.search;
      _controller.text = widget.search;
      _focusNode.requestFocus();
    }
  }


  @override
  void didUpdateWidget(QuickFind oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _search({bool forceSearch = false}) {
    final s = _controller.value.text.trim();

    if (!forceSearch && _lastSearch == s) {
      return;
    }

    _lastSearch = s;

    widget.onSearch(s, _searchTypes);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1.color;
    return Padding(
      padding: const EdgeInsets.only(left: 7.0, right: 7.0, top: 12.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).textTheme.bodyText1.color.withOpacity(.1),
            borderRadius: BorderRadius.circular(5.0)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _controller,
                style: Theme.of(context).appBarTheme.textTheme.bodyText1,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_outlined, color: textColor),
                  border: InputBorder.none,
                  hintText: 'Search bookmarks and notes',
                  hintStyle: Theme.of(context).appBarTheme.textTheme.bodyText1.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).textTheme.bodyText1.color.withOpacity(.7)),
                ),
              ),
            ),
            if (_showSuffix)
              IconButton(
                icon: Icon(Icons.cancel_outlined, color: textColor),
                onPressed: () {
                  _controller.clear();
                  if (_focusNode.hasFocus) {
                    _focusNode.unfocus();
                  } else {
                    setState(() {
                      _showSuffix = false;
                    });
                  }
                },
              ),
            if (_showSuffix)
              IconButton(
                icon: Icon(Icons.filter_list, color: textColor),
                onPressed: () async {
                  final previous = List<UserItemType>.from(_searchTypes);
                  await _showFilter();
                  var changed = false;
                  for (final type in _searchTypes) {
                    if (previous.contains(type)) {
                      previous.remove(type);
                    } else {
                      changed = true;
                      break;
                    }
                  }

                  if (changed || previous.isNotEmpty) {
                    // need to redo the search...
                    _search(forceSearch: true);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilter() => showTecDialog<Reference>(
      maxWidth: 320,
      maxHeight: 300,
      context: context,
      builder: (c) => Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Select types to search'),
                ),
                const _Switch(
                  label: 'Bookmarks',
                  icon: FeatherIcons.bookmark,
                  type: UserItemType.bookmark,
                ),
                const _Switch(
                  label: 'Folders',
                  icon: Icons.folder_outlined,
                  type: UserItemType.folder,
                ),
                const _Switch(
                  label: 'Notes',
                  icon: FeatherIcons.edit2,
                  type: UserItemType.note,
                ),
                const _Switch(
                  label: 'Margin Notes',
                  icon: TecIcons.marginNoteOutline,
                  type: UserItemType.marginNote,
                ),
                FlatButton(
                  child: const Text('DONE'),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
              ],
            ),
          ));
}

class _Switch extends StatefulWidget {
  final String label;
  final IconData icon;
  final UserItemType type;

  const _Switch({Key key, this.label, this.icon, this.type}) : super(key: key);

  @override
  __SwitchState createState() => __SwitchState();
}

class __SwitchState extends State<_Switch> {
  bool _value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      dense: true,
      secondary: Icon(widget.icon),
      title: Text(widget.label),
      value: _value,
      onChanged: (value) {
        if (value) {
          _searchTypes.add(widget.type);
        } else if (_searchTypes.length == 1) {
          TecToast.show(context, 'At least one filter required!');
          return;
        } else {
          _searchTypes.remove(widget.type);
        }
        setState(_updateValue);
      },
    );
  }

  void _updateValue() {
    _value = _searchTypes.contains(widget.type);
  }

  @override
  void initState() {
    super.initState();
    _updateValue();
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickFind extends StatefulWidget {
  final Function(String search) onSearch;

  const QuickFind({Key key, this.onSearch}) : super(key: key);

  @override
  _QuickFindState createState() => _QuickFindState();
}

class _QuickFindState extends State<QuickFind> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuffix;
  Timer _searchTimer;

  @override
  void initState() {
    super.initState();
    _showSuffix = false;

    _focusNode.addListener(() {
      setState(() {
        _showSuffix = _focusNode.hasFocus;
      });
    });

    _controller.addListener(() {
      if (_searchTimer != null) {
        _searchTimer.cancel();
        _searchTimer = null;
      }

      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        if (widget.onSearch != null) {
          widget.onSearch(_controller.value.text.trim());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1.color;
    return Padding(
      padding: const EdgeInsets.only(left: 7.0, right: 2.0),
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        style: Theme.of(context).appBarTheme.textTheme.bodyText1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_outlined, color: textColor),
          border: InputBorder.none,
          suffixIcon: _showSuffix
              ? IconButton(
                  icon: Icon(Icons.cancel_outlined, color: textColor),
                  onPressed: () {
                    _controller.clear();
                    _focusNode.unfocus();
                  },
                )
              : null,
          hintText: 'Search titles and notes',
          hintStyle: Theme.of(context)
              .appBarTheme
              .textTheme
              .bodyText1
              .copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

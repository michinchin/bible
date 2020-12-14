import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BreadCrumb {
  final String folderName;
  final int id;

  BreadCrumb(this.id, this.folderName);
}

class BreadCrumbRow extends StatefulWidget {
  final List<BreadCrumb> breadCrumbs;
  final Function(int num) onTap;

  const BreadCrumbRow({Key key, this.breadCrumbs, this.onTap}) : super(key: key);

  @override
  _BreadCrumbRowState createState() => _BreadCrumbRowState();
}

class _BreadCrumbRowState extends State<BreadCrumbRow> {
  ScrollController _controller;
  int _numberCrumbs;

  @override
  Widget build(BuildContext context) {
    final crumbWidgets = <Widget>[];
    const style = TextStyle(fontSize: 20.0);
    const textPadding = EdgeInsets.only(top: 8.0, left: 4.0, bottom: 8.0, right: 4.0);

    for (var i = 0; i < widget.breadCrumbs.length - 1; i++) {
      crumbWidgets
        ..add(
          InkWell(
            child: Padding(
              padding: textPadding,
              child: Text(widget.breadCrumbs[i].folderName,
                  style: style.copyWith(fontWeight: FontWeight.bold)),
            ),
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap(i);
              }
            },
          ),
        )
        ..add(const Icon(Icons.arrow_back_ios_outlined));
    }

    crumbWidgets.add(Padding(
      padding: textPadding,
      child: Text(widget.breadCrumbs[widget.breadCrumbs.length - 1].folderName, style: style),
    ));

    if (widget.breadCrumbs.length != _numberCrumbs) {
      _numberCrumbs = widget.breadCrumbs.length;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _controller.jumpTo(_controller.position.maxScrollExtent + 100);
      });
    }

    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 8.0),
        child: Row(children: crumbWidgets),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _numberCrumbs = 0;
  }
}

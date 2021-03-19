import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart';

import '../../models/app_settings.dart';
import 'ugc_view.dart';

class BreadCrumb {
  String folderName;
  final int id;
  double scrollOffset;
  static const prefBreadCrumbs = 'breadcrumbs';
  static const prefBreadCrumbUser = 'breadcrumb_user';

  BreadCrumb(this.id, this.folderName, {this.scrollOffset = 0});

  Map toJson() => <String, dynamic>{
        'f': folderName,
        'i': id,
        's': scrollOffset,
      };

  factory BreadCrumb.fromJson(Map<String, dynamic> json) {
    return BreadCrumb(as<int>(json['i']), as<String>(json['f']),
        scrollOffset: as<double>(json['s']));
  }

  static Future<List<BreadCrumb>> load() async {
    final breadCrumbs = <BreadCrumb>[];

    var json = Prefs.shared.getString(prefBreadCrumbs, defaultValue: '');
    if (json.startsWith('${AppSettings.shared.userAccount.user.userId.toString()}:')) {
      json = json.substring(AppSettings.shared.userAccount.user.userId.toString().length + 1);
    }
    else {
      json = '';
    }

    if (json.isNotEmpty) {
      final crumbs =
      asList<Map<String, dynamic>>(jsonDecode(json));
      for (final crumb in crumbs) {
        breadCrumbs.add(BreadCrumb.fromJson(crumb));
      }
    }

    if (breadCrumbs.isEmpty) {
      final topFolder = await AppSettings.shared.userAccount.userDb.getItem(1);
      if (topFolder == null) {
        breadCrumbs.add(BreadCrumb(UGCView.folderHome, 'Journal'));
      }
      else {
        breadCrumbs.add(BreadCrumb(UGCView.folderHome, topFolder.title));
      }
    }

    return breadCrumbs;
  }

  static void save(List<BreadCrumb> breadCrumbs) {
    Prefs.shared.setString(prefBreadCrumbs,
        '${AppSettings.shared.userAccount.user.userId}:${jsonEncode(breadCrumbs)}');
  }
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

    for (var i = 0; i < widget.breadCrumbs.length - 1; i++) {
      if (widget.breadCrumbs[i].id != UGCView.folderSearchResults) {
        crumbWidgets..add(
          InkWell(
            child: Text(widget.breadCrumbs[i].folderName,
                style: style.copyWith(fontWeight: FontWeight.bold)),
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap(i);
              }
            },
          ),
        )..add(const Padding(
          padding: EdgeInsets.only(left: 4.0, right: 4.0),
          child: Icon(Icons.arrow_back_ios_outlined),
        ));
      }
    }

    crumbWidgets
        .add(Text(widget.breadCrumbs[widget.breadCrumbs.length - 1].folderName, style: style));

    if (widget.breadCrumbs.length != _numberCrumbs) {
      _numberCrumbs = widget.breadCrumbs.length;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        // + 100 will show a visible scroll...
        _controller.jumpTo(_controller.position.maxScrollExtent /* + 100 */);
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

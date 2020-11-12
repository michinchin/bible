import 'package:flutter/cupertino.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/view_data/view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';

class UGCViewData extends ViewData {
  final int folderId;

  static const folderHome = 1;
  static const folderRecent = -20;
  static const folderBookmarks = -1;
  static const folderNotes = -2;
  static const folderMarginNotes = -3;
  static const folderHighlights = -4;
  static const folderLicenses = -5;

  const UGCViewData(this.folderId);

  factory UGCViewData.fromJson(Object json) {
    int folderId;

    final jsonMap = json is String ? tec.parseJsonSync(json) : json;
    if (jsonMap is Map<String, dynamic>) {
      folderId = tec.as<int>(jsonMap['folderId']);
    }

    return UGCViewData(folderId ?? folderHome);
  }

  factory UGCViewData.fromContext(BuildContext context, int viewUid) {
    return UGCViewData.fromJson(context.viewManager?.dataWithView(viewUid));
  }
}
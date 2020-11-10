import 'package:flutter/cupertino.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';

void showNotes(BuildContext context) {
  context.viewManager
      ?.add(const ViewManagerEvent.add(type: Const.viewTypeNotes, data: null, position: null));
}

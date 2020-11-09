
import 'package:flutter/cupertino.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';


void showNotes(BuildContext context) {
  context.tbloc<ViewManagerBloc>()?.add(const ViewManagerEvent.add(
      type: Const.viewTypeNotes,
      data: null,
      position: null));
}
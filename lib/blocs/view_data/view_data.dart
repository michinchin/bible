import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../view_manager/view_manager_bloc.dart';

class ViewDataBloc extends Cubit<ViewData> {
  final ViewManagerBloc vmBloc;
  final int viewUid;

  ViewDataBloc(this.vmBloc, this.viewUid, ViewData data)
      : assert(vmBloc != null && viewUid != null && data != null),
        super(data);

  Future<void> update(BuildContext context, ViewData viewData) async {
    assert(viewData != null);
    // tec.dmPrint('ViewDataBloc: updating data for view $viewUid to ${viewData.toString()}');
    await vmBloc.updateDataWithView(viewUid, viewData.toString());
    emit(viewData);
  }
}

@immutable
class ViewData extends Equatable {
  const ViewData();

  factory ViewData.fromContext(BuildContext context, int viewUid) {
    return ViewData.fromJson(context.tbloc<ViewManagerBloc>()?.dataWithView(viewUid));
  }

  ViewData copyWith() => const ViewData();

  @override
  List<Object> get props => [];

  @override
  String toString() => tec.toJsonString(toJson());

  Map<String, dynamic> toJson() => <String, dynamic>{};

  // ignore: avoid_unused_constructor_parameters
  factory ViewData.fromJson(Object json) => const ViewData();
}

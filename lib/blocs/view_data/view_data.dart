import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../view_manager/view_manager_bloc.dart';

class ViewDataCubit extends Cubit<ViewData> {
  final ViewManagerBloc vmBloc;
  final int viewUid;

  ViewDataCubit(this.vmBloc, this.viewUid, ViewData data)
      : assert(vmBloc != null && viewUid != null && data != null),
        super(data);

  void update(ViewData viewData) {
    assert(viewData != null);
    vmBloc.updateDataWithView(viewUid, viewData.toString());
    emit(viewData);
  }
}

@immutable
class ViewData extends Equatable {
  const ViewData();

  @override
  List<Object> get props => [];

  @override
  String toString() => tec.toJsonString(toJson());

  Map<String, dynamic> toJson() => <String, dynamic>{};

  // ignore: avoid_unused_constructor_parameters
  factory ViewData.fromJson(Object json) => const ViewData();
}

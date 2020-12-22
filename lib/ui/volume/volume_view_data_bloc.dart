import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/shared_bible_ref_bloc.dart';
import 'volume_view_data.dart';

export 'volume_view_data.dart';

class VolumeViewDataBloc extends ViewDataBloc {
  VolumeViewDataBloc(ViewManagerBloc vmBloc, int viewUid, VolumeViewData data)
      : super(vmBloc, viewUid, data);

  @override
  Future<void> update(
    BuildContext context,
    ViewData viewData, {
    bool updateSharedRef = true,
  }) async {
    assert(viewData != null && viewData is VolumeViewData);
    await super.update(context, viewData);
    if (updateSharedRef && viewData is VolumeViewData && viewData.useSharedRef) {
      _isUpdatingSharedBibleRef = true;
      context.read<SharedBibleRefBloc>()?.update(viewData.bcv);
      _isUpdatingSharedBibleRef = false;
    }
  }

  bool get isUpdatingSharedBibleRef => _isUpdatingSharedBibleRef;
  var _isUpdatingSharedBibleRef = false;
}

///
/// This should be called from a `BlocListener` like so:
/// 
/// `BlocListener<SharedBibleRefBloc, BookChapterVerse>(listener: handleSharedBibleRefChange)`
///
void handleSharedBibleRefChange(BuildContext context, BookChapterVerse sharedRef) {
  final viewDataBloc = context.read<VolumeViewDataBloc>();
  final viewData = viewDataBloc.state.asVolumeViewData;
  if (!viewDataBloc.isUpdatingSharedBibleRef &&
      viewData.useSharedRef &&
      viewData.bcv != sharedRef) {
    final newViewData = viewData.copyWith(bcv: sharedRef);
    viewDataBloc.update(context, newViewData, updateSharedRef: false);
  }
}

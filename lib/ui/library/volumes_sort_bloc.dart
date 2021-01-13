import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum VolumesSortOpt { name, recent }

// Popular volumes sorted with most popular first.
const _popularVolumes = [9, 51, 32, 47, 49, 231, 1017, 1014, 1013];

///
/// VolumesSortBloc
/// 
class VolumesSortBloc extends Cubit<VolumesSort> {
  VolumesSortBloc()
      : super(VolumesSort.fromJson(tec.Prefs.shared.getString('_library_sort_settings')) ??
            const VolumesSort(VolumesSortOpt.recent, _popularVolumes));

  void updateSortBy(VolumesSortOpt sortBy) => emit(VolumesSort(sortBy, state.recent));

  void updateWithVolume(int volume) {
    final newState = VolumesSort(
        state.sortBy, state.recent.where((v) => v != volume).toList()..insert(0, volume));
    tec.Prefs.shared.setString('_library_sort_settings', tec.toJsonString(newState));
    // tec.dmPrint('VolumesSortBloc.updateWithVolume($volume => $newState');
    _cache = null;
    emit(newState);
  }

  Map<int, int> _cache;
  int compare(int volume1, int volume2) {
    var i = 0;
    _cache ??= <int, int>{for (final v in state.recent) v: i++};
    final i1 = _cache[volume1] ?? state.recent.length;
    final i2 = _cache[volume2] ?? state.recent.length;
    return i1.compareTo(i2);
  }
}

///
/// VolumesSort
/// 
@immutable
class VolumesSort extends Equatable {
  final VolumesSortOpt sortBy;
  final List<int> recent;

  const VolumesSort(this.sortBy, this.recent);

  @override
  List<Object> get props => [sortBy, recent];

  factory VolumesSort.fromJson(Object object) {
    final json = (object is String ? tec.parseJsonSync(object) : object);
    if (json is Map<String, dynamic>) {
      return VolumesSort(
        VolumesSortOpt.values[math.min(
            VolumesSortOpt.values.length - 1, math.max(0, tec.as<int>(json['sortBy']) ?? 1))],
        tec.asList<int>(json['recent']) ?? [],
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (sortBy != VolumesSortOpt.name) 'sortBy': sortBy.index,
      if (recent.isNotEmpty) 'recent': recent,
    };
  }

  @override
  String toString() => tec.toJsonString(toJson());
}

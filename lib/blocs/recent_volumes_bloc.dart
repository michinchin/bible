import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart';

// Popular volumes sorted with most popular first.
const _popularVolumes = [9, 51, 32, 47, 91, 231, 50, 65, 309, 1017, 1014, 1013];

///
/// RecentVolumesBloc
///
class RecentVolumesBloc extends Cubit<RecentVolumes> {
  final String prefsKey;

  RecentVolumesBloc({this.prefsKey = '_recent_volumes'})
      : super(RecentVolumes.fromJson(Prefs.shared.getString(prefsKey)) ??
            RecentVolumes(_popularVolumes.map((id) => RecentVolume(id, null)).toList()));

  void updateWithVolume(int volume, {DateTime now}) {
    final newState = RecentVolumes(state.volumes.where((v) => v.id != volume).toList()
      ..insert(0, RecentVolume(volume, now ?? DateTime.now())));
    Prefs.shared.setString(prefsKey, toJsonString(newState));
    // dmPrint('RecentVolumesBloc.updateWithVolume($volume => $newState');
    _cache = null;
    emit(newState);
  }

  void removeVolume(int volume) {
    final newState = RecentVolumes(state.volumes.where((v) => v.id != volume).toList());
    if (newState != state) {
      Prefs.shared.setString(prefsKey, toJsonString(newState));
      _cache = null;
      emit(newState);
    }
  }

  Map<int, int> _cache;
  int compare(int volume1, int volume2) {
    var i = 0;
    _cache ??= <int, int>{for (final v in state.volumes) v.id: i++};
    final i1 = _cache[volume1] ?? state.volumes.length;
    final i2 = _cache[volume2] ?? state.volumes.length;
    return i1.compareTo(i2);
  }
}

///
/// RecentVolumes
///
@immutable
class RecentVolumes extends Equatable {
  final List<RecentVolume> volumes;

  const RecentVolumes(this.volumes);

  @override
  List<Object> get props => [volumes];

  factory RecentVolumes.fromJson(Object object) {
    final json = (object is String ? parseJsonSync(object) : object);
    if (json is Map<String, Object>) {
      final ids = asList<int>(json['ids']) ?? [];
      final dts = asList<int>(json['dts']) ?? [];
      var i = 0;
      final volumes = ids.map((id) => RecentVolume(id, dateTimeFromDbInt(dts[i++]))).toList();
      return (RecentVolumes(volumes));
    }
    return null;
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      if (volumes.isNotEmpty) 'ids': volumes.map((v) => v.id).toList(),
      if (volumes.isNotEmpty) 'dts': volumes.map((v) => dbIntFromDateOnly(v.dt)).toList(),
    };
  }

  @override
  String toString() => toJsonString(toJson());
}

@immutable
class RecentVolume extends Equatable {
  final int id;
  final DateTime dt;

  const RecentVolume(this.id, this.dt);

  @override
  List<Object> get props => [id, dt];

  @override
  String toString() => id.toString();
}

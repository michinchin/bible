import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../../models/app_settings.dart';

class VolumesBloc extends tec.SafeBloc<VolumesState, VolumesState> {
  VolumesBloc({@required this.key, @required tec.KeyValueStore kvStore})
      : assert(tec.isNotNullOrEmpty(key) && kvStore != null),
        _kvStore = kvStore;

  final String key;
  final tec.KeyValueStore _kvStore;

  @override
  VolumesState get initialState {
    final jsonStr = _kvStore.getString(key);
    VolumesState state;
    if (tec.isNotNullOrEmpty(jsonStr)) {
      final json = tec.parseJsonSync(jsonStr);
      if (json != null) state = VolumesState.fromJson(json);
    }
    if (state != null) return state;

    if (key.endsWith('bibles')) {
      return const VolumesState(VolumesFilter(volumeType: VolumeType.bible), []);
    } else if (key.endsWith('purchased')) {
      return const VolumesState(VolumesFilter(ownershipStatus: OwnershipStatus.owned), []);
    }

    return const VolumesState(VolumesFilter(), []);
  }

  @override
  Stream<VolumesState> mapEventToState(VolumesState event) async* {
    yield event;
  }
}

@immutable
class VolumesState extends Equatable {
  final VolumesFilter filter;
  final List<Volume> volumes;

  const VolumesState(this.filter, this.volumes);

  @override
  List<Object> get props => [filter, volumes];

  static Future<VolumesState> generateFrom(VolumesFilter filter) async {
    final strs = filter.searchFilter.split(' ').map((s) => s.toLowerCase()).toList();
    var ids = VolumesRepository.shared
        .volumeIdsWithType(filter.volumeType ?? VolumeType.anyType, location: filter.location);
    final owned = filter.ownershipStatus == OwnershipStatus.any
        ? null
        : await AppSettings.shared.userAccount.userDb.fullyLicensedVolumesInList(ids);

    if (filter.ownershipStatus == OwnershipStatus.owned) {
      ids = owned;
    } else if (filter.ownershipStatus == OwnershipStatus.unowned) {
      final ownedSet = owned.toSet();
      ids.removeWhere(ownedSet.contains);
    }

    final volumes = ids
        .map<Volume>((id) => VolumesRepository.shared.volumeWithId(id))
        .where((v) => filter.language.isEmpty || (v.language == filter.language))
        .where((v) =>
            strs.isEmpty ||
            (strs.firstWhere((s) => v.matchesSearchString(s), orElse: () => null) != null))
        .toList();
    return VolumesState(filter, volumes);
  }

  factory VolumesState.fromJson(Object object) {
    final json = (object is String ? tec.parseJsonSync(object) : object);
    if (json is Map<String, dynamic>) {
      final filter = VolumesFilter.fromJson(json['filter']);
      return VolumesState(filter, const []);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'filter': filter.toJson(),
    };
  }
}

enum OwnershipStatus { any, owned, unowned }

@immutable
class VolumesFilter extends Equatable {
  final VolumeType volumeType;
  final Location location;
  final OwnershipStatus ownershipStatus;
  final int category;
  final String language;
  final String searchFilter;

  const VolumesFilter({
    this.volumeType = VolumeType.anyType,
    this.location = Location.any,
    this.ownershipStatus = OwnershipStatus.any,
    this.category = 0,
    this.language = '',
    this.searchFilter = '',
  }) : assert(volumeType != null &&
            location != null &&
            category != null &&
            language != null &&
            searchFilter != null);

  @override
  List<Object> get props =>
      [volumeType, location, ownershipStatus, category, language, searchFilter];

  VolumesFilter copyWith({
    VolumeType volumeType,
    Location location,
    OwnershipStatus ownershipStatus,
    int category,
    String language,
    String searchFilter,
  }) =>
      VolumesFilter(
        volumeType: volumeType ?? this.volumeType,
        location: location ?? this.location,
        ownershipStatus: ownershipStatus ?? this.ownershipStatus,
        category: category ?? this.category,
        language: language ?? this.language,
        searchFilter: searchFilter ?? this.searchFilter,
      );

  factory VolumesFilter.fromJson(Object object) {
    final json = (object is String ? tec.parseJsonSync(object) : object);
    if (json is Map<String, dynamic>) {
      return VolumesFilter(
        volumeType: VolumeType.values[math.min(
            VolumeType.values.length - 1, math.max(0, tec.as<int>(json['volumeType']) ?? 0))],
        location: Location.values[
            math.min(Location.values.length - 1, math.max(0, tec.as<int>(json['location']) ?? 0))],
        ownershipStatus: OwnershipStatus.values[math.min(OwnershipStatus.values.length - 1,
            math.max(0, tec.as<int>(json['ownershipStatus']) ?? 0))],
        category: 0,
        language: tec.as<String>(json['language']) ?? '',
        searchFilter: tec.as<String>(json['searchFilter']) ?? '',
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (volumeType != VolumeType.anyType) 'volumeType': volumeType.index,
      if (location != Location.any) 'location': location.index,
      if (ownershipStatus != OwnershipStatus.any) 'ownershipStatus': ownershipStatus.index,
      if (language.isNotEmpty) 'language': language,
      if (searchFilter.isNotEmpty) 'searchFilter': searchFilter,
    };
  }
}

extension on Volume {
  bool matchesSearchString(String str) =>
      (name ?? '').toLowerCase().contains(str) ||
      (abbreviation ?? '').toLowerCase().contains(str) ||
      (publisher ?? '').toLowerCase().contains(str) ||
      (author ?? '').toLowerCase().contains(str);
}

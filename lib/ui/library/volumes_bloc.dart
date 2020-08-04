import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart' as vol;

import '../../models/app_settings.dart';
import '../../models/language_utils.dart';

export '../../models/language_utils.dart';

class VolumesBloc extends tec.SafeBloc<VolumesFilter, VolumesState> {
  final String key;
  final tec.KeyValueStore _kvStore;
  final VolumesFilter defaultFilter;

  VolumesBloc({this.defaultFilter, this.key, tec.KeyValueStore kvStore}) : _kvStore = kvStore;

  @override
  VolumesState get initialState {
    if (tec.isNotNullOrEmpty(key) && _kvStore != null) {
      final jsonStr = _kvStore.getString(key);
      VolumesFilter filter;
      if (tec.isNotNullOrEmpty(jsonStr)) {
        final json = tec.parseJsonSync(jsonStr);
        if (json != null) filter = VolumesFilter.fromJson(json);
      }
      if (filter != null) return VolumesState(filter, const []);
    }

    return VolumesState(defaultFilter ?? const VolumesFilter(), const []);
  }

  @override
  Stream<VolumesState> mapEventToState(VolumesFilter event) async* {
    // Update caches if we need to.
    if (_defaultVolumes == null) {
      await updateCaches();
    }

    // If there's a key and store, save the filter.
    if (tec.isNotNullOrEmpty(key) && _kvStore != null) {
      await _kvStore.setString(key, tec.toJsonString(event.toJson()));
    }

    final volumes = await _volumesWith(event);
    yield VolumesState(event, volumes);
  }

  Future<void> refresh() async {
    add(state.filter);
  }

  // Caches
  List<vol.Volume> _defaultVolumes;
  LinkedHashMap<String, String> _languages;
  LinkedHashMap<int, vol.Category> _categories;

  Future<void> updateCaches() async {
    _defaultVolumes = await _volumesWith(defaultFilter);

    final vr = vol.VolumesRepository.shared;

    final languageCodes = _defaultVolumes.map((v) => v.language).toSet().toList()
      ..sort((a, b) => languageNameFromCode(a).compareTo(languageNameFromCode(b)));
    _languages = {for (final code in languageCodes) code: languageNameFromCode(code)}
        as LinkedHashMap<String, String>;

    _categories = {for (final id in vr.categoryIds()) id: vr.categoryWithId(id)}
        as LinkedHashMap<int, vol.Category>;

    // Remove the categories that don't contain a volume in _defaultVolumes.
    for (final id in vr.categoryIds()) {
      final catVolIdSet = _categories[id].volumeIds.toSet();
      final contains =
          _defaultVolumes.firstWhere((v) => catVolIdSet.contains(v.id), orElse: () => null) != null;
      if (!contains) _categories.remove(id);
    }
  }

  LinkedHashMap<String, String> get languages => _languages;

  LinkedHashMap<int, String> get categories =>
      {for (final c in _categories.values) c.id: c.name} as LinkedHashMap<int, String>;
}

Future<List<vol.Volume>> _volumesWith(VolumesFilter filter) async {
  final vr = vol.VolumesRepository.shared;

  final strs = filter.searchFilter.split(' ').map((s) => s.toLowerCase()).toList();
  var ids = vr.volumeIdsWithType(filter.volumeType, location: filter.location);
  final owned = filter.ownershipStatus == OwnershipStatus.any
      ? null
      : await AppSettings.shared.userAccount.userDb.fullyLicensedVolumesInList(ids);

  if (filter.ownershipStatus == OwnershipStatus.owned) {
    ids = owned;
  } else if (filter.ownershipStatus == OwnershipStatus.unowned) {
    final ownedSet = owned.toSet();
    ids.removeWhere(ownedSet.contains);
  }

  final categoryVolumeIds =
      filter.category == 0 ? null : vr.categoryWithId(filter.category)?.volumeIds?.toSet();

  final volumes = ids
      .map<vol.Volume>(vr.volumeWithId)
      .where((v) => filter.language.isEmpty || (v.language == filter.language))
      .where((v) => categoryVolumeIds == null || categoryVolumeIds.contains(v.id))
      .where((v) =>
          strs.isEmpty ||
          (strs.firstWhere((s) => v.matchesSearchString(s), orElse: () => null) != null))
      .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  return volumes;
}

@immutable
class VolumesState extends Equatable {
  final VolumesFilter filter;
  final List<vol.Volume> volumes;

  const VolumesState(this.filter, this.volumes);

  @override
  List<Object> get props => [filter, volumes];

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
  final vol.VolumeType volumeType;
  final vol.Location location;
  final OwnershipStatus ownershipStatus;
  final int category;
  final String language;
  final String searchFilter;

  const VolumesFilter({
    this.volumeType = vol.VolumeType.anyType,
    this.location = vol.Location.any,
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
    vol.VolumeType volumeType,
    vol.Location location,
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
        volumeType: vol.VolumeType.values[math.min(
            vol.VolumeType.values.length - 1, math.max(0, tec.as<int>(json['volumeType']) ?? 0))],
        location: vol.Location.values[math.min(
            vol.Location.values.length - 1, math.max(0, tec.as<int>(json['location']) ?? 0))],
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
      if (volumeType != vol.VolumeType.anyType) 'volumeType': volumeType.index,
      if (location != vol.Location.any) 'location': location.index,
      if (ownershipStatus != OwnershipStatus.any) 'ownershipStatus': ownershipStatus.index,
      if (language.isNotEmpty) 'language': language,
      if (searchFilter.isNotEmpty) 'searchFilter': searchFilter,
    };
  }
}

extension on vol.Volume {
  bool matchesSearchString(String str) =>
      (name ?? '').toLowerCase().contains(str) ||
      (abbreviation ?? '').toLowerCase().contains(str) ||
      (publisher ?? '').toLowerCase().contains(str) ||
      (author ?? '').toLowerCase().contains(str);
}

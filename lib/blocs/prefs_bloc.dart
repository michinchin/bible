import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_user_account/tec_user_account.dart';

import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../models/app_settings.dart';
import '../models/pref_item.dart';

const unsetHighlightColor = Color(0xff999999);
const defaultCustomHighlightColor1 = Color(0xffffc595);
const defaultCustomHighlightColor2 = Color(0xffdac6ff);
const defaultCustomHighlightColor3 = Color(0xff80cbc4);
const defaultCustomHighlightColor4 = Color(0xffffadaf);
const defaultCustomColors = [
  defaultCustomHighlightColor1,
  defaultCustomHighlightColor2,
  defaultCustomHighlightColor3,
  defaultCustomHighlightColor4
];

class PrefBlocState {
  final Map<int, PrefItem> items;

  const PrefBlocState(this.items);
}

class PrefsBloc extends Cubit<PrefBlocState> {
  static final PrefsBloc shared = PrefsBloc._();

  PrefsBloc._() : super(const PrefBlocState(<int, PrefItem>{}));

  /// in case of "retiring" any prefItems to local storage instead of db
  Future<void> _removeOldPrefItems(List<UserItem> prefItems) async {
    final saveToDbListIds = PrefItemId.saveToDbList.map((i) => i + 100).toList();
    final items = <UserItem>[];

    for (final item in prefItems) {
      if (!saveToDbListIds.contains(item.id)) {
        items.add(item.copyWith(deleted: 1));
      }
    }

    await AppSettings.shared.userAccount.userDb.saveSyncItems(items);
  }

  Future<List<PrefItem>> _loadItems() async {
    final items = <PrefItem>[];
    final prefItems =
        await AppSettings.shared.userAccount.userDb.getItemsOfTypes([UserItemType.prefItem]);

    await _removeOldPrefItems(prefItems);

    for (final id in PrefItemId.saveToDbList) {
      final uid = PrefItemId.uniqueId(id);
      final item = prefItems.firstWhere((i) => i.id == uid, orElse: () => null);
      if (item != null) {
        items.add(PrefItem.from(item));
      }
    }
    for (final id in PrefItemId.saveToPrefsList) {
      final value = Prefs.shared.getString(PrefItemId.keyForPrefs(id), defaultValue: '');
      if (isNotNullOrEmpty(value)) {
        final prefItem = PrefItemHelper.fromSharedPrefs(PrefItemId.keyForPrefs(id), value);
        items.add(prefItem);
      }
    }
    return items;
  }

  void _addDefaultBool(Map<int, PrefItem> prefItems, int id, {bool defaultValue = true}) {
    if (!prefItems.containsKey(id)) {
      prefItems[id] = PrefItem(
          prefItemDataType: PrefItemDataType.bool, prefItemId: id, intValue: defaultValue ? 1 : 0);
    }
  }

  Future<void> _loadDefaults(Map<int, PrefItem> prefItems) async {
    // Custom color initialization
    for (var i = PrefItemId.customColor1; i <= PrefItemId.customColor4; i++) {
      if (!prefItems.containsKey(i)) {
        prefItems[i] = PrefItem(
            prefItemDataType: PrefItemDataType.int,
            prefItemId: i,
            id: PrefItemId.uniqueId(i),
            intValue: defaultCustomColors[i - 1].value);
      }
    }

    _addDefaultBool(prefItems, PrefItemId.navLayout);
    _addDefaultBool(prefItems, PrefItemId.nav3Tap);
    _addDefaultBool(prefItems, PrefItemId.navBookOrder);
    _addDefaultBool(prefItems, PrefItemId.includeShareLink);
    _addDefaultBool(prefItems, PrefItemId.translationsAbbreviated);
    _addDefaultBool(prefItems, PrefItemId.searchFilterBookGridView);
    _addDefaultBool(prefItems, PrefItemId.searchFilterTranslationGridView);
    _addDefaultBool(prefItems, PrefItemId.closeAfterCopyShare);
    _addDefaultBool(prefItems, PrefItemId.syncChapter);
    _addDefaultBool(prefItems, PrefItemId.syncVerse);

    if (!prefItems.containsKey(PrefItemId.translationsFilter)) {
      // Translations for search filter pref initialization
      final bibleIds = VolumesRepository.shared.volumeIdsWithType(VolumeType.bible);
      final volumes = VolumesRepository.shared.volumesWithIds(bibleIds);
      final availableVolumes = <int>[];

      for (final v in volumes.values) {
        if (v.onSale || await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(v.id)) {
          availableVolumes.add(v.id);
        }
      }

      prefItems[PrefItemId.translationsFilter] = PrefItem(
          prefItemDataType: PrefItemDataType.string,
          prefItemId: PrefItemId.translationsFilter,
          id: PrefItemId.uniqueId(PrefItemId.translationsFilter),
          stringValue: availableVolumes.join('|'));
    }

    if (!prefItems.containsKey(PrefItemId.priorityTranslations)) {
      prefItems[PrefItemId.priorityTranslations] = PrefItem(
          prefItemDataType: PrefItemDataType.string,
          prefItemId: PrefItemId.priorityTranslations,
          stringValue: '');
    }
  }

  Future<void> load() async {
    final items = await _loadItems();
    final prefItems = <int, PrefItem>{for (var v in items) v.book: v};
    await _loadDefaults(prefItems);
    emit(PrefBlocState(prefItems));
  }

  void _updateItem(PrefItem prefItem) {
    final items = Map<int, PrefItem>.from(state.items);
    items[prefItem.book] = prefItem;
    _savePrefItem(items[prefItem.book]);
    emit(PrefBlocState(items));
  }

  Future<dynamic> _savePrefItem(PrefItem prefItem) {
    if (prefItem.saveToDb) {
      return AppSettings.shared.userAccount.userDb
          .saveItem(prefItem.copyWith(id: prefItem.uniqueId));
    } else {
      return Prefs.shared.setString(prefItem.keyForPrefs, prefItem.valueToSave);
    }
  }

  static bool getBool(int id, {bool defaultValue = false}) {
    return (!shared.state.items.containsKey(id) || shared.state.items[id].verse == null)
        ? defaultValue
        : shared.state.items[id].verse == 1;
  }

  static void setBool(int id, {bool value = false}) {
    shared._updateItem(PrefItem.from(shared.state.items[id].copyWith(verse: value ? 1 : 0)));
  }

  static int getInt(int id, {int defaultValue = -1}) {
    return (!shared.state.items.containsKey(id) || shared.state.items[id].verse == null)
        ? defaultValue
        : shared.state.items[id].verse;
  }

  static void setInt(int id, int value) {
    shared._updateItem(PrefItem.from(shared.state.items[id].copyWith(verse: value)));
  }

  static String getString(int id, {String defaultValue}) {
    return (!shared.state.items.containsKey(id)) ? defaultValue : shared.state.items[id].info;
  }

  static void setString(int id, String value) {
    shared._updateItem(PrefItem.from(shared.state.items[id].copyWith(info: value)));
  }

  static bool toggle(int id) {
    final items = Map<int, PrefItem>.from(shared.state.items);
    shared._updateItem(PrefItem.from(items[id].copyWith(verse: 1 - items[id].verse)));
    return shared.state.items[id].verse == 1;
  }

// PrefItems _delete(PrefItem prefItem) {
//   final items = List<PrefItem>.from(state.items);
//   if (items.hasItem(prefItem)) {
//     final index = items.indexOfItem(prefItem);
//     items.removeItem(prefItem);
//     AppSettings.shared.userAccount.userDb.deleteItem(prefItem.copyWith(book: items[index].book));
//   }
//   return state.copyWith(items: items);
// }
}

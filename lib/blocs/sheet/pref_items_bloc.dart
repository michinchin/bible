import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/app_settings.dart';
import '../../models/pref_item.dart';

part 'pref_items_bloc.freezed.dart';

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

@freezed
abstract class PrefItemEvent with _$PrefItemEvent {
  const factory PrefItemEvent.add({@required PrefItem prefItem}) = _Add;
  const factory PrefItemEvent.delete({@required PrefItem prefItem}) = _Delete;
  const factory PrefItemEvent.update({@required PrefItem prefItem}) = _Update;
  const factory PrefItemEvent.updateFromDb({@required List<PrefItem> prefItems}) = _UpdateFromDb;
}

@freezed
abstract class PrefItems with _$PrefItems {
  const factory PrefItems(List<PrefItem> items) = _PrefItems;
}

class PrefItemsBloc extends Bloc<PrefItemEvent, PrefItems> {
  PrefItemsBloc() : super(const PrefItems([])) {
    _loadFromDb();
  }

  // returns verse == 0 for item with id
  bool itemBool(int id) => state.items.boolForPrefItem(id);

  PrefItem itemWithId(int id) => state.items.itemWithId(id);

  /// gives the pref item updated with opposite bool (used in conjunction with Update event)
  PrefItem toggledPrefItem(int id) =>
      PrefItem.from(itemWithId(id).copyWith(verse: itemBool(id) ? 1 : 0));

  /// gives the pref item updated with new info string (used in conjunction with Update event)
  PrefItem infoChangedPrefItem(int id, String info) =>
      PrefItem.from(itemWithId(id).copyWith(info: info));

  Future<void> _loadFromDb() async {
    final items =
        await AppSettings.shared.userAccount.userDb.getItemsOfTypes([tua.UserItemType.prefItem]);
    final prefItems = items.map<PrefItem>((i) => PrefItem.from(i)).toList();

    if (prefItems.itemWithId(PrefItemId.customColor1) == null) {
      // Custom color initialization
      for (var i = PrefItemId.customColor1; i <= PrefItemId.customColors.length; i++) {
        prefItems.add(PrefItem(
            prefItemDataType: PrefItemDataType.int,
            prefItemId: i,
            verse: defaultCustomColors[i - 1].value));
      }
    }
    if (prefItems.itemWithId(PrefItemId.navLayout) == null) {
      // Nav pref initialization
      prefItems
        ..add(PrefItem(
            prefItemDataType: PrefItemDataType.bool, prefItemId: PrefItemId.navLayout, verse: 0))
        ..add(PrefItem(
            prefItemDataType: PrefItemDataType.bool, prefItemId: PrefItemId.nav3Tap, verse: 0));
    }
    if (prefItems.itemWithId(PrefItemId.translationsFilter) == null) {
      // Translations for search filter pref initialization
      final bibleIds = VolumesRepository.shared.volumeIdsWithType(VolumeType.bible);
      final volumes = VolumesRepository.shared.volumesWithIds(bibleIds);
      final availableVolumes = <int>[];

      for (final v in volumes.values) {
        if (v.onSale || await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(v.id)) {
          availableVolumes.add(v.id);
        }
      }

      prefItems.add(PrefItem(
          prefItemDataType: PrefItemDataType.string,
          prefItemId: PrefItemId.translationsFilter,
          info: availableVolumes.join('|')));
    }

    if (prefItems.itemWithId(PrefItemId.navBookOrder) == null) {
      // Navigation book order alphabetical/ot/nt
      prefItems.add(PrefItem(
          prefItemDataType: PrefItemDataType.bool, prefItemId: PrefItemId.navBookOrder, verse: 0));
    }

    if (prefItems.itemWithId(PrefItemId.includeShareLink) == null) {
      prefItems.add(PrefItem(
          prefItemDataType: PrefItemDataType.bool,
          prefItemId: PrefItemId.includeShareLink,
          verse: 0));
    }

    if (prefItems.itemWithId(PrefItemId.translationsAbbreviated) == null) {
      prefItems.add(PrefItem(
          prefItemDataType: PrefItemDataType.bool,
          prefItemId: PrefItemId.translationsAbbreviated,
          verse: 0));
    }
    if (prefItems.itemWithId(PrefItemId.searchFilterBookGridView) == null ||
        prefItems.itemWithId(PrefItemId.searchFilterTranslationGridView) == null) {
      prefItems
        ..add(PrefItem(
            prefItemDataType: PrefItemDataType.bool,
            prefItemId: PrefItemId.searchFilterBookGridView,
            verse: 0))
        ..add(PrefItem(
            prefItemDataType: PrefItemDataType.bool,
            prefItemId: PrefItemId.searchFilterTranslationGridView,
            verse: 0));
    }

    if (prefItems.itemWithId(PrefItemId.closeAfterCopyShare) == null) {
      prefItems.add(PrefItem(
          prefItemDataType: PrefItemDataType.bool,
          prefItemId: PrefItemId.closeAfterCopyShare,
          verse: 0));
    }

    add(PrefItemEvent.updateFromDb(prefItems: prefItems));
  }

  @override
  Stream<PrefItems> mapEventToState(PrefItemEvent event) async* {
    final newState =
        event.when(add: _add, delete: _delete, update: _update, updateFromDb: _updateFromDb);
    tec.dmPrint('Updated to $newState');
    yield newState;
  }

  PrefItems _updateFromDb(List<PrefItem> prefItems) {
    AppSettings.shared.userAccount.userDb.saveSyncItems(prefItems);
    return state.copyWith(items: prefItems);
  }

  PrefItems _add(PrefItem prefItem) {
    final items = List<PrefItem>.from(state.items);
    if (!items.hasItem(prefItem)) {
      items.add(prefItem);
      AppSettings.shared.userAccount.userDb.saveItem(prefItem);
    }
    return state.copyWith(items: items);
  }

  PrefItems _delete(PrefItem prefItem) {
    final items = List<PrefItem>.from(state.items);
    if (items.hasItem(prefItem)) {
      final index = items.indexOfItem(prefItem);
      items.removeItem(prefItem);
      AppSettings.shared.userAccount.userDb.deleteItem(prefItem.copyWith(id: items[index].id));
    }
    return state.copyWith(items: items);
  }

  PrefItems _update(PrefItem prefItem) {
    final items = List<PrefItem>.from(state.items);
    if (items.hasItem(prefItem)) {
      final index = items.indexOfItem(prefItem);
      items[index] = PrefItem.from(prefItem.copyWith(id: items[index].id));
      AppSettings.shared.userAccount.userDb.saveItem(prefItem.copyWith(id: items[index].id));
    }
    return state.copyWith(items: items);
  }
}

extension PrefItemsBlocExtOnListOfPrefItem on List<PrefItem> {
  bool hasItem(PrefItem prefItem) => indexOfItem(prefItem) != -1;
  int valueOfItemWithId(int id) => itemWithId(id)?.verse;
  PrefItem itemWithId(int id) => firstWhere((p) => p.book == id, orElse: () => null);
  bool boolForPrefItem(int id) => (itemWithId(id)?.verse ?? 0) == 0;
  int indexOfItem(PrefItem prefItem) => indexWhere((p) => p.book == prefItem.book);
  void removeItem(PrefItem prefItem) => removeWhere((p) => p.book == prefItem.book);
}

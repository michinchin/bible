import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_user_account/tec_user_account.dart' as tua;

import '../../models/app_settings.dart';
import '../../models/pref_item.dart';

part 'pref_items_bloc.freezed.dart';

const unsetHighlightColor = Color(0xff999999);

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
  final PrefItemType prefItemsType;

  PrefItemsBloc({this.prefItemsType}) {
    _loadFromDb();
  }

  @override
  PrefItems get initialState => const PrefItems([]);

  Future<void> _loadFromDb() async {
    final items =
        await AppSettings.shared.userAccount.userDb.getItemsOfTypes([tua.UserItemType.prefItem]);
    final prefItems = items.map((i) => PrefItem.from(i)).toList();
    if (prefItems.isEmpty && prefItemsType == PrefItemType.customColors) {
      for (var i = 1; i <= 4; i++) {
        add(PrefItemEvent.add(
            prefItem: PrefItem(
                prefItemDataType: PrefItemDataType.int,
                prefItemId: i,
                verse: unsetHighlightColor.value)));
      }
    } else if (prefItems.isNotEmpty) {
      add(PrefItemEvent.updateFromDb(prefItems: prefItems));
    }
  }

  @override
  Stream<PrefItems> mapEventToState(PrefItemEvent event) async* {
    final newState =
        event.when(add: _add, delete: _delete, update: _update, updateFromDb: _updateFromDb);
    tec.dmPrint('Updated to $newState');
    yield newState;
  }

  PrefItems _updateFromDb(List<PrefItem> prefItems) {
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
      items.removeItem(prefItem);
      AppSettings.shared.userAccount.userDb.deleteItem(prefItem);
    }
    return state.copyWith(items: items);
  }

  PrefItems _update(PrefItem prefItem) {
    final items = List<PrefItem>.from(state.items);
    if (items.hasItem(prefItem)) {
      final index = items.indexOfItem(prefItem);
      items[index] = prefItem;
      AppSettings.shared.userAccount.userDb.saveItem(prefItem);
    }
    return state.copyWith(items: items);
  }
}

extension PrefItemsBlocExtOnListOfPrefItem on List<PrefItem> {
  bool hasItem(PrefItem prefItem) => indexOfItem(prefItem) != -1;
  int indexOfItem(PrefItem prefItem) => indexWhere((p) => p.book == prefItem.book);
  void removeItem(PrefItem prefItem) => removeWhere((p) => p.book == prefItem.book);
}

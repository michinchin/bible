import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:pedantic/pedantic.dart';
import 'package:tec_user_account/tec_user_account.dart';

import '../models/app_settings.dart';

enum IsLicensedOpt { any, all }

///
/// This Bloc's state will be `null` initially, and then change to `true` if
/// `any` (or optionally `all`) of the given volumes are fully licensed,
/// otherwise it will change to `false`.
///
/// This Bloc listens for license changes in the TecUserAccount UserDb, and
/// auto-updates if there are changes.
///
class IsLicensedBloc extends Bloc<bool, bool> {
  final Set<int> _setOfIds;
  final IsLicensedOpt option;
  final bool checkPremium;
  final bool checkUnlimited;
  StreamSubscription<UserDbChange> _userDbChangeSubscription;

  IsLicensedBloc({
    @required List<int> volumeIds,
    this.option = IsLicensedOpt.any,
    this.checkPremium = true,
    this.checkUnlimited = true,
  })  : assert(volumeIds != null && volumeIds.isNotEmpty),
        assert(option != null && checkPremium != null && checkUnlimited != null),
        _setOfIds = volumeIds?.toSet() ?? {},
        super(null) {
    _userDbChangeSubscription =
        AppSettings.shared.userAccount.userDbChangeStream.listen(_userDbChangeListener);
    _refresh();
  }

  @override
  Future<void> close() {
    _userDbChangeSubscription?.cancel();
    _userDbChangeSubscription = null;
    return super.close();
  }

  @override
  Stream<bool> mapEventToState(bool event) async* {
    yield event;
  }

  Future<void> _userDbChangeListener(UserDbChange change) async {
    if (change.includesItemType(UserItemType.license)) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    // Future.delayed(const Duration(seconds: 1), () async {
    // bloc add now does this test... if (isClosed) return;
    final owned = await AppSettings.shared.userAccount.userDb.fullyLicensedVolumesInList(
      _setOfIds,
      checkPremium: checkPremium,
      checkUnlimited: checkUnlimited,
    );
    add(option == IsLicensedOpt.any ? owned.isNotEmpty : owned.length == _setOfIds.length);
    // });
  }
}

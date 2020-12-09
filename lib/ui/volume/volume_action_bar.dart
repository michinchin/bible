import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/search_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';
import '../../models/user_item_helper.dart';
import '../common/common.dart';
import '../common/tec_action_bar.dart';
import '../common/tec_modal_popup_menu.dart';
import '../library/library.dart';
import '../menu/view_actions.dart';
import '../nav/nav.dart';
import 'study_view_data.dart';
import 'volume_view_data_bloc.dart';

class VolumeViewActionBar extends StatelessWidget {
  final ViewState state;
  final Size size;

  const VolumeViewActionBar({Key key, @required this.state, @required this.size})
      : assert(state != null && size != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VolumeViewDataBloc, ViewData>(
      builder: (context, viewData) {
        if (viewData is VolumeViewData) {
          final volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);
          return ActionBar(
            elevation: defaultActionBarElevation,
            items: [
              ActionBarItem(
                title: 'Search',
                priority: 0,
                options: ActionBarItemOptions.iconOnly,
                showTrailingSeparator: false,
                icon: BlocBuilder<SearchBloc, SearchState>(
                  builder: (c, s) => s.searchResults.isNotEmpty
                      ? const IconWithNumberBadge(
                          color: Const.tecartaBlue, badgeColor: Colors.orange, icon: Icons.search)
                      : const Icon(Icons.search, color: Const.tecartaBlue),
                ),
                onTap: () => _onNavigate(context, viewData, searchView: true),
              ),
              ActionBarItem(
                title: viewData.bookNameAndChapter(),
                priority: 3,
                minTitle: viewData.bookNameAndChapter(useShortBookName: true),
                options: ActionBarItemOptions.titleOnly,
                icon: const Icon(Icons.book),
                onTap: () => _onNavigate(context, viewData),
              ),
              if (tec.isNotNullOrEmpty(volume?.abbreviation))
                ActionBarItem(
                  title: volume.abbreviation,
                  priority: 2,
                  options: ActionBarItemOptions.titleOnly,
                  icon: const Icon(Icons.book),
                  onTap: () => _onSelectVolume(context, viewData),
                ),
              ActionBarItem(
                title: 'Menu',
                priority: 4,
                options: ActionBarItemOptions.iconOnly,
                icon: const Icon(FeatherIcons.chevronDown),
                onTap: () {
                  showTecModalPopupMenu(
                    context: context,
                    insets: context.viewManager.insetsOfView(state.uid),
                    alignment: Alignment.topCenter,
                    minWidth: 125,
                    menuItemsBuilder: (menuContext) => buildMenuItemsForViewWithState(
                      state,
                      context: context,
                      menuContext: menuContext,
                    ),
                  );
                },
              ),
            ],
          );
        }
        throw Exception('VolumeViewActionBar data must be VolumeViewData');
      },
    );
  }
}

Future<void> _onNavigate(BuildContext context, VolumeViewData viewData,
    {int initialIndex = 0, bool searchView = false}) async {
  TecAutoScroll.stopAutoscroll();

  final ref = await navigate(
      context, Reference.fromHref(viewData.bcv.toString(), volume: viewData.volumeId),
      initialIndex: initialIndex, searchView: searchView);

  if (ref != null) {
    // Save navigation ref to nav history.
    unawaited(UserItemHelper.saveNavHistoryItem(ref));

    // Small delay to allow the nav popup to clean up...
    await Future.delayed(const Duration(milliseconds: 350), () {
      final newViewData =
          viewData.copyWith(bcv: BookChapterVerse.fromRef(ref), volumeId: ref.volume);
      tec.dmPrint('VolumeViewActionBar _onNavigate updating with new data: $newViewData');
      context.read<VolumeViewDataBloc>().update(context, newViewData);
    });
  }
}

Future<void> _onSelectVolume(BuildContext context, VolumeViewData viewData) async {
  TecAutoScroll.stopAutoscroll();

  final volumeId = await selectVolumeInLibrary(context,
      title: 'Switch To...', selectedVolume: viewData.volumeId);

  VolumeViewData newViewData;
  if (volumeId != null) {
    assert(viewData != null);
    if (isBibleId(volumeId)) {
      newViewData = VolumeViewData(volumeId, viewData.bcv, 0, useSharedRef: viewData.useSharedRef);
    } else if (isStudyVolumeId(volumeId)) {
      newViewData =
          StudyViewData(0, volumeId, viewData.bcv, 0, useSharedRef: viewData.useSharedRef);
    } else {
      assert(false);
    }
  }

  if (newViewData != null) {
    tec.dmPrint('VolumeViewActionBar _onSelectVolume updating with new data: $newViewData');
    await context.read<VolumeViewDataBloc>().update(context, newViewData);
  }
}

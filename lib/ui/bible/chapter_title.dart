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
import '../../models/user_item_helper.dart';
import '../common/common.dart';
import '../common/tec_modal_popup_menu.dart';
import '../library/library.dart';
import '../menu/view_actions.dart';
import '../nav/nav.dart';
import '../volume/study_view_data.dart';
import 'chapter_view_data.dart';

class VolumeViewPillBar extends StatelessWidget implements PreferredSizeWidget {
  final ViewState state;
  final Size size;

  const VolumeViewPillBar({Key key, @required this.state, @required this.size})
      : assert(state != null && size != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // final scale = (MediaQuery.maybeOf(context)?.textScaleFactor ?? 1.0);

    return BlocBuilder<ChapterViewDataBloc, ViewData>(
      builder: (context, data) {
        if (data is ChapterViewData) {
          return ChapterTitlePill(
            state: state,
            volumeType: isBibleId(data.volumeId) ? VolumeType.bible : VolumeType.studyContent,
          );
        }
        throw Exception('VolumeViewAppBar data must be ChapterViewData');
      },
    );
  }

  // var _preferredHeight = AppBar().preferredSize.height;

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

class ChapterTitlePill extends StatelessWidget {
  final ViewState state;
  final VolumeType volumeType;

  const ChapterTitlePill({Key key, this.state, this.volumeType = VolumeType.anyType})
      : assert(volumeType == VolumeType.bible || volumeType == VolumeType.studyContent),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterViewDataBloc, ViewData>(
      builder: (context, viewData) {
        // tec.dmPrint('rebuilding PageableBibleView title with $viewData');
        if (viewData is ChapterViewData) {
          const buttonPadding = EdgeInsets.all(6); //.only(top: 6.0, bottom: 6.0);
          final buttonStyle = Theme.of(context).appBarTheme.textTheme.headline6;

          final volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);

          Widget separator() => Padding(
                padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                child: Container(
                  color: Theme.of(context).appBarTheme.textTheme.headline6.color.withOpacity(0.35),
                  width: 0.5,
                  height: 28,
                ),
              );

          final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
          const iconButtonSize = 32.0;
          const elevation = 3.0;

          return Container(
            alignment: Alignment.topCenter,
            // padding: const EdgeInsets.only(top: 4),
            // height: 44,
            // constraints: BoxConstraints(maxHeight: double.infinity),
            // color: Colors.red.withOpacity(0.5),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? Theme.of(context).appBarTheme.color
                    : Theme.of(context).backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(90)),
                boxShadow: elevation == 0
                    ? null
                    : const [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, elevation - 1),
                            blurRadius: elevation,
                            spreadRadius: 1),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: iconButtonSize,
                    height: iconButtonSize,
                    child: BlocBuilder<SearchBloc, SearchState>(
                      cubit: context.tbloc<SearchBloc>(),
                      builder: (c, s) => IconButton(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.zero,
                        icon: s.searchResults.isNotEmpty
                            ? const IconWithNumberBadge(
                                color: Colors.orange,
                                icon: Icons.search,
                              )
                            : const Icon(Icons.search),
                        tooltip: 'Search',
                        onPressed: () => _onNavigate(context, viewData, searchView: true),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 4), // separator(),
                  CupertinoButton(
                    minSize: 0,
                    // color: Colors.green,
                    padding: buttonPadding,
                    child: TecText(
                      viewData.bookNameAndChapter,
                      maxLines: 1,
                      style: buttonStyle,
                    ),
                    onPressed: () => _onNavigate(context, viewData),
                  ),
                  separator(),
                  CupertinoButton(
                    minSize: 0,
                    // color: Colors.green,
                    padding: buttonPadding,
                    child: TecText(
                      volume?.abbreviation ?? '',
                      maxLines: 1,
                      style: buttonStyle,
                    ),
                    onPressed: () => _onSelectVolume(context, viewData),
                  ),
                  separator(),
                  Container(
                    width: iconButtonSize,
                    height: iconButtonSize,
                    child: IconButton(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      icon: const Icon(FeatherIcons.chevronDown),
                      tooltip: 'Menu',
                      onPressed: () {
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
                  ),
                ],
              ),
            ),
          );
        } else {
          throw UnsupportedError('ChapterTitlePill must use ChapterViewData');
        }
      },
    );
  }
}

class ChapterTitle extends StatelessWidget {
  final VolumeType volumeType;

  const ChapterTitle({Key key, this.volumeType = VolumeType.anyType})
      : assert(volumeType == VolumeType.bible || volumeType == VolumeType.studyContent),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterViewDataBloc, ViewData>(
      builder: (context, viewData) {
        // tec.dmPrint('rebuilding PageableBibleView title with $viewData');
        if (viewData is ChapterViewData) {
          const minFontSize = 10.0;
          const buttonPadding = EdgeInsets.only(top: 16.0, bottom: 16.0);
          final buttonStyle = Theme.of(context).appBarTheme.textTheme.headline6;
          final autosizeGroup = TecAutoSizeGroup();

          final volume = VolumesRepository.shared.volumeWithId(viewData.volumeId);

          return Row(
            children: [
              Container(
                padding: EdgeInsets.zero,
                width: 32.0,
                child: BlocBuilder<SearchBloc, SearchState>(
                    cubit: context.tbloc<SearchBloc>(),
                    builder: (c, s) => IconButton(
                        padding: const EdgeInsets.only(right: 8.0),
                        iconSize: 20,
                        icon: s.searchResults.isNotEmpty
                            ? const IconWithNumberBadge(
                                color: Colors.orange,
                                icon: FeatherIcons.search,
                              )
                            : const Icon(FeatherIcons.search),
                        tooltip: 'Search',
                        onPressed: () => _onNavigate(context, viewData, searchView: true))),
              ),
              Flexible(
                flex: 3,
                child: CupertinoButton(
                  minSize: 0,
                  padding: buttonPadding,
                  child: TecAutoSizeText(
                    viewData.bookNameAndChapter,
                    minFontSize: minFontSize,
                    maxLines: 1,
                    group: autosizeGroup,
                    style: buttonStyle,
                  ),
                  onPressed: () => _onNavigate(context, viewData),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Container(
                  color: Theme.of(context).appBarTheme.textTheme.headline6.color,
                  width: 1,
                  height: const MinHeightAppBar().preferredSize.height *
                      .55, // 22 * textScaleFactorWith(context),
                ),
              ),
              Flexible(
                child: CupertinoButton(
                  minSize: 0,
                  padding: buttonPadding,
                  child: TecAutoSizeText(
                    volume?.abbreviation ?? '',
                    minFontSize: minFontSize,
                    group: autosizeGroup,
                    maxLines: 1,
                    style: buttonStyle,
                  ),
                  onPressed: () => _onSelectVolume(context, viewData),
                ),
              ),
            ],
          );
        } else {
          throw UnsupportedError('ChapterTitle must use ChapterViewData');
        }
      },
    );
  }
}

Future<void> _onNavigate(BuildContext context, ChapterViewData viewData,
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
      final newViewData = context
          .tbloc<ChapterViewDataBloc>()
          .state
          .asChapterViewData
          .copyWith(bcv: BookChapterVerse.fromRef(ref));
      tec.dmPrint('ChapterTitlePill _onNavigate updating with new data: $newViewData');
      context.tbloc<ChapterViewDataBloc>().update(context, newViewData);
    });
  }
}

Future<void> _onSelectVolume(BuildContext context, ChapterViewData viewData) async {
  TecAutoScroll.stopAutoscroll();

  final volumeId = await selectVolumeInLibrary(context,
      title: 'Switch To...', selectedVolume: viewData.volumeId);

  ChapterViewData newViewData;
  if (volumeId != null) {
    final previous = context.tbloc<ChapterViewDataBloc>().state.asChapterViewData;
    assert(previous != null);
    if (isBibleId(volumeId)) {
      newViewData = ChapterViewData(volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
    } else if (isStudyVolumeId(volumeId)) {
      newViewData =
          StudyViewData(0, volumeId, previous.bcv, 0, useSharedRef: previous.useSharedRef);
    } else {
      assert(false);
    }
  }

  if (newViewData != null) {
    tec.dmPrint('ChapterTitlePill _onSelectVolume updating with new data: $newViewData');
    await context.tbloc<ChapterViewDataBloc>().update(context, newViewData);
  }
}

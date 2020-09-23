import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../../blocs/view_data/view_data.dart';
import '../../models/bible_view_data.dart';
import 'common.dart';

class BibleChapterTitle extends StatelessWidget {
  final Future<void> Function(BuildContext context, BibleViewData viewData, {int initialIndex})
      onNavigate;

  const BibleChapterTitle({Key key, @required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewDataCubit, ViewData>(
      builder: (context, viewData) {
        tec.dmPrint('rebuilding PageableBibleView title with $viewData');
        if (viewData is BibleViewData) {
          const minFontSize = 10.0;
          const buttonPadding = EdgeInsets.only(top: 16.0, bottom: 16.0);
          final buttonStyle = Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Theme.of(context).textColor.withOpacity(0.5));
          final autosizeGroup = TecAutoSizeGroup();

          final bible = VolumesRepository.shared.bibleWithId(viewData.bibleId);

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                width: 32.0,
                child: IconButton(
                    padding: const EdgeInsets.only(right: 8.0),
                    icon: const Icon(FeatherIcons.search, size: 20),
                    tooltip: 'Search',
                    color: Theme.of(context).textColor.withOpacity(0.5),
                    onPressed: () => onNavigate(context, viewData)),
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
                  onPressed: () => onNavigate(context, viewData),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Container(
                  color: Theme.of(context).textColor.withOpacity(0.2),
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
                    bible?.abbreviation ?? '',
                    minFontSize: minFontSize,
                    group: autosizeGroup,
                    maxLines: 1,
                    style: buttonStyle,
                  ),
                  onPressed: () =>
                      onNavigate(context, viewData, initialIndex: NavTabs.translation.index),
                  // onPressed: () => _onSelectBible(context, viewData),
                ),
              ),
            ],
          );
        } else {
          throw UnsupportedError('BibleChapterTitle must use BibleViewData');
        }
      },
    );
  }
}

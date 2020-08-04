import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../common/common.dart';
import 'volumes_bloc.dart';

Future<void> showVolumesFilterSheet(BuildContext context) async {
  final bloc = context.bloc<VolumesBloc>(); // ignore: close_sinks
  await showModalBottomSheet<void>(
    context: context,
    shape: bottomSheetShapeBorder,
    builder: (_) => BlocBuilder<VolumesBloc, VolumesState>(
      bloc: bloc,
      builder: (context, state) => VolumesFilterSheet(volumesBloc: bloc),
    ),
  );
}

class VolumesFilterSheet extends StatelessWidget {
  final VolumesBloc volumesBloc;

  const VolumesFilterSheet({Key key, this.volumesBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = textScaleFactorWith(context);
    final padding = 8 * textScaleFactor;
    final languages = volumesBloc.languages;
    final categories = volumesBloc.categories;
    final language = volumesBloc.state.filter.language;
    final category = volumesBloc.state.filter.category;

    const animationDuration = Duration(milliseconds: 300);
    final buttonHeight = 16 + (20 * textScaleFactor).roundToDouble();

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: TecText(
                'Filter By',
                textScaleFactor: textScaleFactor,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            AnimatedContainer(
              duration: animationDuration,
              height: languages.length > 1 ? buttonHeight : 0,
              child: TecPopupMenuButton<String>(
                title: 'Language',
                values: languages,
                currentValue: language,
                defaultValue: '',
                defaultName: 'Any',
                onSelectValue: (value) {
                  volumesBloc.add(volumesBloc.state.filter.copyWith(language: value));
                },
              ),
            ),
            AnimatedContainer(
              duration: animationDuration,
              height: categories.length > 1 ? buttonHeight : 0,
              child: TecPopupMenuButton<int>(
                title: 'Category',
                values: categories,
                currentValue: category,
                defaultValue: 0,
                defaultName: 'Any',
                onSelectValue: (value) {
                  volumesBloc.add(volumesBloc.state.filter.copyWith(category: value));
                },
              ),
            ),
            AnimatedContainer(
              duration: animationDuration,
              height: volumesBloc.state.filter != volumesBloc.defaultFilter ? buttonHeight : 0,
              child: TecTextButton(
                title: 'Clear Filters',
                onTap: () => volumesBloc.add(volumesBloc.defaultFilter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const bottomSheetRadius = Radius.circular(15);
const bottomSheetShapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: bottomSheetRadius, topRight: bottomSheetRadius));

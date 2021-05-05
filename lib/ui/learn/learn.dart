import 'package:flutter/material.dart';

import 'package:collection/collection.dart' as collection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_bloc/tec_bloc.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/is_licensed_bloc.dart';
import '../../blocs/recent_volumes_bloc.dart';
import '../common/common.dart';
import '../common/tec_modal_bottom_sheet.dart';
import '../common/tec_navigator.dart';
import '../library/volumes_bloc.dart';
import 'learn_volume_card.dart';
import 'learn_volume_detail.dart';

void showLearn(BuildContext context) {
  // Get the list of selected bible references.
  final vm = context?.viewManager;
  final refs = <Reference>[];
  for (final selectionObj in vm?.visibleViewsWithSelections?.map(vm.selectionObjectWithViewUid)) {
    if (selectionObj is Reference) {
      refs.add(selectionObj);
    }
  }

  showLearnWithReferences(refs, context);
}

void showLearnWithReferences(Iterable<Reference> refs, BuildContext context) {
  if (refs == null || refs.isEmpty) return;

  showModalBottomSheetWithMaxWidth<void>(
    context: context,
    maxWidth: 500.0,
    height: 0.9,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: bottomSheetShape,
    clipBehavior: Clip.hardEdge,
    builder: (context) => NavigatorWithHeroController(
      onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (context) => LearnScaffold(refs: refs),
      ),
    ),
  );
}

class LearnScaffold extends StatelessWidget {
  final Iterable<Reference> refs;

  const LearnScaffold({Key key, @required this.refs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IsLicensedBloc>(
      create: (context) =>
          IsLicensedBloc(volumeIds: VolumesRepository.shared.volumeIdsWithType(VolumeType.anyType)),
      child: BlocBuilder<IsLicensedBloc, bool>(
        builder: (context, hasLicensedVolumes) {
          // if `hasLicensedVolumes` is null, just return spinner.
          if (hasLicensedVolumes == null) return const Center(child: LoadingIndicator());

          return Scaffold(
            appBar: AppBar(
              elevation: 1,
              leading: const CloseButton(),
              title: const Text('Learn'),
            ),
            body: BlocProvider<VolumesBloc>(
              create: (context) => VolumesBloc(
                key: '_learn_',
                kvStore: MemoryKVStore.shared, // Prefs.shared,
                defaultFilter: const VolumesFilter(volumeType: VolumeType.studyContent),
              )..refresh(),
              child: BlocBuilder<VolumesBloc, VolumesState>(
                builder: (context, state) => _VolumesList(state),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VolumesList extends StatelessWidget {
  final VolumesState volumesState;

  const _VolumesList(this.volumesState, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var volumes = volumesState.volumes;
    final sortBloc = context.tbloc<RecentVolumesBloc>();
    volumes = List.of(volumes);
    // Using mergeSort because it is stable (i.e. equal elements remain in the same order).
    collection.mergeSort<Volume>(volumes, compare: (a, b) => sortBloc.compare(a.id, b.id));
    volumes = volumes.take(sortBloc.state.volumes.length).toList();

    const heroPrefix = 'learn';

    return SafeArea(
      bottom: false,
      child: ListView.builder(
        itemCount: volumes.length,
        itemBuilder: (context, index) {
          final volume = volumes[index];
          return LearnVolumeCard(
            volume: volume,
            studyText: _studyTextForIndex(index),
            heroPrefix: heroPrefix,
            // trailing: _VolumeActionButton(volume: volume, heroPrefix: widget.heroPrefix),
            onTap: () => Navigator.of(context)
                .push<void>(MaterialPageRoute(builder: (context) => const LearnVolumeDetail())),
          );
        },
      ),
    );
  }
}

String _studyTextForIndex(int i) => _tmpStudyText[i % _tmpStudyText.length];
const _tmpStudyText = [
  'How long did it take God to create the world? There are two basic views about the days of creation: (1) Each day was a literal 24-hour period; (2) each...',
  'A foundational teaching of the Bible is that God speaks and does so with universe-changing authority. The command in this verse is just two words in...',
  'These verses introduce the Pentateuch (Genesis-Deuteronomy) and teach Israel that the world was created, ordered, and populated by the...',
  'That must have been a twenty-four hour day—I don\'t see how you could get anything else out of it. Notice that God said, "Let there be light." Ten times...',
  'God said. God effortlessly spoke light into existence (cf. Pss. 33:6, 148:5), which dispelled the darkness of verse 2 light. That which most clearly...',
  'Some Preliminary Remarks: I have never run the Boston Marathon but at this moment I think I know what it feels like to stand at the starting line now...',
];

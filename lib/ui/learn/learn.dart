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

void showLearnWithReferences(Iterable<Reference> refs, BuildContext context, {int volumeId}) {
  if (refs == null || refs.isEmpty) return;

  final volume = volumeId == null ? null : VolumesRepository.shared.volumeWithId(volumeId);
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
        builder: (context) => volume == null
            ? LearnScaffold(refs: refs)
            : LearnVolumeDetail(volume: volume, reference: refs.first),
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

          final bible = VolumesRepository.shared.bibleWithId(9);
          final reference = refs.first;

          return Scaffold(
            appBar: AppBar(
              elevation: 1,
              leading: CloseButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).maybePop(context),
              ),
              centerTitle: false,
              title: Text('Learn: ${bible.nameOfBook(reference.book)} '
                  '${reference.chapter}:${reference.versesToString()}'),
            ),
            body: BlocProvider<VolumesBloc>(
              create: (context) => VolumesBloc(
                key: '_learn_',
                kvStore: MemoryKVStore.shared, // Prefs.shared,
                defaultFilter: const VolumesFilter(volumeType: VolumeType.studyContent),
              )..refresh(),
              child: BlocBuilder<VolumesBloc, VolumesState>(
                builder: (context, state) => _VolumesList(state, refs),
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
  final Iterable<Reference> refs;

  const _VolumesList(this.volumesState, this.refs, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _volumes = {1017, 1014, 1026, 1015, 1016, 2100, 1900, 1400, 1302};
    var volumes = volumesState.volumes.where((e) => _volumes.contains(e.id)).toList();
    final sortBloc = context.tbloc<RecentVolumesBloc>();
    // Using mergeSort because it is stable (i.e. equal elements remain in the same order).
    collection.mergeSort<Volume>(volumes, compare: (a, b) => sortBloc.compare(a.id, b.id));
    volumes = volumes.take(sortBloc.state.volumes.length).toList();

    // const heroPrefix = 'learn';
    final ref = refs.first;

    if (volumes.isEmpty) {
      dmPrint('Learn: waiting for volumes...');
      return const Center(child: LoadingIndicator());
    }

    return SafeArea(
      bottom: false,
      child: TecFutureBuilder<ErrorOrValue<Map<int, ResourceIntro>>>(
        futureBuilder: () => VolumesRepository.shared.resourceIntros(
            reference: Reference(book: ref.book, chapter: ref.chapter, verse: ref.verse),
            volumes: volumes.map((e) => e.id).toList()),
        builder: (context, result, error) {
          final finalError = error ?? result?.error;
          final intros = result?.value;
          if (intros == null || intros.isEmpty) {
            if (finalError != null) return Center(child: Text(finalError.toString()));
            if (intros != null) {
              final bible = VolumesRepository.shared.bibleWithId(9);
              return Center(
                  child: Text('Did not find any study resources for '
                      '${bible.nameOfBook(ref.book)} ${ref.chapter}:${ref.versesToString()}'));
            }
            return const Center(child: LoadingIndicator());
          } else {
            final volumeIds = volumes.map((e) => e.id).where((e) => intros[e] != null).toList();
            return ListView.builder(
              itemCount: intros.keys.length,
              itemBuilder: (context, index) {
                final volume = volumes[volumes.indexWhere((e) => e.id == volumeIds[index])];
                return LearnVolumeCard(
                  volume: volume,
                  studyText: intros[volume.id].intro,
                  // heroPrefix: heroPrefix,
                  // trailing: _VolumeActionButton(volume: volume, heroPrefix: widget.heroPrefix),
                  onTap: () => Navigator.of(context).push<void>(MaterialPageRoute(
                      builder: (context) => LearnVolumeDetail(
                          volume: volume, reference: refs.first))),
                );
              },
            );
          }
        },
      ),
    );
  }
}

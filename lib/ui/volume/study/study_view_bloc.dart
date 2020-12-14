import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../volume_view_data.dart';

class StudyViewBloc extends Cubit<StudyViewState> {
  StudyViewBloc() : super(const StudyViewState(0, null));

  Future<void> updateWithData(VolumeViewData data) async {
    assert(data != null);

    // If the volume ID didn't change, just return.
    if (data?.volumeId == state.volumeId) return;

    if (data?.volumeId != null && data.volumeId > 0) {
      final volume = VolumesRepository.shared.volumeWithId(data.volumeId);
      if (volume != null) {
        // First emit `null` so the progress spinner is shown.
        emit(StudyViewState(data.volumeId, null));

        final sections = await volume?.studySections();

        // Then re-emit with the sections.
        emit(StudyViewState(data.volumeId, sections));
        
        return;
      }
    }

    emit(const StudyViewState(0, null));
  }
}

@immutable
class StudyViewState extends Equatable {
  final int volumeId;
  final List<StudySection> sections;

  const StudyViewState(this.volumeId, this.sections);

  @override
  List<Object> get props => [volumeId, sections];
}

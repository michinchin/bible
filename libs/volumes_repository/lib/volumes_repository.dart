library volumes_repository;

import 'src/models/bible.dart';
import 'src/models/volume.dart';

export 'src/models/volume.dart';

enum Location { local, remote }

abstract class VolumesRepository {
  Future<List<int>> volumesOfType(
    VolumeType type, {
    Location location,
    int maxCount,
  });

  Future<Volume> volumeWithId(int id);

  Future<Bible> bibleWithId(int id);
}

class MockVolumesRepository implements VolumesRepository {
  @override
  Future<List<int>> volumesOfType(VolumeType type,
      {Location location, int maxCount,}) {
    if (type == VolumeType.bible) {
      return Future.value(<int>[32, 51]);
    }
    return Future.value(<int>[]);
  }

  @override
  Future<Volume> volumeWithId(int id) {
    // TODO: implement volumeWithId
    throw UnimplementedError();
  }

  @override
  Future<Bible> bibleWithId(int id) {
    // TODO: implement bibleWithId
    throw UnimplementedError();
  }

}

library tec_volumes;

import 'package:tec_env/tec_env.dart';

import 'src/bible.dart';
import 'src/chapter.dart';
import 'src/volume.dart';

export 'src/bible.dart';
export 'src/chapter.dart';
export 'src/volume.dart';

enum Location { local, remote }

///
/// 
abstract class VolumesRepository {
  Future<List<int>> volumeIdsWithType(
    VolumeType type, {
    Location location,
    int maxCount,
  });

  Future<Volume> volumeWithId(int id);

  Future<Map<int, Volume>> volumesWithIds(List<int> ids);

  Future<Bible> bibleWithId(int id);

  Future<Map<int, Bible>> biblesWithIds(List<int> ids);

  Future<Chapter> chapterWithVolume(int volumeId, {int book, int chapter});
}

///
/// TecVolumesRepository
/// 
class TecVolumesRepository implements VolumesRepository {
  final TecEnv env;

  TecVolumesRepository(this.env);

  @override
  Future<List<int>> volumeIdsWithType(VolumeType type,
      {Location location, int maxCount}) {
    // TODO: implement volumeIdsWithType
    throw UnimplementedError();
  }

  @override
  Future<Volume> volumeWithId(int id) {
    // TODO: implement volumeWithId
    throw UnimplementedError();
  }

  @override
  Future<Map<int, Volume>> volumesWithIds(List<int> ids) {
    // TODO: implement volumesWithIds
    throw UnimplementedError();
  }

  @override
  Future<Bible> bibleWithId(int id) {
    // TODO: implement bibleWithId
    throw UnimplementedError();
  }

  @override
  Future<Map<int, Bible>> biblesWithIds(List<int> ids) {
    // TODO: implement biblesWithIds
    throw UnimplementedError();
  }

  @override
  Future<Chapter> chapterWithVolume(int volumeId, {int book, int chapter}) {
    return Chapter.fetch(env: env, volumeId: volumeId, book: book, chapter: chapter);
  }
}

///
/// MockVolumesRepository -- for testing.
/// 
class MockVolumesRepository implements VolumesRepository {
  @override
  Future<List<int>> volumeIdsWithType(
    VolumeType type, {
    Location location,
    int maxCount,
  }) {
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
  Future<Map<int, Volume>> volumesWithIds(List<int> ids) {
    // TODO: implement volumesWithIds
    throw UnimplementedError();
  }

  @override
  Future<Bible> bibleWithId(int id) {
    // TODO: implement bibleWithId
    throw UnimplementedError();
  }

  @override
  Future<Map<int, Bible>> biblesWithIds(List<int> ids) {
    // TODO: implement biblesWithIds
    throw UnimplementedError();
  }

  @override
  Future<Chapter> chapterWithVolume(int volumeId, {int book, int chapter}) {
    // TODO: implement chapterWithVolume
    throw UnimplementedError();
  }
}

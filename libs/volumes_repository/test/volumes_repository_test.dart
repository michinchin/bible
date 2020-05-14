import 'package:flutter_test/flutter_test.dart';

import 'package:volumes_repository/volumes_repository.dart';

void main() {
  test('MockVolumesRepository volumesOfType', () async {
    final repository = MockVolumesRepository();
    expect(await repository.volumesOfType(VolumeType.studyContent), <int>[]);
    expect(await repository.volumesOfType(VolumeType.bible), [32, 51]);
  });
}

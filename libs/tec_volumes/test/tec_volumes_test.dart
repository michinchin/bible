import 'package:flutter_test/flutter_test.dart';

import 'package:tec_env/tec_env.dart';
import 'package:tec_volumes/tec_volumes.dart';

void main() {
  test('TecVolumesRepository chapterWithVolume', () async {
    final repo = TecVolumesRepository(const TecEnv());
    final chapter = await repo.chapterWithVolume(32, book: 23, chapter: 117);
    expect(chapter.html, _nivPsalm117Html);
  });

  test('MockVolumesRepository volumesOfType', () async {
    final repository = MockVolumesRepository();
    expect(
        await repository.volumeIdsWithType(VolumeType.studyContent), <int>[]);
    expect(await repository.volumeIdsWithType(VolumeType.bible), [32, 51]);
  });
}

// cspell: disable
const _nivPsalm117Html =
    '<div class="CHAPNPS"> <span v="0">Psalm</span> <span v="0">117</span> </div><div class="VRSONE"> <div class="v" id="1"><span v="0">1</span></div><span>Praise</span> <span>the</span> <span class="bdscaps xref" href="23_117_1">Lord</span><span>,</span> <span>all</span> <span>you</span> <span class="xref" href="23_117_2">nations</span><span>;</span> </div><div class="TXTTWO"><span>extol</span> <span>him,</span> <span>all</span> <span>you</span> <span>peoples.</span></div><div class="VRSONE"> <div class="v" id="2"><span v="0">2</span></div><span>For</span> <span>great</span> <span>is</span> <span>his</span> <span class="xref" href="23_117_3">love</span> <span>toward</span> <span>us,</span></div><div class="TXTTWO"><span>and</span> <span>the</span> <span>faithfulness</span> <span>of</span> <span>the</span> <span class="bdscaps xref" href="23_117_4">Lord</span> <span>endures</span> <span>forever.</span></div><div class="HALF"> </div><div class="TXTONE"><span>Praise</span> <span>the</span> <span class="bdscaps">Lord</span><span>.</span><span class="FOOTNO" href="23_117_1" v="0">a</span></div><div id="copyright">Scriptures taken from the Holy Bible, New International Version®, NIV®. Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc.™</div>';

import 'package:bloc/bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import 'view_data/chapter_view_data.dart';

const String _prefsKey = 'sharedBibleRef';

class SharedBibleRefBloc extends Cubit<BookChapterVerse> {
  SharedBibleRefBloc()
      : super(BookChapterVerse.fromJson(tec.Prefs.shared.getString(_prefsKey)) ?? defaultBCV);

  void update(BookChapterVerse bcv) {
    assert(bcv != null);
    if (bcv != state) {
      tec.Prefs.shared.setString(_prefsKey, '{ "r": "${bcv.toString()}" }');
    }
    emit(bcv);
  }
}

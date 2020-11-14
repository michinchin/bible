import 'package:bloc/bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

const defaultBibleId = 9;
const defaultBCV = BookChapterVerse(50, 1, 1);

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

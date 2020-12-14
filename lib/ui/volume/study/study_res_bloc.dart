import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

Volume _volume(int id) => VolumesRepository.shared.volumeWithId(id);

class StudyResBloc extends Cubit<StudyRes> {
  StudyResBloc({@required int volumeId, int resId, int book, int chapter, ResourceType type})
      : super(
            StudyRes(volumeId: volumeId, resId: resId, book: book, chapter: chapter, type: type)) {
    update();
  }

  Future<void> update({int volumeId, int resId, int book, int chapter, ResourceType type}) async {
    var s =
        state.copyWith(volumeId: volumeId, resId: resId, book: book, chapter: chapter, type: type);
    if (s != state) {
      s = s.copyWith(clearRes: true, clearHtml: true, clearError: true);
      emit(s);
    }

    Volume volume;

    // Asynchronously get the resource, if needed.
    if (s.res == null) {
      volume ??= _volume(s.volumeId);
      tec.ErrorOrValue<Resource> result;
      if (s.resId != null) {
        result = await volume?.resourceWithId(s.resId);
      } else if (s.book != null && s.chapter != null) {
        final r = await volume?.resourcesWithBook(s.book, s.chapter, s.type);
        result = tec.ErrorOrValue(r.error, tec.isNullOrEmpty(r.value) ? null : r.value.first);
      }
      // tec.dmPrint('StudyResBloc update got new ${result.value}');
      s = s.copyWithRes(result.value).copyWithError(result.error);
    }

    // Asynchronously get the html, if needed.
    if (s.res != null && (s.html == null || s.res != state.res)) {
      volume ??= _volume(s.volumeId);
      final fileUrl = volume?.fileUrlForResource(s.res);
      if (tec.isNotNullOrEmpty(fileUrl)) {
        s = s.copyWithHtml(await tec.textFromUrl(fileUrl));
        // tec.dmPrint('StudyResBloc update got new html: ${s.html}');
      }
    }

    // if (s != state) tec.dmPrint('StudyResBloc update emitting $s');
    emit(s);
  }
}

class StudyRes extends Equatable {
  final int volumeId;
  final int resId;
  final int book;
  final int chapter;
  final ResourceType type;
  final Resource res;
  final String html;
  final Object error;

  const StudyRes({
    @required this.volumeId,
    this.resId,
    this.book,
    this.chapter,
    this.type,
    this.res,
    this.html,
    this.error,
  })  : assert(volumeId != null && volumeId > 0),
        assert(resId != null || (book != null && chapter != null));

  @override
  List<Object> get props => [volumeId, resId, book, chapter, type, res, html, error];

  StudyRes copyWith({
    int volumeId,
    int resId,
    int book,
    int chapter,
    ResourceType type,
    Resource res,
    bool clearRes = false,
    String html,
    bool clearHtml = false,
    Object error,
    bool clearError = false,
  }) =>
      StudyRes(
          volumeId: volumeId ?? this.volumeId,
          resId: resId ?? this.resId,
          book: book ?? this.book,
          chapter: chapter ?? this.chapter,
          type: type ?? this.type,
          res: res ?? (clearRes ? null : this.res),
          html: html ?? (clearHtml ? null : this.html),
          error: error ?? (clearError ? null : this.error));

  StudyRes copyWithRes(Resource res) => copyWith(res: res, clearRes: true);
  StudyRes copyWithError(Object error) => copyWith(error: error, clearError: true);
  StudyRes copyWithHtml(String html) => copyWith(html: html, clearHtml: true);

  @override
  String toString() => tec.toJsonString(toJson());

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'v': volumeId,
      if (resId != null) 'id': resId,
      if (book != null) 'b': book,
      if (chapter != null) 'c': chapter,
      if (type != null) 't': type.index,
    };
  }
}

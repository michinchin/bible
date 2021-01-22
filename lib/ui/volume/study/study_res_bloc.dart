import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

Volume _volume(int id) => VolumesRepository.shared.volumeWithId(id);

class StudyResBloc extends Cubit<StudyRes> {
  StudyResBloc({@required int volumeId, int resId, int book, int chapter, ResourceType type})
      : super(StudyRes(volumeId: volumeId, resId: resId, book: book, chapter: chapter)) {
    update(type: type);
  }

  StudyResBloc.withResource(Resource res)
      : assert(res != null),
        super(StudyRes(volumeId: res.volumeId, resId: res.id, res: res)) {
    update();
  }

  Future<void> update({int volumeId, int resId, int book, int chapter, ResourceType type}) async {
    var s =
        state.copyWith(volumeId: volumeId, resId: resId, book: book, chapter: chapter, type: type);

    // If the volumeId, resId, book, chapter, or type changed, clear the resource data.
    if (s != state || (type != null && state.res != null && !state.res.hasType(type))) {
      s = s.copyWith(clearRes: true); // `clearRes` clears `html`, `error`, etc. as well.
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
        final r = await volume?.resourcesWithBook(s.book, s.chapter, type);
        result = tec.ErrorOrValue(r.error, tec.isNullOrEmpty(r.value) ? null : r.value.first);
      }
      // tec.dmPrint('StudyResBloc update got new ${result.value}');
      s = s.copyWithRes(result.value).copyWithError(result.error);
    }

    // If the resource has an HTML file, asynchronously get the HTML, if needed.
    if (s.res != null && s.res.filename.endsWith('.html') && s.html == null) {
      volume ??= _volume(s.volumeId);
      final fileUrl = volume?.fileUrlForResource(s.res);
      if (tec.isNotNullOrEmpty(fileUrl)) {
        s = s.copyWithHtml(await tec.textFromUrl(fileUrl));
        // tec.dmPrint('StudyResBloc update got new html: ${s.html}');
      }
    }

    // If the resource is a folder, asynchronously get the children, if needed.
    if (s.res != null && s.res.hasType(ResourceType.folder) && s.children == null) {
      volume ??= _volume(s.volumeId);
      final result = await volume?.resourcesInFolder(s.resId);
      s = s.copyWithChildren(result.value).copyWithError(result.error);
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
  final Resource res;
  final String html;
  final List<Resource> children;
  final Object error;

  const StudyRes({
    @required this.volumeId,
    this.resId,
    this.book,
    this.chapter,
    this.res,
    this.html,
    this.children,
    this.error,
  })  : assert(volumeId != null && volumeId > 0),
        assert(resId != null || (book != null && chapter != null));

  @override
  List<Object> get props => [volumeId, resId, book, chapter, res, html, error];

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
    List<Resource> children,
    bool clearChildren = false,
    Object error,
    bool clearError = false,
  }) =>
      StudyRes(
          volumeId: volumeId ?? this.volumeId,
          resId: resId ?? this.resId,
          book: book ?? this.book,
          chapter: chapter ?? this.chapter,
          res: res ?? (clearRes ? null : this.res),
          html: html ?? (clearRes || clearHtml ? null : this.html),
          children: children ?? (clearRes || clearChildren ? null : this.children),
          error: error ?? (clearRes || clearError ? null : this.error));

  StudyRes copyWithRes(Resource res) => copyWith(res: res, clearRes: true);
  StudyRes copyWithHtml(String html) => copyWith(html: html, clearHtml: true);
  StudyRes copyWithChildren(List<Resource> children) =>
      copyWith(children: children, clearChildren: true);
  StudyRes copyWithError(Object error) => copyWith(error: error, clearError: true);

  @override
  String toString() => tec.toJsonString(toJson());

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'v': volumeId,
      if (resId != null) 'id': resId,
      if (book != null) 'b': book,
      if (chapter != null) 'c': chapter,
    };
  }
}

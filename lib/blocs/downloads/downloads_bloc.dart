import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';

import 'downloads_bloc_io.dart' if (dart.library.html) 'downloads_bloc_web.dart';

class DownloadsBloc extends Bloc<DownloadsState, DownloadsState> {
  DownloadsBloc() : super(const DownloadsState(isLoading: true, items: {}));

  factory DownloadsBloc.create() => DownloadsBlocImp();

  bool get supportsDownloading => false;

  @override
  Stream<DownloadsState> mapEventToState(DownloadsState event) async* {
    yield event;
  }

  Future<void> requestDownload(int volumeId) async {
    assert(false);
  }

  Future<void> cancelDownload(int volumeId) async {
    assert(false);
  }

  Future<void> pauseDownload(int volumeId) async {
    assert(false);
  }

  Future<void> resumeDownload(int volumeId) async {
    assert(false);
  }

  Future<void> deleteDownload(int volumeId) async {
    assert(false);
  }
}

enum DownloadStatus { undefined, enqueued, running, complete, failed, canceled, paused }

@immutable
class DownloadsState extends Equatable {
  final bool isLoading;
  final bool permissionReady;
  final Map<int, DownloadItem> items;

  const DownloadsState({
    this.isLoading = false,
    this.permissionReady = false,
    this.items,
  });

  @override
  List<Object> get props => [items];

  DownloadsState copyWith({
    bool isLoading,
    bool permissionReady,
    Map<int, DownloadItem> items,
  }) =>
      DownloadsState(
        isLoading: isLoading ?? this.isLoading,
        permissionReady: permissionReady ?? this.permissionReady,
        items: items ?? this.items,
      );
}

@immutable
class DownloadItem extends Equatable {
  final int volumeId;
  final String url;
  final String taskId;
  final DownloadStatus status;
  final double progress;

  const DownloadItem({
    @required this.volumeId,
    @required this.url,
    this.taskId = '',
    this.status = DownloadStatus.undefined,
    this.progress = 0.0,
  }) : assert(volumeId != null && volumeId > 0 && url != null);

  @override
  List<Object> get props => [volumeId, url, taskId, status, progress];

  DownloadItem copyWith({
    int volumeId,
    String url,
    String taskId,
    DownloadStatus status,
    double progress,
  }) =>
      DownloadItem(
        volumeId: volumeId ?? this.volumeId,
        url: url ?? this.url,
        taskId: taskId ?? this.taskId,
        status: status ?? this.status,
        progress: progress ?? this.progress,
      );
}

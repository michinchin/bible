import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tec_platform_util/tec_platform_util.dart' as tec;
import 'package:tec_util/tec_util.dart' as tec;

import 'downloads_bloc.dart';

const isDebugMode = kDebugMode;

class DownloadsBlocImp extends DownloadsBloc {
  DownloadsBlocImp() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(_downloadCallback);
    _loadDownloadTasks();
  }

  @override
  bool get supportsDownloading => true;

  @override
  Future<void> close() {
    _unbindBackgroundIsolate();
    return super.close();
  }

  @override
  Future<void> requestDownload(int volumeId) async {
    final newItems = Map.of(state.items); // shallow copy
    newItems[volumeId] = state.items[volumeId] ?? DownloadItem(volumeId: volumeId, url: '');

    assert(newItems[volumeId].status == DownloadStatus.undefined ||
        newItems[volumeId].status == DownloadStatus.failed ||
        newItems[volumeId].status == DownloadStatus.canceled);

    final licenseUrl = '${tec.streamUrl}/products-list/license-$volumeId.json.gz';
    final json = await tec.sendHttpRequest<Map<String, dynamic>>(tec.HttpRequestType.get,
        url: licenseUrl, completion: (status, json, dynamic error) => Future.value(json));

    if (json != null) {
      final url = tec.as<String>(json['url']);
      if (tec.isNotNullOrEmpty(url)) {
        final taskId = await FlutterDownloader.enqueue(
            url: url,
            // headers: {"auth": "test_for_sql_encoding"},
            savedDir: _downloadsDir,
            showNotification: true,
            openFileFromNotification: false);

        if (taskId == null) {
          tec.dmPrint('FlutterDownloader.enqueue(\'$url\') returned null!');
        } else {
          newItems[volumeId] = newItems[volumeId].copyWith(taskId: taskId, url: url);
        }
      }
    }

    add(state.copyWith(items: newItems));
  }

  @override
  Future<void> cancelDownload(int volumeId) async {
    final item = state.items[volumeId];
    if (item == null ||
        !(item.status == DownloadStatus.running || item.status == DownloadStatus.paused)) {
      assert(false);
    } else {
      await FlutterDownloader.cancel(taskId: item.taskId);
    }
  }

  @override
  Future<void> pauseDownload(int volumeId) async {
    final item = state.items[volumeId];
    if (item == null || item.status != DownloadStatus.running) {
      assert(false);
    } else {
      await FlutterDownloader.pause(taskId: item.taskId);
    }
  }

  @override
  Future<void> resumeDownload(int volumeId) async {
    final item = state.items[volumeId];
    if (item == null || item.status != DownloadStatus.paused) {
      assert(false);
    } else {
      final newTaskId = await FlutterDownloader.resume(taskId: item.taskId);
      if (newTaskId == null) {
        tec.dmPrint('FlutterDownloader.resume(\'${item.url}\') returned null!');
      } else {
        final newItems = Map.of(state.items); // shallow copy
        newItems[volumeId] = newItems[volumeId].copyWith(taskId: newTaskId);
        add(state.copyWith(items: newItems));
      }
    }
  }

  // Future<void> retryDownload(int volumeId) async {
  //   String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
  //   task.taskId = newTaskId;
  // }

  @override
  Future<void> deleteDownload(int volumeId) async {
    // TODO(ron): ...
    // await FlutterDownloader.remove(
    //     taskId: task.taskId, shouldDeleteContent: true);
    // await _prepare();
    // setState(() {});
  }

  //
  // PRIVATE STUFF
  //

  final ReceivePort _port = ReceivePort();
  String _downloadsDir;
  String _unzipDir;

  void _bindBackgroundIsolate() {
    final isSuccess =
        IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (isDebugMode) {
        tec.dmPrint('UI Isolate Callback: $data');
      }
      if (!isClosed && data is List<dynamic>) {
        final taskId = tec.as<String>(data[0]);
        final status = tec.as<DownloadTaskStatus>(data[1]);
        final progress = tec.as<int>(data[2]);
        final volumeId = state.items.values
            .firstWhere((item) => item.taskId == taskId, orElse: () => null)
            ?.volumeId;
        if (volumeId != null && taskId != null && status != null && progress != null) {
          final newItems = Map.of(state.items); // shallow copy
          final item = newItems[volumeId];
          final newItem = item.copyWith(
            status: status._toDownloadStatus(),
            progress: progress / 100.0,
          );
          newItems[volumeId] = newItem;
          add(state.copyWith(items: newItems));

          // If just completed download, and it's a zip file, unzip it...
          if (newItem.status == DownloadStatus.complete &&
              item.status != DownloadStatus.complete &&
              newItem.url.endsWith('.zip')) {
            _unzipFile(path.basename(item.url));
          }
        }
      }
    });
  }

  Future<bool> _unzipFile(String zipFilename) async {
    var successful = false;
    final zipFile = File(path.join(_downloadsDir, zipFilename));
    if (zipFile.existsSync()) {
      final stopwatch = Stopwatch()..start();
      successful = await tec.unzipFile(zipFile.path, toDir: _unzipDir);
      tec.dmPrint('Unzipping $zipFilename took ${stopwatch.elapsed}');
    }
    return successful;
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void _downloadCallback(String id, DownloadTaskStatus status, int progress) {
    if (isDebugMode) {
      tec.dmPrint(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> _loadDownloadTasks() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (isClosed) return;

    final newItems = Map.of(state.items); // shallow copy

    for (final task in tasks) {
      final volumeId = _volumeIdFromUrl(task.url);
      if (volumeId <= 0) continue;
      final status = task.status?._toDownloadStatus() ?? DownloadStatus.undefined;
      final progress = (task.progress ?? 0.0) / 100.0;
      newItems[volumeId] = newItems[volumeId]?.copyWith(
            volumeId: volumeId,
            url: task.url,
            taskId: task.taskId,
            status: status,
            progress: progress,
          ) ??
          DownloadItem(
            volumeId: volumeId,
            url: task.url,
            taskId: task.taskId,
            status: status,
            progress: progress,
          );
    }

    // Check permissions...
    final permissionReady = await _checkPermission();

    // Create the `downloads` dir if needed...
    _unzipDir = await _findLocalPath();
    _downloadsDir = '$_unzipDir${Platform.pathSeparator}downloads';
    final dir = Directory(_downloadsDir);
    if (!dir.existsSync()) {
      await dir.create();
    }

    add(state.copyWith(isLoading: false, permissionReady: permissionReady, items: newItems));
  }

  Future<String> _findLocalPath() async {
    final directory = tec.platformIs(tec.Platform.android)
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> _checkPermission() async {
    if (tec.platformIs(tec.Platform.android)) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
}

extension on DownloadTaskStatus {
  DownloadStatus _toDownloadStatus() {
    if (this == DownloadTaskStatus.enqueued) return DownloadStatus.enqueued;
    if (this == DownloadTaskStatus.running) return DownloadStatus.running;
    if (this == DownloadTaskStatus.complete) return DownloadStatus.complete;
    if (this == DownloadTaskStatus.failed) return DownloadStatus.failed;
    if (this == DownloadTaskStatus.canceled) return DownloadStatus.canceled;
    if (this == DownloadTaskStatus.paused) return DownloadStatus.paused;
    assert(this == DownloadTaskStatus.undefined);
    return DownloadStatus.undefined;
  }
}

int _volumeIdFromUrl(String url) {
  if (url == null || url.isEmpty || !url.endsWith('.zip')) return 0;
  final i = url.lastIndexOf('/') + 1;
  if (i > 0) {
    final j = url.indexOf('-', i);
    if (j > i) {
      return int.tryParse(url.substring(i, j)) ?? 0;
    }
  }
  return 0;
}

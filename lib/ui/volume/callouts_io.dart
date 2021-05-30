import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

const _calloutsDBName = 'callouts.sqlite';
Database _calloutsDB;

Future<void> copyCalloutsDB() async {
  // Construct a file path to copy database to
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, _calloutsDBName);

  // TODO(mike): - also need to add modified check

  // Only copy if the database doesn't exist
  if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
    // Load database from asset and copy
    final data = await rootBundle.load(join('assets', _calloutsDBName));
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await File(path).writeAsBytes(bytes);
  }
}

Future<ErrorOrValue<Map<int, Map<int, ResourceIntro>>>> chapterCallouts(
    BookChapterVerse ref) async {
  try {
    if (_calloutsDB == null || !_calloutsDB.isOpen) {
      final path = join(await getDatabasesPath(), _calloutsDBName);
      _calloutsDB = await openDatabase(path);
    }

    final offset = random(min: 1, max: 4);

    final results = await _calloutsDB.rawQuery(
        'select c.volumeId, c.itemId, l.learn, verse from callouts c, learn l where'
        ' c.volumeId = l.volumeId and c.itemId = l.itemId and book = ? and chapter = ?'
        ' and verse % 10 = ? order by verse',
        [ref.book, ref.chapter, ref.verse + offset]);

    final callouts = <int, Map<int, ResourceIntro>>{};

    for (final result in results) {
      callouts[as<int>(result['verse'])] = {
        as<int>(result['volumeId']): ResourceIntro(
            as<int>(result['itemId']), ResourceType.studyNote, as<String>(result['learn']))
      };
    }

    return ErrorOrValue<Map<int, Map<int, ResourceIntro>>>(null, callouts);
  } catch (e) {
    return ErrorOrValue<Map<int, Map<int, ResourceIntro>>>(
        TecVolumesError('chapterCallouts for ${ref.book}/${ref.chapter} failed. $e'), null);
  }
}

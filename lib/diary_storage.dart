import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'diary_entry.dart';

class DiaryStorage {
  DiaryStorage({this.directoryProvider});

  final Future<Directory> Function()? directoryProvider;
  Future<void> _saveQueue = Future<void>.value();

  Future<List<DiaryEntry>?> loadEntries(String accountId) async {
    final file = await _fileFor(accountId);
    if (!await file.exists()) return null;

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! List) {
      throw const FormatException('Invalid diary data');
    }
    return decoded
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const FormatException('Invalid diary entry');
          }
          return DiaryEntry.fromJson(entry);
        })
        .toList(growable: true);
  }

  Future<void> saveEntries(String accountId, List<DiaryEntry> entries) {
    final snapshot = entries.map((entry) => entry.toJson()).toList();
    final save = _saveQueue.then((_) => _writeEntries(accountId, snapshot));
    _saveQueue = save.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return save;
  }

  Future<void> _writeEntries(
    String accountId,
    List<Map<String, Object?>> entries,
  ) async {
    final file = await _fileFor(accountId);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(entries), flush: true);
  }

  Future<File> _fileFor(String accountId) async {
    final baseDirectory = directoryProvider == null
        ? await getApplicationDocumentsDirectory()
        : await directoryProvider!();
    final safeId = base64Url.encode(utf8.encode(accountId)).replaceAll('=', '');
    return File('${baseDirectory.path}/flower_finder/diary_$safeId.json');
  }
}

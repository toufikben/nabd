import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// BackupService — نسخ احتياطي محلي + تصدير/استيراد.
class BackupService {
  /// تصدير كل البيانات كـ ZIP.
  Future<File> createBackup({String? password}) async {
    final docs = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final archive = Archive();

    // ─── 1. Journal entries ───
    final entriesBox = Hive.box('journal_entries');
    final entriesJson = entriesBox.values.toList();
    final entriesBytes = utf8.encode(jsonEncode(entriesJson));
    archive.addFile(ArchiveFile('entries.json', entriesBytes.length, entriesBytes));

    // ─── 2. Settings ───
    final settingsBox = Hive.box('settings');
    final settingsJson = Map<String, dynamic>.fromEntries(
      settingsBox.keys.map((k) => MapEntry(k.toString(), settingsBox.get(k))),
    );
    final settingsBytes = utf8.encode(jsonEncode(settingsJson));
    archive.addFile(ArchiveFile('settings.json', settingsBytes.length, settingsBytes));

    // ─── 3. Images ───
    final imagesDir = Directory('${docs.path}/images');
    if (await imagesDir.exists()) {
      for (final file in imagesDir.listSync()) {
        if (file is File) {
          final name = p.basename(file.path);
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile('images/$name', bytes.length, bytes));
        }
      }
    }

    // ─── 4. Audio ───
    final audioDir = Directory('${docs.path}/audio');
    if (await audioDir.exists()) {
      for (final file in audioDir.listSync()) {
        if (file is File) {
          final name = p.basename(file.path);
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile('audio/$name', bytes.length, bytes));
        }
      }
    }

    // ─── 5. Metadata ───
    final meta = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'entryCount': entriesBox.length,
    };
    final metaBytes = utf8.encode(jsonEncode(meta));
    archive.addFile(ArchiveFile('metadata.json', metaBytes.length, metaBytes));

    // ─── 6. Encode ZIP ───
    var zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw Exception('Failed to create ZIP');
    }

    // ─── 7. Encrypt if password provided ───
    if (password != null && password.isNotEmpty) {
      // Simple XOR-based encryption for the ZIP
      zipBytes = _simpleEncrypt(zipBytes, password);
    }

    // ─── 8. Save ───
    final filename =
        'journal_backup_${DateTime.now().millisecondsSinceEpoch}.${password != null ? 'enc' : 'zip'}';
    final backupFile = File('${tempDir.path}/$filename');
    await backupFile.writeAsBytes(zipBytes);

    return backupFile;
  }

  /// استيراد من ملف ZIP.
  Future<ImportResult> restoreBackup(
    String backupPath, {
    String? password,
  }) async {
    try {
      var bytes = await File(backupPath).readAsBytes();

      // Decrypt if needed
      if (password != null && password.isNotEmpty) {
        bytes = _simpleEncrypt(bytes, password); // XOR is symmetric
      }

      final archive = ZipDecoder().decodeBytes(bytes);

      var imported = 0;
      var imagesRestored = 0;
      var audioRestored = 0;

      final docs = await getApplicationDocumentsDirectory();

      for (final file in archive) {
        if (!file.isFile) continue;

        final name = file.name;
        final content = file.content as List<int>;

        // ─── Entries ───
        if (name == 'entries.json') {
          final entries = jsonDecode(utf8.decode(content)) as List;
          final box = Hive.box('journal_entries');
          for (final entry in entries) {
            final map = Map<String, dynamic>.from(entry as Map);
            final id = map['id']?.toString() ?? '';
            if (id.isNotEmpty) {
              await box.put(id, map);
              imported++;
            }
          }
        }

        // ─── Settings ───
        else if (name == 'settings.json') {
          final settings = jsonDecode(utf8.decode(content)) as Map;
          final box = Hive.box('settings');
          for (final e in settings.entries) {
            await box.put(e.key.toString(), e.value);
          }
        }

        // ─── Images ───
        else if (name.startsWith('images/')) {
          final filename = name.substring(7);
          final imagesDir = Directory('${docs.path}/images');
          if (!await imagesDir.exists()) {
            await imagesDir.create(recursive: true);
          }
          await File('${imagesDir.path}/$filename').writeAsBytes(content);
          imagesRestored++;
        }

        // ─── Audio ───
        else if (name.startsWith('audio/')) {
          final filename = name.substring(6);
          final audioDir = Directory('${docs.path}/audio');
          if (!await audioDir.exists()) {
            await audioDir.create(recursive: true);
          }
          await File('${audioDir.path}/$filename').writeAsBytes(content);
          audioRestored++;
        }
      }

      return ImportResult(
        ok: true,
        entriesImported: imported,
        imagesRestored: imagesRestored,
        audioRestored: audioRestored,
      );
    } catch (e) {
      return ImportResult(ok: false, error: '$e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Simple symmetric encryption
  // ═══════════════════════════════════════════════════════════

  List<int> _simpleEncrypt(List<int> data, String password) {
    final key = utf8.encode(password);
    final out = List<int>.filled(data.length, 0);

    for (var i = 0; i < data.length; i++) {
      out[i] = data[i] ^ key[i % key.length];
    }

    return out;
  }
}

class ImportResult {
  final bool ok;
  final int entriesImported;
  final int imagesRestored;
  final int audioRestored;
  final String? error;

  const ImportResult({
    required this.ok,
    this.entriesImported = 0,
    this.imagesRestored = 0,
    this.audioRestored = 0,
    this.error,
  });
}

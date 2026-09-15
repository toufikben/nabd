import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// PrivacyService — حذف البيانات المحلية.
class PrivacyService {
  Future<void> deleteEverything() async {
    // Hive boxes
    await Hive.box('journal_entries').clear();
    await Hive.box('settings').clear();
    await Hive.box('moods').clear();
    await Hive.box('tags').clear();

    // Media files
    final docs = await getApplicationDocumentsDirectory();
    for (final dir in ['images', 'audio']) {
      final d = Directory('${docs.path}/$dir');
      if (await d.exists()) {
        await d.delete(recursive: true);
      }
    }
  }

  Future<int> getStorageUsageBytes() async {
    var total = 0;

    // Hive files
    final docs = await getApplicationDocumentsDirectory();
    for (final file in docs.listSync(recursive: true)) {
      if (file is File) {
        total += await file.length();
      }
    }

    return total;
  }
}

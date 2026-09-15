import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';
import '../models/tag.dart';

class DatabaseService {
  Box get entriesBox => Hive.box('journal_entries');
  Box get tagsBox => Hive.box('tags');
  Future<void> addEntry(JournalEntry entry) => entriesBox.put(entry.id, entry.toMap());
  Future<void> updateEntry(JournalEntry entry) => entriesBox.put(entry.id, entry.toMap());
  Future<void> deleteEntry(String id) => entriesBox.delete(id);
  List<JournalEntry> getAllEntries() => entriesBox.values.map((e) => JournalEntry.fromMap(Map<dynamic, dynamic>.from(e as Map))).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<JournalEntry> getEntriesForDate(DateTime date) => getAllEntries().where((e) => e.createdAt.year == date.year && e.createdAt.month == date.month && e.createdAt.day == date.day).toList();
  List<JournalEntry> searchEntries(String query) { final q = query.toLowerCase(); return getAllEntries().where((e) => e.title.toLowerCase().contains(q) || e.content.toLowerCase().contains(q) || e.tags.any((t) => t.toLowerCase().contains(q))).toList(); }
  List<JournalEntry> getFavoriteEntries() => getAllEntries().where((e) => e.isFavorite).toList();
  int getEntryCount() => entriesBox.length;
  int getWordCount() => getAllEntries().fold(0, (sum, e) => sum + (e.content.trim().isEmpty ? 0 : e.content.trim().split(RegExp(r'\s+')).length));
  Future<void> saveTag(Tag tag) => tagsBox.put(tag.id, {'id': tag.id, 'name': tag.name, 'color': tag.color, 'usageCount': tag.usageCount});
  List<Tag> getAllTags() => tagsBox.isEmpty ? Tag.defaultTags : tagsBox.values.map((e) { final m = Map<dynamic, dynamic>.from(e as Map); return Tag(id: m['id']?.toString() ?? '', name: m['name']?.toString() ?? '', color: (m['color'] as num?)?.toInt() ?? 0xFF6C5CE7, usageCount: (m['usageCount'] as num?)?.toInt() ?? 0); }).toList();
  Map<String, int> getMoodDistribution() { final out = <String, int>{}; for (final e in getAllEntries()) { if (e.mood.isNotEmpty) out[e.mood] = (out[e.mood] ?? 0) + 1; } return out; }
  Map<DateTime, int> getStreakData() { final out = <DateTime, int>{}; for (final e in getAllEntries()) { final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day); out[d] = (out[d] ?? 0) + 1; } return out; }
}

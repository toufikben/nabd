import 'package:flutter_test/flutter_test.dart';
import 'package:nabd/services/backup_service.dart';

void main() {
  test('accepts only known backup paths', () {
    expect(BackupService.isSafeArchivePath('entries.json'), isTrue);
    expect(BackupService.isSafeArchivePath('images/photo.jpg'), isTrue);
    expect(BackupService.isSafeArchivePath('audio/voice.m4a'), isTrue);
  });

  test('rejects traversal, absolute and encoded traversal paths', () {
    expect(BackupService.isSafeArchivePath('../entries.json'), isFalse);
    expect(BackupService.isSafeArchivePath(r'..\entries.json'), isFalse);
    expect(BackupService.isSafeArchivePath('/tmp/entries.json'), isFalse);
    expect(BackupService.isSafeArchivePath('%2e%2e/entries.json'), isFalse);
    expect(BackupService.isSafeArchivePath('images/../settings.json'), isFalse);
  });

  test('does not treat entitlement files as a supported archive path', () {
    expect(BackupService.isSafeArchivePath('is_pro.json'), isFalse);
  });
}

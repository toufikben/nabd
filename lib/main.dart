import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/biometric_service.dart';
import 'services/encryption_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Hive boxes ───
  await Hive.initFlutter();
  await Hive.openBox('journal_entries');
  await Hive.openBox('settings');
  await Hive.openBox('moods');
  await Hive.openBox('tags');
  await Hive.openBox('garden');

  // ─── Services ───
  await NotificationService.init();
  await SettingsService.init();

  // ─── Encryption key ───
  final enc = EncryptionService();
  if (!await enc.isEnabled()) {
    await enc.generateMasterKey();
  }

  // ─── Biometric (optional) ───
  final bio = BiometricService();
  await bio.updateLastActivity();

  // ─── System UI ───
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: NabdApp()));
}

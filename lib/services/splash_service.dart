import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// SplashService — يدير السبلاش الدوّار + الأصوات.
class SplashService {
  static const _channel = MethodChannel('com.productchat/splash');
  static const _splashCount = 5;

  /// يشغّل صوتًا.
  Future<void> playSplashSound(String soundId) async {
    try {
      await _channel.invokeMethod('playSound', {'soundId': soundId});
    } on MissingPluginException {
      debugPrint('Splash sound is unavailable on this platform.');
    } on PlatformException catch (error) {
      debugPrint('Splash sound failed: ${error.code}');
    }
  }

  Future<void> stopSplashSound() async {
    try {
      await _channel.invokeMethod('stopSound');
    } on MissingPluginException {
      debugPrint('Splash sound stop is unavailable on this platform.');
    } on PlatformException catch (error) {
      debugPrint('Splash sound stop failed: ${error.code}');
    }
  }

  /// يعيد splash التالي (لا يكرر السابق مباشرة).
  ///
  /// المنطق: random exclude previous.
  static int getNextSplash() {
    final box = Hive.box('settings');
    final last = box.get('last_splash_id', defaultValue: 0) as int;

    int next;
    do {
      next = DateTime.now().microsecondsSinceEpoch % _splashCount + 1;
    } while (next == last && _splashCount > 1);

    unawaited(box.put('last_splash_id', next));
    return next;
  }

  /// Sound المرتبط بكل splash.
  static String defaultSoundFor(int splashId) {
    switch (splashId) {
      case 1:
        return 'rain_soft';
      case 2:
        return 'flute_dawn';
      case 3:
        return 'harp_soft';
      case 4:
        return 'oud_soft';
      case 5:
        return 'tibetan_bowl';
      default:
        return 'piano_gentle';
    }
  }
}

class SplashOption {
  final int id;
  final String name;
  final String description;
  final String emoji;
  final List<String> sounds;

  const SplashOption({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.sounds,
  });

  static const all = [
    SplashOption(
      id: 1,
      name: 'First Seed',
      description: 'بذرة تسقط وتنبت',
      emoji: '🌱',
      sounds: ['rain_soft', 'piano_gentle'],
    ),
    SplashOption(
      id: 2,
      name: 'New Dawn',
      description: 'شروق الشمس خلف الجبال',
      emoji: '🌅',
      sounds: ['flute_dawn', 'birds_distant'],
    ),
    SplashOption(
      id: 3,
      name: 'Book to Butterfly',
      description: 'كتاب يتحول إلى فراشات',
      emoji: '🦋',
      sounds: ['paper_turn', 'harp_soft'],
    ),
    SplashOption(
      id: 4,
      name: 'Candle Light',
      description: 'شمعة تضيء غرفة دافئة',
      emoji: '🕯️',
      sounds: ['oud_soft', 'whisper_gentle'],
    ),
    SplashOption(
      id: 5,
      name: 'Circle of Life',
      description: 'دائرة ضوء تكشف شجرة',
      emoji: '💫',
      sounds: ['tibetan_bowl', 'drums_soft'],
    ),
  ];
}

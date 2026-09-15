import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// SoundscapeService — أصوات محيطة للكتابة.
///
/// ملاحظة: يستخدم أصوات النظام أو ملفات صوتية في assets.
class SoundscapeService extends StateNotifier<SoundscapeState> {
  SoundscapeService() : super(const SoundscapeState());

  /// تفعيل/تعطيل الصوت.
  Future<void> toggle() async {
    state = state.copyWith(enabled: !state.enabled);
    await Hive.box('settings').put('soundscape_enabled', state.enabled);
  }

  /// تغيير نوع الصوت.
  Future<void> setType(String type) async {
    state = state.copyWith(type: type);
    await Hive.box('settings').put('soundscape_type', type);
  }

  /// تغيير مستوى الصوت.
  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await Hive.box('settings').put('soundscape_volume', volume);
  }

  void load() {
    final box = Hive.box('settings');
    state = SoundscapeState(
      enabled: box.get('soundscape_enabled', defaultValue: false) as bool,
      type: box.get('soundscape_type', defaultValue: 'rain') as String,
      volume: (box.get('soundscape_volume', defaultValue: 0.5) as num).toDouble(),
    );
  }
}

class SoundscapeState {
  final bool enabled;
  final String type;
  final double volume;

  const SoundscapeState({
    this.enabled = false,
    this.type = 'rain',
    this.volume = 0.5,
  });

  SoundscapeState copyWith({
    bool? enabled,
    String? type,
    double? volume,
  }) =>
      SoundscapeState(
        enabled: enabled ?? this.enabled,
        type: type ?? this.type,
        volume: volume ?? this.volume,
      );
}

class SoundscapeOption {
  final String id;
  final String emoji;
  final String labelEn;
  final String labelAr;

  const SoundscapeOption({
    required this.id,
    required this.emoji,
    required this.labelEn,
    required this.labelAr,
  });

  static const all = [
    SoundscapeOption(id: 'rain', emoji: '🌧️', labelEn: 'Rain', labelAr: 'مطر'),
    SoundscapeOption(id: 'forest', emoji: '🌲', labelEn: 'Forest', labelAr: 'غابة'),
    SoundscapeOption(id: 'ocean', emoji: '🌊', labelEn: 'Ocean', labelAr: 'محيط'),
    SoundscapeOption(id: 'cafe', emoji: '☕', labelEn: 'Café', labelAr: 'مقهى'),
    SoundscapeOption(id: 'fire', emoji: '🔥', labelEn: 'Fireplace', labelAr: 'مدفأة'),
    SoundscapeOption(id: 'night', emoji: '🌙', labelEn: 'Night', labelAr: 'ليل'),
    SoundscapeOption(id: 'wind', emoji: '💨', labelEn: 'Wind', labelAr: 'رياح'),
    SoundscapeOption(id: 'birds', emoji: '🐦', labelEn: 'Birds', labelAr: 'طيور'),
  ];
}

final soundscapeProvider =
    StateNotifierProvider<SoundscapeService, SoundscapeState>(
  (ref) => SoundscapeService(),
);

class AppSettings {
  const AppSettings._();

  /// يمكن تعطيل صوت البداية مؤقتًا عبر --dart-define.
  static const bool splashSoundEnabled = bool.fromEnvironment(
    'SPLASH_SOUND_ENABLED',
    defaultValue: true,
  );

  /// هذه القائمة تعكس الملفات الموجودة فعليًا في assets/sounds.
  static const Set<String> availableSounds = {
    'rain_soft',
    'tibetan_bowl',
  };

  static bool hasSoundFile(String soundId) => availableSounds.contains(soundId);

  static String fallbackSound(String requested) {
    return hasSoundFile(requested) ? requested : 'rain_soft';
  }
}

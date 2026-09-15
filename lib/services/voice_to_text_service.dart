import 'package:speech_to_text/speech_to_text.dart';

class VoiceToTextService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  Future<bool> initialize() async { if (_initialized) return true; _initialized = await _speech.initialize(); return _initialized; }
  Future<void> startListening({required Function(String) onResult, String localeId = 'en-US'}) async { if (!await initialize()) return; await _speech.listen(options: SpeechListenOptions(localeId: localeId), onResult: (result) => onResult(result.recognizedWords)); }
  Future<void> stopListening() => _speech.stop();
  bool get isListening => _speech.isListening;
}

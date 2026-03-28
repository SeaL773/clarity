import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  String? lastError;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) {
        lastError = error.errorMsg;
      },
      onStatus: (status) {},
    );
    if (!_isInitialized) {
      lastError = 'Speech recognition not available on this device';
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    Function(String error)? onError,
  }) async {
    if (!_isInitialized) {
      final available = await initialize();
      if (!available) {
        onError?.call(lastError ?? 'Speech recognition unavailable');
        return;
      }
    }
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize({Function(String error)? onError}) async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (error) {
        onError?.call(error.errorMsg);
      },
      onStatus: (_) {},
    );

    if (!_isInitialized) {
      onError?.call('Speech recognition not available on this device');
    }

    return _isInitialized;
  }

  Future<void> startListening({
    required void Function() onListeningStarted,
    required Function(String text) onResult,
    Function(String error)? onError,
  }) async {
    final available = await initialize(onError: onError);
    if (!available) return;

    onListeningStarted();
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

  void dispose() {}
}

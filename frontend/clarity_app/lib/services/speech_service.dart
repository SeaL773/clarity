import '../models/speech_input_mode.dart';
import 'speech_to_text_service.dart';
import 'whisper_speech_service.dart';

class SpeechService {
  final WhisperSpeechService _whisperService = WhisperSpeechService();
  final SpeechToTextService _speechToTextService = SpeechToTextService();

  bool get isListening =>
      _whisperService.isListening || _speechToTextService.isListening;

  Future<void> startListening({
    required SpeechInputMode mode,
    required void Function() onListeningStarted,
    required Function(String text) onResult,
    Function(String error)? onError,
  }) async {
    switch (mode) {
      case SpeechInputMode.whisper:
        await _whisperService.startListening(
          onRecordingStarted: onListeningStarted,
          onError: onError,
        );
        break;
      case SpeechInputMode.device:
        await _speechToTextService.startListening(
          onListeningStarted: onListeningStarted,
          onResult: onResult,
          onError: onError,
        );
        break;
    }
  }

  Future<void> stopListening({
    required SpeechInputMode mode,
    required Function(String text) onResult,
    Function()? onProcessing,
    Function(String error)? onError,
  }) async {
    switch (mode) {
      case SpeechInputMode.whisper:
        await _whisperService.stopListening(
          onResult: onResult,
          onProcessing: onProcessing,
          onError: onError,
        );
        break;
      case SpeechInputMode.device:
        await _speechToTextService.stopListening();
        break;
    }
  }

  void dispose() {
    _whisperService.dispose();
    _speechToTextService.dispose();
  }
}

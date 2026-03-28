class WhisperSpeechService {
  bool get isListening => false;

  Future<bool> initialize() async => false;

  Future<void> startListening({
    required void Function() onRecordingStarted,
    Function(String error)? onError,
  }) async {
    onError?.call('Whisper voice input is not supported on web yet');
  }

  Future<void> stopListening({
    required Function(String text) onResult,
    Function()? onProcessing,
    Function(String error)? onError,
  }) async {
    onError?.call('Whisper voice input is not supported on web yet');
  }

  void dispose() {}
}

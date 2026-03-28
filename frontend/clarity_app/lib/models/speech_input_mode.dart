enum SpeechInputMode {
  whisper,
  device,
}

// Developer switch: true uses Whisper, false uses speech_to_text.
const bool kUseWhisper = false;

SpeechInputMode get defaultSpeechInputMode =>
    kUseWhisper ? SpeechInputMode.whisper : SpeechInputMode.device;

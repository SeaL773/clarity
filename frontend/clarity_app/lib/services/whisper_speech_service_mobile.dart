import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'api_service.dart';

class WhisperSpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  final ApiService _apiService = ApiService();

  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isListening => _isRecording;

  Future<bool> initialize() async {
    return _recorder.hasPermission();
  }

  Future<void> startListening({
    required void Function() onRecordingStarted,
    Function(String error)? onError,
  }) async {
    final available = await initialize();
    if (!available) {
      onError?.call('Microphone permission denied');
      return;
    }

    final directory = await getTemporaryDirectory();
    final filePath = path.join(
      directory.path,
      'clarity_whisper_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    _currentRecordingPath = filePath;
    _isRecording = true;
    onRecordingStarted();
  }

  Future<void> stopListening({
    required Function(String text) onResult,
    Function()? onProcessing,
    Function(String error)? onError,
  }) async {
    if (!_isRecording) return;

    final recordedPath = await _recorder.stop();
    _isRecording = false;
    final audioPath = recordedPath ?? _currentRecordingPath;
    _currentRecordingPath = null;

    if (audioPath == null) {
      onError?.call('Recording failed');
      return;
    }

    final audioFile = File(audioPath);
    if (!await audioFile.exists()) {
      onError?.call('Recorded audio file was not found');
      return;
    }

    try {
      onProcessing?.call();
      final text = await _apiService.transcribeAudio(audioPath);
      if (text.isEmpty) {
        onError?.call('Whisper returned empty text');
        return;
      }
      onResult(text);
    } on DioException catch (e) {
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail'] as String?)
          : null;
      onError?.call(detail ?? 'Whisper transcription failed');
    } catch (_) {
      onError?.call('Whisper transcription failed');
    } finally {
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../models/speech_input_mode.dart';
import '../providers/task_provider.dart';
import '../services/api_service.dart';
import '../services/speech_service.dart';

class BrainDumpInput extends StatefulWidget {
  final VoidCallback? onCollapse;
  const BrainDumpInput({super.key, this.onCollapse});

  @override
  State<BrainDumpInput> createState() => _BrainDumpInputState();
}

class _BrainDumpInputState extends State<BrainDumpInput> {
  final TextEditingController _controller = TextEditingController();
  final SpeechService _speechService = SpeechService();
  final ApiService _apiService = ApiService();
  bool _isListening = false;
  bool _isTranscribing = false;
  bool _expanded = false;
  String? _speechError;

  @override
  void dispose() {
    _speechService.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    final speechInputMode = context.read<TaskProvider>().speechInputMode;

    if (_isListening) {
      await _speechService.stopListening(
        mode: speechInputMode,
        onProcessing: () {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _isTranscribing = true;
            _speechError = null;
          });
        },
        onResult: (text) {
          if (!mounted) return;
          final currentText = _controller.text.trim();
          final mergedText = currentText.isEmpty ? text : '$currentText $text';
          _controller.text = mergedText;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          setState(() {
            _isListening = false;
            _isTranscribing = false;
            _speechError = null;
            _expanded = true;
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _isTranscribing = false;
            _speechError = error;
          });
        },
      );
      if (!mounted) return;
      if (speechInputMode == SpeechInputMode.device) {
        setState(() {
          _isListening = false;
          _isTranscribing = false;
          _speechError = null;
        });
      }
    } else {
      setState(() {
        _isListening = true;
        _isTranscribing = false;
        _speechError = null;
        _expanded = true;
      });
      await _speechService.startListening(
        mode: speechInputMode,
        onListeningStarted: () {
          if (!mounted) return;
          setState(() {
            _isListening = true;
            _isTranscribing = false;
          });
        },
        onResult: (text) {
          if (!mounted) return;
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _isTranscribing = false;
            _speechError = error;
          });
        },
      );
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<TaskProvider>().processBrainDump(text);
    _controller.clear();
    setState(() => _expanded = false);
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickAndUploadAudio() async {
    setState(() {
      _expanded = true;
      _isTranscribing = true;
      _speechError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'mp4', 'mpeg', 'mpga', 'webm'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isTranscribing = false;
        });
        return;
      }

      final file = result.files.single;
      final text = await _apiService.transcribeAudioFile(
        filename: file.name,
        filePath: file.path,
        bytes: file.bytes,
      );

      if (!mounted) return;
      final currentText = _controller.text.trim();
      final mergedText = currentText.isEmpty ? text : '$currentText $text';
      _controller.text = mergedText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      setState(() {
        _isTranscribing = false;
        _speechError = null;
      });
    } on DioException catch (e) {
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail'] as String?)
          : null;
      if (!mounted) return;
      setState(() {
        _isTranscribing = false;
        _speechError = detail ?? 'Audio upload failed';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTranscribing = false;
        _speechError = 'Audio upload failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isLoading = provider.isLoading;
    final speechInputMode = provider.speechInputMode;
    final theme = Theme.of(context);
    final isBusy = isLoading || _isTranscribing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? const Color(0xFF252320) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: _expanded ? 4 : 1,
                minLines: 1,
                enabled: !isBusy,
                onTap: () {
                  setState(() {
                    _expanded = true;
                    _speechError = null;
                  });
                },
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                decoration: InputDecoration(
                  hintText: 'What do you need to do?',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                ),
              ),
              // Action row
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  children: [
                    // Mic button
                    _CircleButton(
                      icon: _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: _isListening ? Colors.red.shade400 : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                      bgColor: _isListening ? Colors.red.shade50 : Colors.transparent,
                      onPressed: isBusy ? null : _toggleListening,
                      size: 36,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 4),
                    _CircleButton(
                      icon: Icons.audio_file_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                      bgColor: Colors.transparent,
                      onPressed: isBusy ? null : _pickAndUploadAudio,
                      size: 36,
                      iconSize: 19,
                    ),
                    if (_isListening)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                            speechInputMode == SpeechInputMode.whisper
                                ? 'Recording...'
                                : 'Listening...',
                            style: TextStyle(color: Colors.red.shade300, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    if (_isTranscribing)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          'Transcribing...',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Submit
                    SizedBox(
                      height: 36,
                      child: FilledButton.icon(
                        onPressed: isBusy ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: Text(isLoading ? 'Thinking...' : 'Clarity',
                            style: const TextStyle(fontSize: 13)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_speechError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _speechError!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onPressed,
    this.size = 40,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(child: Icon(icon, size: iconSize, color: color)),
        ),
      ),
    );
  }
}

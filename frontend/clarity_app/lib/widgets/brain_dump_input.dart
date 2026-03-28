import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/speech_service.dart';

class BrainDumpInput extends StatefulWidget {
  const BrainDumpInput({super.key});

  @override
  State<BrainDumpInput> createState() => _BrainDumpInputState();
}

class _BrainDumpInputState extends State<BrainDumpInput> {
  final TextEditingController _controller = TextEditingController();
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speechService.startListening(
        onResult: (text) {
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        },
      );
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<TaskProvider>().processBrainDump(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskProvider>().isLoading;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 2,
            enabled: !isLoading,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            decoration: InputDecoration(
              hintText: 'Just dump everything here...\ntasks, thoughts, worries, plans...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                height: 1.5,
              ),
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Mic button
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.red.shade50
                      : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: isLoading ? null : _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 20,
                    color: _isListening ? Colors.red.shade400 : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  tooltip: _isListening ? 'Stop listening' : 'Voice input',
                  padding: EdgeInsets.zero,
                ),
              ),
              if (_isListening)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Listening...',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              const Spacer(),
              // Submit button
              FilledButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(isLoading ? 'Thinking...' : 'Clarity'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

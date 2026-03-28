import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
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
  bool _isListening = false;
  bool _expanded = false;

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
      setState(() {
        _isListening = true;
        _expanded = true;
      });
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
    setState(() => _expanded = false);
    FocusScope.of(context).unfocus();
    widget.onCollapse?.call();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isLoading = provider.isLoading;
    final isTestMode = provider.isTestMode;
    final theme = Theme.of(context);

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
                enabled: !isLoading,
                onTap: () => setState(() => _expanded = true),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                decoration: InputDecoration(
                  hintText: isTestMode
                      ? 'Input text to generate local demo tasks'
                      : 'What do you need to do?',
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
                      onPressed: isLoading ? null : _toggleListening,
                      size: 36,
                    ),
                    if (_isListening)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text('Listening...',
                            style: TextStyle(color: Colors.red.shade300, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    const Spacer(),
                    // Submit
                    SizedBox(
                      height: 36,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: Text(
                            isLoading
                                ? 'Thinking...'
                                : isTestMode
                                    ? 'Generate Demo'
                                    : 'Clarity',
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

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onPressed,
    this.size = 40,
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
          child: Center(child: Icon(icon, size: 18, color: color)),
        ),
      ),
    );
  }
}

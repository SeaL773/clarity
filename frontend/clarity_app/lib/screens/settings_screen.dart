import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _aboutTapCount = 0;
  bool _dailyReminderEnabled = false;

  Future<void> _testWhisper(BuildContext context, String assetPath, String label) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transcribing $label...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 10),
      ),
    );

    try {
      // Copy asset to temp file
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Send to backend
      final api = ApiService();
      final text = await api.transcribeAudio(tempFile.path);

      // Clean up
      await tempFile.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('$label Result'),
            content: Text(text.isEmpty ? '(empty transcription)' : text),
            actions: [
              FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Whisper error: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            const SizedBox(height: 20),

            // About — tap 3 times to enable dev mode
            _SettingsSection(
              title: 'About',
              children: [
                GestureDetector(
                  onTap: () {
                    _aboutTapCount++;
                    if (_aboutTapCount >= 3 && !provider.isTestMode) {
                      provider.toggleTestMode();
                      _aboutTapCount = 0;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Development mode enabled'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (_aboutTapCount >= 3 && provider.isTestMode) {
                      provider.toggleTestMode();
                      _aboutTapCount = 0;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Development mode disabled'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    // Reset tap count after 2 seconds
                    Future.delayed(const Duration(seconds: 2), () {
                      _aboutTapCount = 0;
                    });
                  },
                  child: _SettingsTile(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Clarity',
                    subtitle: 'AI-powered smart todo list',
                    trailing: Text(
                      provider.isTestMode ? 'dev' : 'v1.0.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: provider.isTestMode
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        fontWeight: provider.isTestMode ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Designed for ADHD',
                  subtitle: 'No time pressure, encouraging feedback',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Appearance
            _SettingsSection(
              title: 'Appearance',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(Icons.dark_mode_outlined, size: 18,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dark Mode', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                            Text('Easy on the eyes', style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                          ],
                        ),
                      ),
                      _CustomToggle(
                        value: provider.isDarkMode,
                        onChanged: () => provider.toggleDarkMode(),
                        activeIcon: Icons.dark_mode_rounded,
                        inactiveIcon: Icons.light_mode_rounded,
                        activeColor: theme.colorScheme.primary,
                        inactiveIconColor: Colors.orange.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reminders
            _SettingsSection(
              title: 'Reminders',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(Icons.notifications_outlined, size: 18,
                                color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Check-in', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                Text('Gentle reminder to plan your day', style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                              ],
                            ),
                          ),
                          _CustomToggle(
                            value: _dailyReminderEnabled,
                            onChanged: () async {
                              setState(() => _dailyReminderEnabled = !_dailyReminderEnabled);
                              if (_dailyReminderEnabled) {
                                await NotificationService().scheduleDailyReminder(hour: 9, minute: 0);
                              } else {
                                await NotificationService().cancelAll();
                              }
                            },
                            activeIcon: Icons.notifications_active_rounded,
                            inactiveIcon: Icons.notifications_off_outlined,
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      // Test buttons only in dev mode
                      if (provider.isTestMode) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () async {
                              await NotificationService().showTestNotification();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Notification sent! Check your notification tray.'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Test Notification'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () => _testWhisper(context, 'assets/test_1.mp3', 'Test Voice 1'),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Test Whisper — Voice 1'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () => _testWhisper(context, 'assets/test_2.mp3', 'Test Voice 2'),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Test Whisper — Voice 2'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // How it works
            _SettingsSection(
              title: 'How it works',
              children: [
                _SettingsTile(
                  icon: Icons.edit_note_rounded,
                  title: 'Brain Dump',
                  subtitle: 'Type or speak anything on your mind',
                ),
                _SettingsTile(
                  icon: Icons.psychology_rounded,
                  title: 'AI Pipeline',
                  subtitle: '3-step: Parse → Prioritize → Organize',
                ),
                _SettingsTile(
                  icon: Icons.insights_rounded,
                  title: 'Daily Recap',
                  subtitle: 'Encouraging summary of your progress',
                ),
              ],
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Built at AWS Kiro × CS Careers Hackathon\nVirginia Tech · March 2026',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Toggle ──

class _CustomToggle extends StatelessWidget {
  final bool value;
  final VoidCallback onChanged;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final Color? inactiveIconColor;

  const _CustomToggle({
    required this.value,
    required this.onChanged,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    this.inactiveIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? activeColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                value ? activeIcon : inactiveIcon,
                size: 13,
                color: value ? activeColor : (inactiveIconColor ?? Colors.grey.shade400),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Settings Section ──

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF252320) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 1, indent: 56, color: Colors.grey.shade100),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Settings Tile ──

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

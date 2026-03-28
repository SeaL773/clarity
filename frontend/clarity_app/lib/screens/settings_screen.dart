import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

            // About section
            _SettingsSection(
              title: 'About',
              children: [
                _SettingsTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Clarity',
                  subtitle: 'AI-powered smart todo list',
                  trailing: Text('v1.0.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                ),
                _SettingsTile(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Designed for ADHD',
                  subtitle: 'No time pressure, encouraging feedback',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Features section
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
                      Switch(
                        value: provider.isDarkMode,
                        onChanged: (_) => provider.toggleDarkMode(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Coming soon
            _SettingsSection(
              title: 'Coming Soon',
              children: [
                _SettingsTile(
                  icon: Icons.calendar_month_rounded,
                  title: 'Calendar View',
                  subtitle: 'See your tasks on a calendar',
                  trailing: _ComingSoonBadge(),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Reminders',
                  subtitle: 'Gentle nudges, not nagging',
                  trailing: _ComingSoonBadge(),
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
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2024) : Colors.white,
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

class _ComingSoonBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('Soon',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.orange.shade400)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TaskProvider>();
    final thp = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(slivers: [

        // ── APP BAR ────────────────────────────────────────
        SliverAppBar(
          floating: true,
          snap: true,
          titleSpacing: 20,
          toolbarHeight: 60,
          title: Text('Settings',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: theme.textTheme.displaySmall?.color)),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── QUICK SUMMARY BANNER ───────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick Summary',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.65),
                                    letterSpacing: 0.3)),
                            const SizedBox(height: 6),
                            Row(children: [
                              _SummaryNum(
                                  value: '${tp.totalCount}',
                                  label: 'Total'),
                              const SizedBox(width: 20),
                              _SummaryNum(
                                  value: '${tp.completedCount}',
                                  label: 'Done'),
                              const SizedBox(width: 20),
                              _SummaryNum(
                                  value: '${tp.overdueTasks.length}',
                                  label: 'Overdue',
                                  danger: tp.overdueTasks.isNotEmpty),
                            ]),
                          ]),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bar_chart_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ]),
                ),

                const SizedBox(height: 24),

                // ── APPEARANCE ─────────────────────────────────
                _GroupLabel('Appearance'),
                const SizedBox(height: 8),
                _SettingsGroup(children: [
                  _Tile(
                    icon: thp.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    iconColor: AppColors.primaryLight,
                    title: 'Dark Mode',
                    subtitle: thp.isDark
                        ? 'Dark theme active'
                        : 'Light theme active',
                    trailing: Switch(
                        value: thp.isDark,
                        onChanged: (_) => thp.toggleTheme()),
                  ),
                ]),

                const SizedBox(height: 16),

                // ── DATA & BACKUP ──────────────────────────────
                _GroupLabel('Data & Backup'),
                const SizedBox(height: 8),
                _SettingsGroup(children: [
                  _Tile(
                    icon: Icons.share_rounded,
                    iconColor: AppColors.todo,
                    title: 'Export / Backup Tasks',
                    subtitle: 'Share your task list as text',
                    trailing: Icon(Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.mutedDark
                            : AppColors.mutedLight),
                    onTap: () async {
                      try {
                        await Share.share(tp.exportText(),
                            subject: 'EzzeToDo Export');
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                              content: const Text('Export failed.'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10))));
                        }
                      }
                    },
                  ),
                  _TileDivider(isDark: isDark),
                  _Tile(
                    icon: Icons.delete_sweep_outlined,
                    iconColor: AppColors.error,
                    title: 'Clear All Tasks',
                    subtitle: 'Permanently delete all tasks',
                    trailing: Icon(Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.mutedDark
                            : AppColors.mutedLight),
                    onTap: () => _showClearDialog(context, tp),
                  ),
                ]),

                const SizedBox(height: 16),

                // ── NOTIFICATIONS ──────────────────────────────
                _GroupLabel('Notifications'),
                const SizedBox(height: 8),
                _SettingsGroup(children: [
                  _Tile(
                    icon: Icons.notifications_rounded,
                    iconColor: AppColors.medium,
                    title: 'Task Reminders',
                    subtitle: 'Get notified about upcoming deadlines',
                    trailing:
                    Switch(value: true, onChanged: (_) {}),
                  ),
                  _TileDivider(isDark: isDark),
                  _Tile(
                    icon: Icons.today_rounded,
                    iconColor: AppColors.inProgress,
                    title: 'Daily Summary',
                    subtitle: 'Morning summary of today\'s tasks',
                    trailing:
                    Switch(value: false, onChanged: (_) {}),
                  ),
                ]),

                const SizedBox(height: 16),

                // ── ABOUT ──────────────────────────────────────
                _GroupLabel('About'),
                const SizedBox(height: 8),
                _SettingsGroup(children: [
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    iconColor: isDark
                        ? AppColors.mutedDark
                        : AppColors.mutedLight,
                    title: 'App Version',
                    subtitle: '1.0.0',
                  ),
                  _TileDivider(isDark: isDark),
                  _Tile(
                    icon: Icons.settings_suggest_outlined,
                    iconColor: AppColors.primary,
                    title: 'Ezze ToDo',
                    subtitle: 'Built with Claude Code',
                  ),
                ]),

              ])),
        ),
      ]),
    );
  }

  void _showClearDialog(BuildContext context, TaskProvider tp) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Clear All Tasks',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 17)),
          content: const Text(
              'This will permanently delete ALL your tasks.',
              style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  tp.clearAll();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                      content: const Text('All tasks cleared'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10))));
                },
                child: const Text('Clear All')),
          ],
        ));
  }
}

// ═══════════════════════════════════════════════════════════
// SUMMARY NUM
// ═══════════════════════════════════════════════════════════

class _SummaryNum extends StatelessWidget {
  final String value, label;
  final bool danger;
  const _SummaryNum({
    required this.value,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: danger
                  ? const Color(0xFFFFD6D6)
                  : Colors.white)),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.6))),
    ],
  );
}

// ═══════════════════════════════════════════════════════════
// GROUP LABEL
// ═══════════════════════════════════════════════════════════

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(text.toUpperCase(),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isDark
                ? AppColors.mutedDark
                : AppColors.mutedLight));
  }
}

// ═══════════════════════════════════════════════════════════
// SETTINGS GROUP
// ═══════════════════════════════════════════════════════════

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            width: 1.2),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TILE
// ═══════════════════════════════════════════════════════════

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(children: [
          // Icon box
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textDark
                              : AppColors.textLight)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mutedDark
                              : AppColors.mutedLight)),
                ]),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TILE DIVIDER
// ═══════════════════════════════════════════════════════════

class _TileDivider extends StatelessWidget {
  final bool isDark;
  const _TileDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 60),
    child: Container(
      height: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    ),
  );
}
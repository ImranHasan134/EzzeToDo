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
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
            floating: true,
            snap: true,
            titleSpacing: 16,
            title: Text('Settings',
                style: theme.textTheme.headlineMedium)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            _GL('Appearance'),
            _SC(children: [
              SettingsTile(
                  icon: thp.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: thp.isDark
                      ? 'Dark theme active'
                      : 'Light theme active',
                  iconColor: AppColors.primaryLight,
                  trailing: Switch(
                      value: thp.isDark,
                      onChanged: (_) => thp.toggleTheme())),
            ]),
            const SizedBox(height: 16),
            _GL('Data & Backup'),
            _SC(children: [
              SettingsTile(
                  icon: Icons.share_rounded,
                  title: 'Export / Backup Tasks',
                  subtitle: 'Share your task list as text',
                  iconColor: AppColors.todo,
                  onTap: () async {
                    try {
                      await Share.share(tp.exportText(),
                          subject: 'EzzeToDo Export');
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                            content:
                                const Text('Export failed.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10))));
                      }
                    }
                  }),
              const AppDivider(),
              SettingsTile(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Clear All Tasks',
                  subtitle: 'Permanently delete all tasks',
                  iconColor: AppColors.error,
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            title:
                                const Text('Clear All Tasks'),
                            content: const Text(
                                'This will permanently delete ALL your tasks.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.error),
                                  onPressed: () {
                                    tp.clearAll();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        content: const Text(
                                            'All tasks cleared'),
                                        backgroundColor:
                                            AppColors.error,
                                        behavior: SnackBarBehavior
                                            .floating,
                                        shape:
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            10))));
                                  },
                                  child:
                                      const Text('Clear All')),
                            ],
                          ))),
            ]),
            const SizedBox(height: 16),
            _GL('Notifications'),
            _SC(children: [
              SettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Task Reminders',
                  subtitle:
                      'Get notified about upcoming deadlines',
                  iconColor: AppColors.medium,
                  trailing:
                      Switch(value: true, onChanged: (_) {})),
              const AppDivider(),
              SettingsTile(
                  icon: Icons.today_rounded,
                  title: 'Daily Summary',
                  subtitle: 'Morning summary of today\'s tasks',
                  iconColor: AppColors.inProgress,
                  trailing:
                      Switch(value: false, onChanged: (_) {})),
            ]),
            const SizedBox(height: 16),
            _GL('About'),
            _SC(children: [
              SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  iconColor: AppColors.mutedLight),
              const AppDivider(),
              SettingsTile(
                  icon: Icons.favorite_rounded,
                  title: 'Ezze ToDo',
                  subtitle: 'Built with Flutter & ❤️',
                  iconColor: AppColors.error),
            ]),
            const SizedBox(height: 24),
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [
                          Color(0xFF534AB7),
                          Color(0xFF7F77DD)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Quick Summary',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _SP('${tp.totalCount} Total'),
                    const SizedBox(width: 8),
                    _SP('${tp.completedCount} Done'),
                    const SizedBox(width: 8),
                    _SP('${tp.overdueTasks.length} Overdue'),
                  ]),
                ])),
          ])),
        ),
      ]),
    );
  }
}

class _GL extends StatelessWidget {
  final String text;
  const _GL(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color:
                    Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 1.2)),
      );
}

class _SC extends StatelessWidget {
  final List<Widget> children;
  const _SC({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.5)),
        clipBehavior: Clip.hardEdge,
        child: Column(children: children),
      );
}

class _SP extends StatelessWidget {
  final String label;
  const _SP(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );
}

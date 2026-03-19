import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../widgets/common_widgets.dart';
import 'add_or_edit_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final tp = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(slivers: [

        // ── App Bar ────────────────────────────────────────
        SliverAppBar(
          floating: true,
          snap: true,
          titleSpacing: 20,
          toolbarHeight: 64,
          title: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'Ezze',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.primary)),
              TextSpan(
                  text: 'ToDo',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: theme.textTheme.displaySmall?.color)),
            ])),
          ]),
          actions: [
            if (p.overdueTasks.isNotEmpty)
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.high.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.high.withOpacity(0.3),
                          width: 1)),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 13, color: AppColors.high),
                    const SizedBox(width: 4),
                    Text('${p.overdueTasks.length} overdue',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.high)),
                  ])),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: tp.toggleTheme,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                    tp.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // ── Body ───────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          sliver: SliverList(
              delegate: SliverChildListDelegate([

            // Greeting
            Text(greeting,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    letterSpacing: 0.3)),
            const SizedBox(height: 4),
            Text("Let's get things done!",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: theme.textTheme.displaySmall?.color)),
            const SizedBox(height: 24),

            // Progress Banner
            _ProgressBanner(p: p),
            const SizedBox(height: 16),

            // Stat Row
            Row(children: [
              Expanded(
                  child: _StatCard(
                      label: 'To Do',
                      value: '${p.todoCount}',
                      accent: AppColors.todo,
                      icon: Icons.circle_outlined)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      label: 'In Progress',
                      value: '${p.inProgressCount}',
                      accent: AppColors.inProgress,
                      icon: Icons.timelapse_rounded)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      label: 'Done',
                      value: '${p.completedCount}',
                      accent: AppColors.completed,
                      icon: Icons.check_circle_rounded)),
            ]),
            const SizedBox(height: 28),

            // Today's Tasks
            _SectionLabel(
                title: "Today's Tasks", accent: AppColors.todo),
            const SizedBox(height: 12),
            if (p.todayTasks.isEmpty)
              _EmptyCard(
                emoji: '🎉',
                title: 'All caught up!',
                subtitle: 'No tasks due today.',
              )
            else
              ...p.todayTasks.take(5).map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskCard(
                        task: t,
                        onTap: () => _goDetail(context, t.id),
                        onComplete: () => p.markComplete(t.id)),
                  )),

            // High Priority
            if (p.allTasks.any((t) =>
                t.priority == Priority.high &&
                t.status != TaskStatus.completed)) ...[
              const SizedBox(height: 8),
              _SectionLabel(
                  title: 'High Priority',
                  accent: AppColors.high,
                  icon: Icons.local_fire_department_rounded),
              const SizedBox(height: 12),
              ...p.allTasks
                  .where((t) =>
                      t.priority == Priority.high &&
                      t.status != TaskStatus.completed)
                  .take(3)
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskCard(
                            task: t,
                            onTap: () => _goDetail(context, t.id),
                            onComplete: () => p.markComplete(t.id)),
                      )),
            ],
          ])),
        ),
      ]),

      // FAB
      floatingActionButton: _AddFab(onTap: () => _goAdd(context)),
    );
  }

  void _goDetail(BuildContext ctx, String id) => Navigator.push(
      ctx,
      MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: id)));

  void _goAdd(BuildContext ctx) => Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const AddOrEditScreen()));
}

// ═══════════════════════════════════════════════════════════
// PROGRESS BANNER
// ═══════════════════════════════════════════════════════════

class _ProgressBanner extends StatelessWidget {
  final TaskProvider p;
  const _ProgressBanner({required this.p});

  @override
  Widget build(BuildContext context) {
    final pct = (p.completionRate * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          // Ring
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: p.completionRate,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor:
                      Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation(
                      Colors.white),
                ),
              ),
              Text('$pct%',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5)),
            ]),
          ),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text('Overall Progress',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3)),
            const SizedBox(height: 4),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: '${p.completedCount}',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1)),
              TextSpan(
                  text: ' / ${p.totalCount} tasks',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.6))),
            ])),
          ])),
        ]),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.white.withOpacity(0.12)),
        const SizedBox(height: 14),
        Row(children: [
          _BannerPill(
              label: '${p.highCount} High',
              color: const Color(0xFFFF6B6B)),
          const SizedBox(width: 8),
          _BannerPill(
              label: '${p.mediumCount} Medium',
              color: const Color(0xFFFFB347)),
          const SizedBox(width: 8),
          _BannerPill(
              label: '${p.lowCount} Low',
              color: const Color(0xFF3DD68C)),
        ]),
      ]),
    );
  }
}

class _BannerPill extends StatelessWidget {
  final String label;
  final Color color;
  const _BannerPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color accent;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            width: 1.2),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: accent),
        ),
        const SizedBox(height: 10),
        Text(value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: accent)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.mutedDark
                    : AppColors.mutedLight)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color accent;
  final IconData? icon;
  const _SectionLabel(
      {required this.title, required this.accent, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      if (icon != null) ...[
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 6),
      ],
      Text(title,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: theme.textTheme.displaySmall?.color)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════
// EMPTY CARD
// ═══════════════════════════════════════════════════════════

class _EmptyCard extends StatelessWidget {
  final String emoji, title, subtitle;
  const _EmptyCard(
      {required this.emoji,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            width: 1.2),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textDark
                    : AppColors.textLight)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.mutedDark
                    : AppColors.mutedLight)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FAB
// ═══════════════════════════════════════════════════════════

class _AddFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFab({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded,
              color: Colors.white, size: 28),
        ),
      );
}

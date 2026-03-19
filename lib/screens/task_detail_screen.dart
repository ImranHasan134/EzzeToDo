import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../widgets/common_widgets.dart';
import 'add_or_edit_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final task = p.allTasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Task')),
          body: const Center(child: Text('Task not found.')));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.completed;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 4,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back_rounded,
                size: 18,
                color: theme.textTheme.bodySmall?.color),
          ),
        ),
        title: Text('Task Detail',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: theme.textTheme.displaySmall?.color)),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── BADGES ROW ──────────────────────────────────
              Row(children: [
                _Badge(
                    label: H.priorityLabel(task.priority),
                    color: H.priorityColor(task.priority),
                    bg: H.priorityBg(task.priority)),
                const SizedBox(width: 6),
                _Badge(
                    label: H.statusLabel(task.status),
                    color: H.statusColor(task.status),
                    bg: H.statusBg(task.status)),
                if (task.isOverdue) ...[
                  const SizedBox(width: 6),
                  _Badge(
                      label: 'Overdue',
                      color: AppColors.high,
                      bg: AppColors.highBg,
                      icon: Icons.warning_amber_rounded),
                ],
              ]),

              const SizedBox(height: 14),

              // ── TITLE ────────────────────────────────────────
              Text(task.title,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.2,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted
                          ? isDark
                          ? AppColors.mutedDark
                          : AppColors.mutedLight
                          : isDark
                          ? AppColors.textDark
                          : AppColors.textLight)),

              // ── DESCRIPTION ───────────────────────────────────
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(task.description,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark
                            ? AppColors.mutedDark
                            : AppColors.mutedLight)),
              ],

              const SizedBox(height: 20),

              // ── INFO CARD ─────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: 1.2),
                ),
                child: Column(children: [
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Deadline',
                    value: task.deadline != null
                        ? H.fmtDate(task.deadline)
                        : 'No deadline',
                    valueColor:
                    task.isOverdue ? AppColors.high : null,
                    isDark: isDark,
                  ),
                  _InfoDivider(isDark: isDark),
                  _InfoRow(
                    icon: Icons.flag_rounded,
                    label: 'Priority',
                    value: H.priorityLabel(task.priority),
                    valueColor: H.priorityColor(task.priority),
                    isDark: isDark,
                  ),
                  _InfoDivider(isDark: isDark),
                  _InfoRow(
                    icon: Icons.adjust_rounded,
                    label: 'Status',
                    value: H.statusLabel(task.status),
                    valueColor: H.statusColor(task.status),
                    isDark: isDark,
                  ),
                  _InfoDivider(isDark: isDark),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Created',
                    value: H.fmtDate(task.createdAt),
                    isDark: isDark,
                  ),
                  if (task.deadline != null) ...[
                    _InfoDivider(isDark: isDark),
                    _InfoRow(
                      icon: Icons.timer_rounded,
                      label: 'Time Left',
                      value: task.isOverdue
                          ? '${task.daysLeft.abs()} day${task.daysLeft.abs() == 1 ? '' : 's'} overdue'
                          : task.isDueToday
                          ? 'Due today'
                          : '${task.daysLeft} day${task.daysLeft == 1 ? '' : 's'} left',
                      valueColor: task.isOverdue
                          ? AppColors.high
                          : task.isDueToday
                          ? AppColors.medium
                          : null,
                      isDark: isDark,
                    ),
                  ],
                ]),
              ),

              const SizedBox(height: 20),

              // ── MARK COMPLETE ─────────────────────────────────
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      p.markComplete(task.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                          content: const Text('Task completed!'),
                          backgroundColor: AppColors.completed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10))));
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Mark as Complete',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.completed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // ── EDIT / DELETE ROW ──────────────────────────────
              Row(children: [
                Expanded(
                  child: _OutlineBtn(
                    label: 'Edit',
                    icon: Icons.edit_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AddOrEditScreen(task: task))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OutlineBtn(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: () => _del(context, task, p),
                  ),
                ),
              ]),
            ]),
      ),
    );
  }

  void _del(BuildContext ctx, Task t, TaskProvider p) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Task',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17)),
          content: Text('Delete "${t.title}"? This cannot be undone.',
              style: const TextStyle(fontSize: 14)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8))),
                onPressed: () {
                  p.deleteTask(t.id);
                  Navigator.pop(ctx);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(
                      content: const Text('Task deleted'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10))));
                },
                child: const Text('Delete')),
          ],
        ));
  }
}

// ═══════════════════════════════════════════════════════════
// BADGE
// ═══════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  final String label;
  final Color color, bg;
  final IconData? icon;
  const _Badge({
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
      ],
      Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════
// INFO ROW
// ═══════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  final bool isDark;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
    child: Row(children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.borderDark
              : AppColors.borderLight,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon,
            size: 14,
            color: isDark
                ? AppColors.mutedDark
                : AppColors.mutedLight),
      ),
      const SizedBox(width: 12),
      Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.mutedDark
                  : AppColors.mutedLight)),
      const Spacer(),
      Text(value,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ??
                  (isDark
                      ? AppColors.textDark
                      : AppColors.textLight))),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════
// INFO DIVIDER
// ═══════════════════════════════════════════════════════════

class _InfoDivider extends StatelessWidget {
  final bool isDark;
  const _InfoDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 54),
    child: Container(
      height: 1,
      color: isDark
          ? AppColors.borderDark
          : AppColors.borderLight,
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// OUTLINE BUTTON
// ═══════════════════════════════════════════════════════════

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withOpacity(0.3), width: 1.2),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ]),
      ),
    );
  }
}
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
    final task =
        p.allTasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Task')),
          body: const Center(child: Text('Task not found.')));
    }

    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddOrEditScreen(task: task)))),
          IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _del(context, task, p)),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              PriorityBadge(priority: task.priority),
              const SizedBox(width: 8),
              StatusBadge(status: task.status),
              if (task.isOverdue) ...[
                const SizedBox(width: 8),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.highBg,
                        borderRadius:
                            BorderRadius.circular(20)),
                    child: const Text('⚠ Overdue',
                        style: TextStyle(
                            color: AppColors.high,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)))
              ],
            ]),
            const SizedBox(height: 16),
            Text(task.title,
                style: theme.textTheme.displaySmall?.copyWith(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted
                        ? theme.textTheme.bodySmall?.color
                        : null)),
            const SizedBox(height: 12),
            if (task.description.isNotEmpty) ...[
              Text(task.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          theme.textTheme.bodySmall?.color)),
              const SizedBox(height: 20),
            ],
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.dividerColor,
                        width: 1.5)),
                child: Column(children: [
                  _IR(Icons.calendar_today_rounded, 'Deadline',
                      task.deadline != null
                          ? H.fmtDate(task.deadline)
                          : 'No deadline',
                      vc: task.isOverdue
                          ? AppColors.high
                          : null),
                  const SizedBox(height: 8),
                  const AppDivider(),
                  const SizedBox(height: 8),
                  _IR(Icons.flag_rounded, 'Priority',
                      H.priorityLabel(task.priority),
                      vc: H.priorityColor(task.priority)),
                  const SizedBox(height: 8),
                  const AppDivider(),
                  const SizedBox(height: 8),
                  _IR(Icons.circle_outlined, 'Status',
                      H.statusLabel(task.status),
                      vc: H.statusColor(task.status)),
                  const SizedBox(height: 8),
                  const AppDivider(),
                  const SizedBox(height: 8),
                  _IR(Icons.access_time_rounded, 'Created',
                      H.fmtDate(task.createdAt)),
                  if (task.deadline != null) ...[
                    const SizedBox(height: 8),
                    const AppDivider(),
                    const SizedBox(height: 8),
                    _IR(
                        Icons.timer_rounded,
                        'Time Left',
                        task.isOverdue
                            ? '${task.daysLeft.abs()} day${task.daysLeft.abs() == 1 ? '' : 's'} overdue'
                            : task.isDueToday
                                ? 'Due today'
                                : '${task.daysLeft} day${task.daysLeft == 1 ? '' : 's'} left',
                        vc: task.isOverdue
                            ? AppColors.high
                            : task.isDueToday
                                ? AppColors.medium
                                : null),
                  ],
                ])),
            const SizedBox(height: 24),
            if (!isCompleted)
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        p.markComplete(task.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                            content: const Text(
                                '✅ Task completed!'),
                            backgroundColor:
                                AppColors.completed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10))));
                      },
                      icon: const Icon(Icons.check_rounded),
                      label:
                          const Text('Mark as Complete'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                          backgroundColor:
                              AppColors.completed))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddOrEditScreen(task: task))),
                      icon: const Icon(Icons.edit_rounded,
                          size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14)))),
              const SizedBox(width: 12),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () =>
                          _del(context, task, p),
                      icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: AppColors.error),
                      label: const Text('Delete',
                          style: TextStyle(
                              color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          side: const BorderSide(
                              color: AppColors.error)))),
            ]),
          ])),
    );
  }

  void _del(BuildContext ctx, Task t, TaskProvider p) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Delete Task'),
              content: Text(
                  'Delete "${t.title}"? This cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
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

class _IR extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? vc;
  const _IR(this.icon, this.label, this.value, {this.vc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Icon(icon,
          size: 16,
          color: theme.textTheme.bodySmall?.color),
      const SizedBox(width: 8),
      Text(label, style: theme.textTheme.bodySmall),
      const Spacer(),
      Text(value,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: vc, fontWeight: FontWeight.w600)),
    ]);
  }
}

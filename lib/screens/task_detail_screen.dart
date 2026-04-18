import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final task = provider.allTasks.where((t) => t.id == taskId).firstOrNull;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (task == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Task not found')));

    final isCompleted = task.status == TaskStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: task.priority.color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: task.priority.color),
                    const SizedBox(width: 6),
                    Text(task.priority.label, style: TextStyle(color: task.priority.color, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(task.safeCategory.name.toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(task.title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: isCompleted ? (isDark ? Colors.white30 : Colors.black38) : null, decoration: isCompleted ? TextDecoration.lineThrough : null)),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(task.description, style: TextStyle(fontSize: 16, height: 1.5, color: isDark ? Colors.white70 : Colors.black87)),
          ],

          const SizedBox(height: 40),

          // Progress Section
          Text('Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: task.progress / 100,
                    minHeight: 12,
                    backgroundColor: theme.dividerColor,
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text('${task.progress}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  onPressed: isCompleted ? null : () => _showProgressDialog(context, task, provider, theme),
                  child: const Text('Running', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: isCompleted ? null : () => _showCompletedDialog(context, task, provider, theme),
                  child: const Text('Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context, Task task, TaskProvider provider, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardTheme.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        int sliderValue = task.progress;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Update Task Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 32),
                  Text('$sliderValue%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderThemeData(trackHeight: 8, activeTrackColor: theme.colorScheme.primary, inactiveTrackColor: theme.dividerColor, thumbColor: theme.colorScheme.primary),
                    child: Slider(
                      value: sliderValue.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (val) {
                        if (val >= task.progress) { // 🔴 Prevents decreasing below current progress
                          setState(() => sliderValue = val.toInt());
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {
                        provider.updateTaskProgress(task.id, sliderValue);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCompletedDialog(BuildContext context, Task task, TaskProvider provider, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Complete Task?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to mark this task as fully completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Recheck your progress', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary),
            onPressed: () {
              provider.updateTaskProgress(task.id, 100);
              Navigator.pop(ctx);
              Navigator.pop(context); // Return to list screen
            },
            child: const Text('Mark Complete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
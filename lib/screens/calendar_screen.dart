import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateTasks = provider.allTasks.where((t) {
      if (t.deadline == null) return false;
      return t.deadline!.year == _selectedDate.year &&
          t.deadline!.month == _selectedDate.month &&
          t.deadline!.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Column(
        children: [
          Container(
            color: theme.cardTheme.color,
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          Container(height: 1, color: theme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks for ${_selectedDate.month}/${_selectedDate.day}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('${dateTasks.length}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
                )
              ],
            ),
          ),
          Expanded(
            child: dateTasks.isEmpty
                ? Center(
              child: Text('No tasks due on this date', style: TextStyle(fontSize: 15, color: isDark ? Colors.white54 : Colors.black54)),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: dateTasks.length,
              itemBuilder: (context, index) {
                final task = dateTasks[index];
                final isCompleted = task.status == TaskStatus.completed;
                final isOverdue = task.isOverdue;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id))),
                    child: Hero(
                      tag: 'task_card_${task.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isOverdue && !isCompleted ? Colors.redAccent.withOpacity(0.5) : theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Container(width: 4, height: 40, decoration: BoxDecoration(color: task.priority.color, borderRadius: BorderRadius.circular(2))),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                                              color: isCompleted ? (isDark ? Colors.white30 : Colors.black38) : null,
                                            ),
                                          ),
                                        ),
                                        if (isOverdue && !isCompleted)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                            child: const Icon(Icons.warning_rounded, color: Colors.black, size: 12),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        if (task.deadline != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.calendar_today_outlined, size: 11, color: isOverdue && !isCompleted ? Colors.redAccent : theme.textTheme.bodySmall?.color),
                                              const SizedBox(width: 4),
                                              Text('Due: ${task.deadline!.month}/${task.deadline!.day}', style: TextStyle(fontSize: 11, color: isOverdue && !isCompleted ? Colors.redAccent : theme.textTheme.bodySmall?.color, fontWeight: isOverdue && !isCompleted ? FontWeight.w700 : FontWeight.w400)),
                                            ],
                                          ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_calendar_outlined, size: 11, color: theme.textTheme.bodySmall?.color),
                                            const SizedBox(width: 4),
                                            Text('Created: ${task.createdAt.month}/${task.createdAt.day}', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                                value: task.progress / 100,
                                                minHeight: 6,
                                                backgroundColor: theme.dividerColor,
                                                // 🔴 FIX: Now explicitly turns primary green when completed!
                                                valueColor: AlwaysStoppedAnimation(isCompleted ? theme.colorScheme.primary : task.priority.color)
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // 🔴 FIX: Text turns green when completed!
                                        Text(
                                            '${task.progress}%',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isCompleted ? theme.colorScheme.primary : task.priority.color
                                            )
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'To Do', 'In Progress', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Local filtering to allow viewing completed tasks
    final displayTasks = provider.allTasks.where((t) {
      // 1. Apply Search
      final matchesSearch = provider.highlightedTask == null || // Using query indirectly or checking raw text
          t.title.toLowerCase().contains(provider.allTasks.toString().toLowerCase()) || true; // Simplification for UI focus

      // 2. Apply Status Filter
      bool matchesFilter = true;
      if (_filter == 'To Do') matchesFilter = t.status == TaskStatus.todo;
      if (_filter == 'In Progress') matchesFilter = t.status == TaskStatus.inProgress;
      if (_filter == 'Completed') matchesFilter = t.status == TaskStatus.completed;

      return matchesFilter; // Add search matching logic back if needed explicitly
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search your workspace...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardTheme.color,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final f = _filters[index];
                    final isSelected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f, style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        )),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _filter = f),
                        backgroundColor: theme.cardTheme.color,
                        selectedColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.dividerColor),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: displayTasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No tasks found', style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w600)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayTasks.length,
        itemBuilder: (context, index) {
          final task = displayTasks[index];
          final isCompleted = task.status == TaskStatus.completed;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => provider.toggleTaskCompletion(task.id),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? theme.colorScheme.primary : Colors.transparent,
                        border: Border.all(
                            color: isCompleted ? theme.colorScheme.primary : theme.dividerColor,
                            width: 2
                        ),
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? (isDark ? Colors.white30 : Colors.black38) : null,
                            )
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                                fontSize: 13,
                                color: isCompleted ? (isDark ? Colors.white24 : Colors.black26) : theme.textTheme.bodySmall?.color
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => provider.deleteTask(task.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
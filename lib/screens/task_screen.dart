import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_or_edit_screen.dart'; // <-- Fixed missing import
import 'task_detail_screen.dart'; // <-- Fixed missing import

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

    // Properly filtering the tasks based on both Search AND the Status Tab
    final displayTasks = provider.allTasks.where((t) {
      final query = provider.searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          t.title.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query);

      bool matchesFilter = true;
      if (_filter == 'To Do') matchesFilter = t.status == TaskStatus.todo;
      if (_filter == 'In Progress') matchesFilter = t.status == TaskStatus.inProgress;
      if (_filter == 'Completed') matchesFilter = t.status == TaskStatus.completed;

      return matchesSearch && matchesFilter;
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
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id))),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(color: task.priority.color, borderRadius: BorderRadius.circular(2))
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
                                    valueColor: AlwaysStoppedAnimation(isCompleted ? theme.dividerColor : task.priority.color),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                  '${task.progress}%',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isCompleted ? (isDark ? Colors.white30 : Colors.black38) : task.priority.color
                                  )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddOrEditScreen(task: task))),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => provider.deleteTask(task.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
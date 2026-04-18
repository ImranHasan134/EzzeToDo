import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_or_edit_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<String> _filters = ['All', 'To Do', 'In Progress', 'Completed', 'Overdue'];
  final List<String> _sorts = ['Newest First', 'Closest Due Date', 'Priority (High-Low)', 'Priority (Low-High)'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayTasks = provider.allTasks.where((t) {
      final query = provider.searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty || t.title.toLowerCase().contains(query) || t.description.toLowerCase().contains(query);
      bool matchesFilter = true;
      if (provider.filterStatus == 'To Do') matchesFilter = t.status == TaskStatus.todo;
      if (provider.filterStatus == 'In Progress') matchesFilter = t.status == TaskStatus.inProgress;
      if (provider.filterStatus == 'Completed') matchesFilter = t.status == TaskStatus.completed;
      if (provider.filterStatus == 'Overdue') matchesFilter = t.isOverdue && t.status != TaskStatus.completed;
      return matchesSearch && matchesFilter;
    }).toList();

    displayTasks.sort((a, b) {
      if (provider.sortOption == 'Closest Due Date') {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      } else if (provider.sortOption == 'Priority (High-Low)') {
        return a.priority.index.compareTo(b.priority.index);
      } else if (provider.sortOption == 'Priority (Low-High)') {
        return b.priority.index.compareTo(a.priority.index);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sort by:', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.sortOption,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                          onChanged: (String? newValue) {
                            if (newValue != null) provider.setSortOption(newValue);
                          },
                          items: _sorts.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
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
                    final isSelected = provider.filterStatus == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (f == 'Overdue') ...[Icon(Icons.warning_rounded, size: 14, color: isSelected ? Colors.white : Colors.redAccent), const SizedBox(width: 4)],
                            Text(f, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => provider.setFilterStatus(f),
                        backgroundColor: theme.cardTheme.color,
                        selectedColor: f == 'Overdue' ? Colors.redAccent : theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? (f == 'Overdue' ? Colors.redAccent : theme.colorScheme.primary) : theme.dividerColor)),
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
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox_outlined, size: 64, color: theme.dividerColor), const SizedBox(height: 16), Text('No tasks found', style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w600))]))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayTasks.length,
        itemBuilder: (context, index) {
          final task = displayTasks[index];
          final isCompleted = task.status == TaskStatus.completed;
          final isOverdue = task.isOverdue;
          final activeColor = isCompleted ? Colors.green : task.priority.color;

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
                        Container(width: 4, height: 40, decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(2))),
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
                                      child: LinearProgressIndicator(value: task.progress / 100, minHeight: 6, backgroundColor: theme.dividerColor, valueColor: AlwaysStoppedAnimation(activeColor)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('${task.progress}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: activeColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddOrEditScreen(task: task)))),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => provider.deleteTask(task.id)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
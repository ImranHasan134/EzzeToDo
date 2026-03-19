import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../widgets/common_widgets.dart';
import 'add_or_edit_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          titleSpacing: 16,
          title: _showSearch
              ? TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: p.setSearchQuery)
              : Text('All Tasks',
                  style: theme.textTheme.headlineMedium),
          actions: [
            IconButton(
                icon: Icon(
                    _showSearch ? Icons.close : Icons.search_rounded),
                onPressed: () {
                  setState(() => _showSearch = !_showSearch);
                  if (!_showSearch) {
                    _searchCtrl.clear();
                    p.setSearchQuery('');
                  }
                }),
          ],
        ),
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: FilterChipRow(
                    options: const [
                      'All',
                      'To Do',
                      'In Progress',
                      'Completed'
                    ],
                    selected: p.filterStatus,
                    onChanged: p.setFilterStatus))),
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilterChipRow(
                    options: const [
                      'All',
                      'High',
                      'Medium',
                      'Low'
                    ],
                    selected: p.filterPriority,
                    onChanged: p.setFilterPriority))),
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                    '${p.filteredTasks.length} task${p.filteredTasks.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall))),
        p.filteredTasks.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                    emoji: '📭',
                    title: 'No tasks found',
                    subtitle:
                        'Try a different filter or add a new task',
                    actionLabel: '+ Add Task',
                    onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AddOrEditScreen()))))
            : SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                  final t = p.filteredTasks[i];
                  return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 10),
                      child: TaskCard(
                          task: t,
                          onTap: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(
                                      taskId: t.id))),
                          onComplete: () =>
                              p.markComplete(t.id),
                          onDelete: () =>
                              _confirmDelete(ctx, t.id, p)));
                }, childCount: p.filteredTasks.length))),
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const AddOrEditScreen())),
          child: const Icon(Icons.add_rounded, size: 28)),
    );
  }

  void _confirmDelete(
      BuildContext ctx, String id, TaskProvider p) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Delete Task'),
              content: const Text(
                  'This task will be permanently deleted.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
                    onPressed: () {
                      p.deleteTask(id);
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

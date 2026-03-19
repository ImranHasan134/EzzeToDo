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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _Fab(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const AddOrEditScreen()))),
      body: CustomScrollView(slivers: [

        // ── APP BAR ────────────────────────────────────────
        SliverAppBar(
          floating: true,
          snap: true,
          titleSpacing: 20,
          toolbarHeight: 64,
          title: _showSearch
              ? TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.displaySmall?.color),
              decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.mutedDark
                          : AppColors.mutedLight),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.inputBgDark
                      : AppColors.inputBgLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: AppColors.primary, width: 1.5))),
              onChanged: p.setSearchQuery)
              : Text('All Tasks',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: theme.textTheme.displaySmall?.color)),
          actions: [
            GestureDetector(
              onTap: () {
                setState(() => _showSearch = !_showSearch);
                if (!_showSearch) {
                  _searchCtrl.clear();
                  p.setSearchQuery('');
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 4),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _showSearch
                      ? AppColors.primary.withOpacity(0.12)
                      : isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                  border: _showSearch
                      ? Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1)
                      : null,
                ),
                child: Icon(
                    _showSearch ? Icons.close_rounded : Icons.search_rounded,
                    size: 17,
                    color: _showSearch
                        ? AppColors.primary
                        : theme.textTheme.bodySmall?.color),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // ── TASK COUNT HEADER ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Total :' ' ${p.filteredTasks.length}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppColors.primary)),
                const SizedBox(width: 2),
                Text(
                    p.filteredTasks.length == 1 ?'task' :'tasks',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.mutedDark
                            : AppColors.mutedLight)),
              ],
            ),
          ),
        ),

        // ── STATUS FILTER ──────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: _FilterRow(
              options: const ['All', 'To Do', 'In Progress', 'Completed'],
              selected: p.filterStatus,
              onChanged: p.setFilterStatus,
              accentColors: const {
                'All': AppColors.primary,
                'To Do': AppColors.todo,
                'In Progress': AppColors.inProgress,
                'Completed': AppColors.completed,
              },
            ),
          ),
        ),

        // ── PRIORITY FILTER ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: _FilterRow(
              options: const ['All', 'High', 'Medium', 'Low'],
              selected: p.filterPriority,
              onChanged: p.setFilterPriority,
              accentColors: const {
                'All': AppColors.primary,
                'High': AppColors.high,
                'Medium': AppColors.medium,
                'Low': AppColors.low,
              },
            ),
          ),
        ),

        // ── DIVIDER ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            height: 1,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),

        // ── TASK LIST / EMPTY ──────────────────────────────
        if (p.filteredTasks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              onAdd: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const AddOrEditScreen())),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                  final t = p.filteredTasks[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskCard(
                        task: t,
                        onTap: () => Navigator.push(ctx,
                            MaterialPageRoute(
                                builder: (_) =>
                                    TaskDetailScreen(taskId: t.id))),
                        onComplete: () => p.markComplete(t.id),
                        onDelete: () => _confirmDelete(ctx, t.id, p)),
                  );
                },
                childCount: p.filteredTasks.length,
              ),
            ),
          ),
      ]),
    );
  }

  void _confirmDelete(BuildContext ctx, String id, TaskProvider p) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Task',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 17)),
          content: const Text(
              'This task will be permanently deleted.',
              style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  p.deleteTask(id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: const Text('Task deleted'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))));
                },
                child: const Text('Delete')),
          ],
        ));
  }
}

// ═══════════════════════════════════════════════════════════
// FILTER ROW
// ═══════════════════════════════════════════════════════════

class _FilterRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final Map<String, Color> accentColors;

  const _FilterRow({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.accentColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = options[i];
          final isSel = opt == selected;
          final accent = accentColors[opt] ?? AppColors.primary;
          return GestureDetector(
            onTap: () => onChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: isSel
                    ? accent
                    : isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isSel
                        ? accent
                        : isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1.2),
              ),
              child: Center(
                child: Text(opt,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSel
                            ? Colors.white
                            : isDark
                            ? AppColors.mutedDark
                            : AppColors.mutedLight)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.inbox_rounded,
                  size: 32,
                  color: isDark
                      ? AppColors.mutedDark
                      : AppColors.mutedLight),
            ),
            const SizedBox(height: 20),
            Text('No tasks found',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark
                        ? AppColors.textDark
                        : AppColors.textLight)),
            const SizedBox(height: 6),
            Text('Try a different filter or add a new task',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedDark
                        : AppColors.mutedLight)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('+ Add Task',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FAB
// ═══════════════════════════════════════════════════════════

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded,
          color: Colors.white, size: 26),
    ),
  );
}
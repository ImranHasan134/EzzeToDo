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
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          titleSpacing: 16,
          title: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Ezze',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            TextSpan(
                text: 'ToDo',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.displaySmall?.color)),
          ])),
          actions: [
            if (p.overdueTasks.isNotEmpty)
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: AppColors.highBg,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: AppColors.high),
                    const SizedBox(width: 4),
                    Text('${p.overdueTasks.length} overdue',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.high)),
                  ])),
            IconButton(
              icon: Icon(
                  tp.isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: theme.textTheme.bodySmall?.color),
              onPressed: tp.toggleTheme,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            Text(greeting, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text("Let's get things done! 💪",
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            _ProgressBanner(p: p),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: StatBox(
                      label: 'To Do',
                      value: '${p.todoCount}',
                      color: AppColors.todo,
                      bgColor: AppColors.todoBg)),
              const SizedBox(width: 10),
              Expanded(
                  child: StatBox(
                      label: 'In Progress',
                      value: '${p.inProgressCount}',
                      color: AppColors.inProgress,
                      bgColor: AppColors.inProgressBg)),
              const SizedBox(width: 10),
              Expanded(
                  child: StatBox(
                      label: 'Done',
                      value: '${p.completedCount}',
                      color: AppColors.completed,
                      bgColor: AppColors.completedBg)),
            ]),
            const SizedBox(height: 24),
            SectionHeader(title: "Today's Tasks"),
            if (p.todayTasks.isEmpty)
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: Column(children: [
                    const Text('🎉',
                        style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text('All caught up for today!',
                        style: theme.textTheme.titleMedium),
                    Text('No tasks due today.',
                        style: theme.textTheme.bodySmall),
                  ]))
            else
              ...p.todayTasks.take(5).map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskCard(
                        task: t,
                        onTap: () => _goDetail(context, t.id),
                        onComplete: () => p.markComplete(t.id)),
                  )),
            if (p.allTasks.any((t) =>
                t.priority == Priority.high &&
                t.status != TaskStatus.completed)) ...[
              SectionHeader(title: '🔴 High Priority'),
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
                            onComplete: () =>
                                p.markComplete(t.id)),
                      )),
            ],
          ])),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _goAdd(context),
          child: const Icon(Icons.add_rounded, size: 28)),
    );
  }

  void _goDetail(BuildContext ctx, String id) => Navigator.push(
      ctx,
      MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: id)));

  void _goAdd(BuildContext ctx) => Navigator.push(
      ctx,
      MaterialPageRoute(
          builder: (_) => const AddOrEditScreen()));
}

class _ProgressBanner extends StatelessWidget {
  final TaskProvider p;
  const _ProgressBanner({required this.p});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF534AB7), Color(0xFF7F77DD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          SizedBox(
              width: 80,
              height: 80,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                    value: p.completionRate,
                    strokeWidth: 8,
                    backgroundColor:
                        Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(
                        Colors.white),
                    strokeCap: StrokeCap.round),
                Text('${(p.completionRate * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ])),
          const SizedBox(width: 20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            const Text('Overall Progress',
                style: TextStyle(
                    color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: '${p.completedCount}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              TextSpan(
                  text: ' / ${p.totalCount}',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7))),
            ])),
            const Text('tasks completed',
                style: TextStyle(
                    color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
            Row(children: [
              _Pill('${p.highCount} High', '🔴'),
              const SizedBox(width: 8),
              _Pill('${p.mediumCount} Med', '🟡'),
            ]),
          ])),
        ]),
      );
}

class _Pill extends StatelessWidget {
  final String label, icon;
  const _Pill(this.label, this.icon);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20)),
        child: Text('$icon $label',
            style: const TextStyle(
                color: Colors.white, fontSize: 11)),
      );
}

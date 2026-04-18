import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../screens/add_or_edit_screen.dart'; // Ensure this matches your actual file structure

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hey, User! 👋', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'These are ${provider.activeTasks.length} tasks waiting for you',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Horizontal Tabs
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _TabItem(
                    'All',
                    isSelected: provider.homeTab == 'All',
                    onTap: () => provider.setHomeTab('All'),
                  ),
                  _TabItem(
                    'Workspace',
                    isSelected: provider.homeTab == 'Workspace',
                    onTap: () => provider.setHomeTab('Workspace'),
                  ),
                  _TabItem(
                    'Portfolio',
                    isSelected: provider.homeTab == 'Portfolio',
                    onTap: () => provider.setHomeTab('Portfolio'),
                  ),
                  _TabItem(
                    'Personal',
                    isSelected: provider.homeTab == 'Personal',
                    onTap: () => provider.setHomeTab('Personal'),
                  ),
                ],
              ),
            ),
          ),

          // 2x2 Grid Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _GridStatCard(title: 'Total Tasks', value: '${provider.totalTasks}', subtitle: 'All time records')),
                      const SizedBox(width: 12),
                      Expanded(child: _GridStatCard(title: 'Ended Tasks', value: '${provider.completedTasks}', subtitle: 'Successfully finished')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _GridStatCard(title: 'Running', value: '${provider.runningTasks}', subtitle: 'Currently active')),
                      const SizedBox(width: 12),
                      Expanded(child: _GridStatCard(title: 'Pending', value: '${provider.pendingTasks}', subtitle: 'Waiting to start')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // "On Progress" Highlight Card
          if (provider.highlightedTask != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('On Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('See All', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _HighlightCard(task: provider.highlightedTask!),
                  ],
                ),
              ),
            ),

          // Task List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          provider.homeTab == 'All' ? 'All Pending Tasks' : '${provider.homeTab} Tasks',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)
                      ),
                      Text('See All', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Filtered Task List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    // Use the filtered list based on the selected tab
                    child: _TaskListItem(task: provider.homeFilteredTasks[index]),
                  );
                },
                childCount: provider.homeFilteredTasks.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Padding for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddOrEditScreen()),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SUB-WIDGETS FOR HOME SCREEN
// ════════════════════════════════════════════════════════════

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem(this.label, {required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridStatCard extends StatelessWidget {
  final String title, value, subtitle;
  const _GridStatCard({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Icon(Icons.arrow_outward_rounded, size: 16, color: isDark ? Colors.white54 : Colors.black54),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: theme.colorScheme.primary, height: 1)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final Task task;
  const _HighlightCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          if (task.description.isNotEmpty)
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Priority Level', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;
  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<TaskProvider>();
    final isCompleted = task.status == TaskStatus.completed;

    return Container(
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
                  width: 2,
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
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${task.createdAt.month}/${task.createdAt.day}',
                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
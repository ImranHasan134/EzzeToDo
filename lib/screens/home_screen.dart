import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../models/task.dart';
import 'add_or_edit_screen.dart';
import 'task_detail_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  final List<String> _tabs = ['All', 'Workspace', 'Portfolio', 'Personal'];

  @override
  void initState() {
    super.initState();
    final initialTab = context.read<TaskProvider>().homeTab;
    final initialIndex = _tabs.indexOf(initialTab).clamp(0, 3);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Task> _getTasksForTab(TaskProvider provider, String tab) {
    var baseList = provider.activeTasks;
    if (tab == 'Workspace') return baseList.where((t) => t.safeCategory == TaskCategory.work).toList();
    if (tab == 'Portfolio') return baseList.where((t) => t.safeCategory == TaskCategory.portfolio).toList();
    if (tab == 'Personal') return baseList.where((t) => t.safeCategory == TaskCategory.personal).toList();
    return baseList;
  }

  Task? _getMostImportantForTab(List<Task> tabTasks) {
    final highPriority = tabTasks.where((t) => t.priority == Priority.high && t.status != TaskStatus.completed).toList();
    if (highPriority.isNotEmpty) return highPriority.first;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hey, ${userProvider.firstName}! 👋', style: const TextStyle(fontWeight: FontWeight.w800)),
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
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tabName = _tabs[index];
                final isSelected = provider.homeTab == tabName;

                return _TabItem(
                  tabName,
                  isSelected: isSelected,
                  onTap: () {
                    provider.setHomeTab(tabName);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                );
              },
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) => provider.setHomeTab(_tabs[index]),
              itemCount: _tabs.length,
              itemBuilder: (context, pageIndex) {
                final tabName = _tabs[pageIndex];
                final tabTasks = _getTasksForTab(provider, tabName);
                final mostImportant = _getMostImportantForTab(tabTasks);

                return CustomScrollView(
                  key: PageStorageKey<String>(tabName),
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    if (tabName == 'All')
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.setFilterStatus('All');
                                        provider.setNavIndex(1);
                                      },
                                      child: _GridStatCard(title: 'Total Tasks', value: '${provider.totalTasks}', subtitle: 'All time records'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.setFilterStatus('Completed');
                                        provider.setNavIndex(1);
                                      },
                                      child: _GridStatCard(title: 'Ended Tasks', value: '${provider.completedTasks}', subtitle: 'Successfully finished'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.setFilterStatus('In Progress');
                                        provider.setNavIndex(1);
                                      },
                                      child: _GridStatCard(title: 'Running', value: '${provider.runningTasks}', subtitle: 'Currently active'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        provider.setFilterStatus('To Do');
                                        provider.setNavIndex(1);
                                      },
                                      child: _GridStatCard(title: 'Pending', value: '${provider.pendingTasks}', subtitle: 'Waiting to start'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (mostImportant != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Most Important', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MostImportantTasksScreen(tabName: tabName))),
                                    child: Text('See All', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: mostImportant.id))),
                                child: _HighlightCard(task: mostImportant),
                              ),
                            ],
                          ),
                        ),
                      ),

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
                                  tabName == 'All' ? 'All Pending Tasks' : '$tabName Tasks',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, taskIndex) {
                            return _FadeAndSlidePop(
                              key: ValueKey('${tabName}_${tabTasks[taskIndex].id}'),
                              index: taskIndex,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TaskListItem(task: tabTasks[taskIndex]),
                              ),
                            );
                          },
                          childCount: tabTasks.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
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

class MostImportantTasksScreen extends StatelessWidget {
  final String tabName;
  const MostImportantTasksScreen({super.key, required this.tabName});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    var baseList = provider.activeTasks.where((t) => t.priority == Priority.high && t.status != TaskStatus.completed).toList();
    if (tabName == 'Workspace') baseList = baseList.where((t) => t.safeCategory == TaskCategory.work).toList();
    if (tabName == 'Portfolio') baseList = baseList.where((t) => t.safeCategory == TaskCategory.portfolio).toList();
    if (tabName == 'Personal') baseList = baseList.where((t) => t.safeCategory == TaskCategory.personal).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Most Important Tasks'),
      ),
      body: baseList.isEmpty
          ? Center(child: Text('No high priority tasks right now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.black54)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: baseList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TaskListItem(task: baseList[index]),
          );
        },
      ),
    );
  }
}

class _FadeAndSlidePop extends StatefulWidget {
  final Widget child;
  final int index;
  const _FadeAndSlidePop({super.key, required this.child, required this.index});
  @override
  State<_FadeAndSlidePop> createState() => _FadeAndSlidePopState();
}
class _FadeAndSlidePopState extends State<_FadeAndSlidePop> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}

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
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 2))),
        child: Center(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: color))),
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
      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor)),
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
      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2))),
              const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          if (task.description.isNotEmpty)
            Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Priority Level', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: task.priority.color),
                    const SizedBox(width: 4),
                    Text(task.priority.label.toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
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
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.isOverdue;

    // 🔴 THE MASTER COLOR FIX: This forces EVERYTHING to be Green when 100% complete
    final activeColor = isCompleted ? theme.colorScheme.primary : task.priority.color;

    return GestureDetector(
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
                // 🔴 FIX: The side stripe now turns Green when done
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
                              child: LinearProgressIndicator(
                                  value: task.progress / 100,
                                  minHeight: 6,
                                  backgroundColor: theme.dividerColor,
                                  // 🔴 FIX: The bar turns strictly Green when done
                                  valueColor: AlwaysStoppedAnimation(activeColor)
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 🔴 FIX: The Text turns strictly Green when done
                          Text(
                              '${task.progress}%',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: activeColor
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
    );
  }
}
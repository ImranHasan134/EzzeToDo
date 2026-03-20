import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';

// ════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════

class H {
  static Color priorityColor(Priority p) => const {
        Priority.high: AppColors.high,
        Priority.medium: AppColors.medium,
        Priority.low: AppColors.low,
      }[p]!;

  static Color priorityBg(Priority p) => const {
        Priority.high: AppColors.highBg,
        Priority.medium: AppColors.mediumBg,
        Priority.low: AppColors.lowBg,
      }[p]!;

  static Color statusColor(TaskStatus s) => const {
        TaskStatus.todo: AppColors.todo,
        TaskStatus.inProgress: AppColors.inProgress,
        TaskStatus.completed: AppColors.completed,
      }[s]!;

  static Color statusBg(TaskStatus s) => const {
        TaskStatus.todo: AppColors.todoBg,
        TaskStatus.inProgress: AppColors.inProgressBg,
        TaskStatus.completed: AppColors.completedBg,
      }[s]!;

  static String priorityLabel(Priority p) => const {
        Priority.high: 'High',
        Priority.medium: 'Medium',
        Priority.low: 'Low',
      }[p]!;

  static String statusLabel(TaskStatus s) => const {
        TaskStatus.todo: 'To Do',
        TaskStatus.inProgress: 'In Progress',
        TaskStatus.completed: 'Completed',
      }[s]!;

  static String statusIcon(TaskStatus s) => const {
        TaskStatus.todo: '○',
        TaskStatus.inProgress: '◑',
        TaskStatus.completed: '●',
      }[s]!;

  static String priorityIcon(Priority p) => const {
        Priority.high: '🔴',
        Priority.medium: '🟡',
        Priority.low: '🟢',
      }[p]!;

  static String fmtDate(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM d, yyyy').format(d);

  static String fmtShort(DateTime? d) {
    if (d == null) return '—';
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day)
      return 'Today';
    final tom = now.add(const Duration(days: 1));
    if (d.year == tom.year && d.month == tom.month && d.day == tom.day)
      return 'Tomorrow';
    return DateFormat('MMM d').format(d);
  }

  static String deadlineLabel(Task t) {
    if (t.deadline == null) return '';
    if (t.isOverdue) {
      final d = t.daysLeft.abs();
      return d == 0 ? 'Due today' : '$d day${d == 1 ? '' : 's'} overdue';
    }
    if (t.isDueToday) return 'Due today';
    final d = t.daysLeft;
    if (d == 1) return 'Tomorrow';
    if (d <= 3) return 'In $d days';
    return fmtShort(t.deadline);
  }

  static Color deadlineColor(Task t, BuildContext ctx) {
    if (t.isOverdue) return AppColors.high;
    if (t.isDueToday) return AppColors.medium;
    if (t.daysLeft <= 3) return AppColors.medium;
    return Theme.of(ctx).textTheme.bodySmall!.color!;
  }

  static Priority priorityFromString(String s) =>
      s == 'High' ? Priority.high : s == 'Low' ? Priority.low : Priority.medium;

  static TaskStatus statusFromString(String s) =>
      s == 'In Progress'
          ? TaskStatus.inProgress
          : s == 'Completed'
              ? TaskStatus.completed
              : TaskStatus.todo;
}

// ════════════════════════════════════════════════════════════
// TASK PROVIDER
// ════════════════════════════════════════════════════════════

const _uuid = Uuid();

class TaskProvider extends ChangeNotifier {
  late Box<Task> _box;
  List<Task> _tasks = [];
  String _filterStatus = 'All';
  String _filterPriority = 'All';
  String _searchQuery = '';

  List<Task> get allTasks => List.unmodifiable(_tasks);

  List<Task> get filteredTasks => _tasks.where((t) {
        final ms = _filterStatus == 'All' ||
            (_filterStatus == 'To Do' && t.status == TaskStatus.todo) ||
            (_filterStatus == 'In Progress' &&
                t.status == TaskStatus.inProgress) ||
            (_filterStatus == 'Completed' &&
                t.status == TaskStatus.completed);
        final mp = _filterPriority == 'All' ||
            (_filterPriority == 'High' && t.priority == Priority.high) ||
            (_filterPriority == 'Medium' && t.priority == Priority.medium) ||
            (_filterPriority == 'Low' && t.priority == Priority.low);
        final mq = _searchQuery.isEmpty ||
            t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        return ms && mp && mq;
      }).toList()
        ..sort((a, b) {
          if (a.isOverdue && !b.isOverdue) return -1;
          if (!a.isOverdue && b.isOverdue) return 1;
          final po = {Priority.high: 0, Priority.medium: 1, Priority.low: 2};
          final pc = po[a.priority]!.compareTo(po[b.priority]!);
          if (pc != 0) return pc;
          if (a.deadline != null && b.deadline != null)
            return a.deadline!.compareTo(b.deadline!);
          return b.createdAt.compareTo(a.createdAt);
        });

  List<Task> get todayTasks => _tasks
      .where((t) => t.isDueToday && t.status != TaskStatus.completed)
      .toList();
  List<Task> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();
  List<Task> get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList();

  int get totalCount => _tasks.length;
  int get completedCount => completedTasks.length;
  int get todoCount =>
      _tasks.where((t) => t.status == TaskStatus.todo).length;
  int get inProgressCount =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  double get completionRate =>
      _tasks.isEmpty ? 0 : completedCount / _tasks.length;
  int get highCount =>
      _tasks.where((t) => t.priority == Priority.high).length;
  int get mediumCount =>
      _tasks.where((t) => t.priority == Priority.medium).length;
  int get lowCount =>
      _tasks.where((t) => t.priority == Priority.low).length;
  String get filterStatus => _filterStatus;
  String get filterPriority => _filterPriority;

  List<Task> get thisWeekCompleted {
    final wa = DateTime.now().subtract(const Duration(days: 7));
    return completedTasks.where((t) => t.createdAt.isAfter(wa)).toList();
  }

  Map<String, int> get dailyCompletionMap {
    final map = <String, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      map['${day.month}/${day.day}'] = completedTasks
          .where((t) =>
              t.createdAt.year == day.year &&
              t.createdAt.month == day.month &&
              t.createdAt.day == day.day)
          .length;
    }
    return map;
  }

  Future<void> init() async {
    _box = await Hive.openBox<Task>('tasks');
    _tasks = _box.values.toList();
    if (_tasks.isEmpty) _seed();
    notifyListeners();
  }

  void _seed() {
    final samples = [
      Task(
          id: _uuid.v4(),
          title: 'Design new landing page',
          description:
              'Create wireframes and final designs for the Q2 revamp.',
          deadline: DateTime.now().add(const Duration(days: 3)),
          priority: Priority.high,
          status: TaskStatus.inProgress,
          createdAt: DateTime.now()),
      Task(
          id: _uuid.v4(),
          title: 'Write project proposal',
          description: 'Draft the proposal for the upcoming client pitch.',
          deadline: DateTime.now().add(const Duration(days: 7)),
          priority: Priority.medium,
          status: TaskStatus.todo,
          createdAt: DateTime.now().subtract(const Duration(hours: 5))),
      Task(
          id: _uuid.v4(),
          title: 'Update API documentation',
          description: 'Refresh the API docs with new endpoints.',
          deadline: DateTime.now().add(const Duration(days: 14)),
          priority: Priority.low,
          status: TaskStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ];
    for (final t in samples) _box.put(t.id, t);
    _tasks = _box.values.toList();
  }

  Future<void> addTask(Task t) async {
    await _box.put(t.id, t);
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> updateTask(Task t) async {
    await _box.put(t.id, t);
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> markComplete(String id) async {
    final t = _box.get(id);
    if (t != null) {
      await _box.put(id, t.copyWith(status: TaskStatus.completed));
    }
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _tasks = [];
    notifyListeners();
  }

  void setFilterStatus(String s) {
    _filterStatus = s;
    notifyListeners();
  }

  void setFilterPriority(String s) {
    _filterPriority = s;
    notifyListeners();
  }

  void setSearchQuery(String s) {
    _searchQuery = s;
    notifyListeners();
  }

  Task newTask({
    required String title,
    String description = '',
    DateTime? deadline,
    Priority priority = Priority.medium,
    TaskStatus status = TaskStatus.todo,
  }) =>
      Task(
          id: _uuid.v4(),
          title: title,
          description: description,
          deadline: deadline,
          priority: priority,
          status: status,
          createdAt: DateTime.now());

  String exportText() {
    final sb = StringBuffer();
    sb.writeln('EZZE TODO — Task Export');
    sb.writeln('Generated: ${DateTime.now().toString().split('.')[0]}');
    sb.writeln('Total: ${_tasks.length} tasks\n${'─' * 40}');
    for (final cat in ['To Do', 'In Progress', 'Completed']) {
      sb.writeln('\n$cat:');
      for (final t
          in _tasks.where((t) => H.statusLabel(t.status) == cat)) {
        sb.writeln('  [${H.priorityLabel(t.priority)}] ${t.title}');
        if (t.description.isNotEmpty) sb.writeln('    ${t.description}');
        if (t.deadline != null)
          sb.writeln('    Due: ${H.fmtDate(t.deadline)}');
      }
    }
    return sb.toString();
  }
}

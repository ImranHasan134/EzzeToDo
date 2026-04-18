import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _box;
  List<Task> _tasks = [];
  String _searchQuery = '';
  String _homeTab = 'All';

  int _navIndex = 0;
  String _filterStatus = 'All';
  String _sortOption = 'Newest First';

  String get homeTab => _homeTab;
  String get searchQuery => _searchQuery;
  int get navIndex => _navIndex;
  String get filterStatus => _filterStatus;
  String get sortOption => _sortOption;

  void setHomeTab(String tab) { _homeTab = tab; notifyListeners(); }
  void setNavIndex(int index) { _navIndex = index; notifyListeners(); }
  void setFilterStatus(String status) { _filterStatus = status; notifyListeners(); }
  void setSortOption(String sort) { _sortOption = sort; notifyListeners(); }

  List<Task> get allTasks => List.unmodifiable(_tasks);

  List<Task> get activeTasks => _tasks.where((t) {
    final isMatch = _searchQuery.isEmpty || t.title.toLowerCase().contains(_searchQuery.toLowerCase()) || (t.description.toLowerCase().contains(_searchQuery.toLowerCase()));
    return isMatch && t.status != TaskStatus.completed;
  }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get runningTasks => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get pendingTasks => _tasks.where((t) => t.status == TaskStatus.todo).length;

  // 🔴 NEW: Current Month Stats
  List<Task> get _thisMonthTasks {
    final now = DateTime.now();
    return _tasks.where((t) => t.createdAt.year == now.year && t.createdAt.month == now.month).toList();
  }

  int get thisMonthTotalTasks => _thisMonthTasks.length;
  int get thisMonthCompletedTasks => _thisMonthTasks.where((t) => t.status == TaskStatus.completed).length;
  int get thisMonthRunningTasks => _thisMonthTasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get thisMonthTodoTasks => _thisMonthTasks.where((t) => t.status == TaskStatus.todo).length;

  Map<String, int> get categoryDistribution {
    return {
      'Workspace': _tasks.where((t) => t.safeCategory == TaskCategory.work).length,
      'Portfolio': _tasks.where((t) => t.safeCategory == TaskCategory.portfolio).length,
      'Personal': _tasks.where((t) => t.safeCategory == TaskCategory.personal).length,
    };
  }

  List<int> get last7DaysCompletions {
    final List<int> completions = List.filled(7, 0);
    final now = DateTime.now();
    final completed = _tasks.where((t) => t.status == TaskStatus.completed && t.completedAt != null);

    for (var t in completed) {
      final diff = now.difference(t.completedAt!).inDays;
      if (diff >= 0 && diff < 7) {
        completions[6 - diff]++;
      }
    }
    return completions;
  }

  Future<void> init() async {
    _box = await Hive.openBox<Task>('tasks');
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> saveTask(Task t) async {
    await _box.put(t.id, t);
    _tasks = _box.values.toList();

    await NotificationService().scheduleTaskNotifications(t);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    _tasks = _box.values.toList();

    await NotificationService().cancelTaskNotifications(id);
    notifyListeners();
  }

  Future<void> clearAllTasks() async {
    for (var t in _tasks) {
      await NotificationService().cancelTaskNotifications(t.id);
    }
    await _box.clear();
    _tasks = [];
    notifyListeners();
  }

  Future<void> updateTaskProgress(String id, int newProgress) async {
    final t = _box.get(id);
    if (t != null) {
      TaskStatus newStatus = t.status;
      DateTime? completedAt = t.completedAt;

      if (newProgress == 100) {
        newStatus = TaskStatus.completed;
        completedAt = DateTime.now();
        await NotificationService().cancelTaskNotifications(id);
      } else if (newProgress > 0) {
        newStatus = TaskStatus.inProgress;
        completedAt = null;
      } else {
        newStatus = TaskStatus.todo;
        completedAt = null;
      }

      await _box.put(id, t.copyWith(progress: newProgress, status: newStatus, completedAt: completedAt));
      _tasks = _box.values.toList();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
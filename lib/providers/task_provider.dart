import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _box;
  List<Task> _tasks = [];
  String _searchQuery = '';

  List<Task> get allTasks => List.unmodifiable(_tasks);

  List<Task> get activeTasks => _tasks.where((t) {
    final isMatch = _searchQuery.isEmpty ||
        t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (t.description.toLowerCase().contains(_searchQuery.toLowerCase()));
    return isMatch && t.status != TaskStatus.completed;
  }).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Task> get todayTasks => activeTasks.where((t) => t.isDueToday || t.deadline == null).toList();

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get runningTasks => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get pendingTasks => _tasks.where((t) => t.status == TaskStatus.todo).length;

  Task? get highlightedTask {
    final running = _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    if (running.isNotEmpty) return running.first;
    if (activeTasks.isNotEmpty) return activeTasks.first;
    return null;
  }

  Future<void> init() async {
    _box = await Hive.openBox<Task>('tasks');
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> saveTask(Task t) async {
    await _box.put(t.id, t);
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final t = _box.get(id);
    if (t != null) {
      final isCompleting = t.status != TaskStatus.completed;
      await _box.put(
        id,
        t.copyWith(
          status: isCompleting ? TaskStatus.completed : TaskStatus.todo,
          completedAt: isCompleting ? DateTime.now() : null,
        ),
      );
    }
    _tasks = _box.values.toList();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
//  EzzeToDo

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';


// ════════════════════════════════════════════════════════════
// SECTION 1 — MODELS
// ════════════════════════════════════════════════════════════

@HiveType(typeId: 0)
enum Priority {
  @HiveField(0) high,
  @HiveField(1) medium,
  @HiveField(2) low,
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0) todo,
  @HiveField(1) inProgress,
  @HiveField(2) completed,
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String description;
  @HiveField(3) DateTime? deadline;
  @HiveField(4) Priority priority;
  @HiveField(5) TaskStatus status;
  @HiveField(6) DateTime createdAt;
  @HiveField(7) bool reminderSet;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.deadline,
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    required this.createdAt,
    this.reminderSet = false,
  });

  Task copyWith({
    String? title, String? description, DateTime? deadline,
    Priority? priority, TaskStatus? status, bool? reminderSet,
    bool clearDeadline = false,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    deadline: clearDeadline ? null : (deadline ?? this.deadline),
    priority: priority ?? this.priority,
    status: status ?? this.status,
    createdAt: createdAt,
    reminderSet: reminderSet ?? this.reminderSet,
  );

  bool get isOverdue {
    if (deadline == null || status == TaskStatus.completed) return false;
    final now = DateTime.now();
    return DateTime(deadline!.year, deadline!.month, deadline!.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    return deadline!.year == now.year &&
        deadline!.month == now.month &&
        deadline!.day == now.day;
  }

  int get daysLeft {
    if (deadline == null) return 999;
    final now = DateTime.now();
    return DateTime(deadline!.year, deadline!.month, deadline!.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 2 — HIVE ADAPTERS
// ════════════════════════════════════════════════════════════

class PriorityAdapter extends TypeAdapter<Priority> {
  @override final int typeId = 0;
  @override Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0: return Priority.high;
      case 2: return Priority.low;
      default: return Priority.medium;
    }
  }
  @override void write(BinaryWriter writer, Priority obj) {
    writer.writeByte(obj.index);
  }
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override final int typeId = 1;
  @override TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1: return TaskStatus.inProgress;
      case 2: return TaskStatus.completed;
      default: return TaskStatus.todo;
    }
  }
  @override void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeByte(obj.index);
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override final int typeId = 2;
  @override Task read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Task(
      id: f[0] as String,
      title: f[1] as String,
      description: f[2] as String? ?? '',
      deadline: f[3] as DateTime?,
      priority: f[4] as Priority,
      status: f[5] as TaskStatus,
      createdAt: f[6] as DateTime,
      reminderSet: f[7] as bool? ?? false,
    );
  }
  @override void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.description)
      ..writeByte(3)..write(obj.deadline)
      ..writeByte(4)..write(obj.priority)
      ..writeByte(5)..write(obj.status)
      ..writeByte(6)..write(obj.createdAt)
      ..writeByte(7)..write(obj.reminderSet);
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 3 — THEME & COLORS
// ════════════════════════════════════════════════════════════

class AppColors {
  static const primary       = Color(0xFF534AB7);
  static const primaryLight  = Color(0xFF7F77DD);
  static const primarySurface= Color(0xFFEEEDFE);
  static const high          = Color(0xFFE24B4A);
  static const highBg        = Color(0xFFFCEBEB);
  static const medium        = Color(0xFFBA7517);
  static const mediumBg      = Color(0xFFFAEEDA);
  static const low           = Color(0xFF3B6D11);
  static const lowBg         = Color(0xFFEAF3DE);
  static const todo          = Color(0xFF378ADD);
  static const todoBg        = Color(0xFFE6F1FB);
  static const inProgress    = Color(0xFFBA7517);
  static const inProgressBg  = Color(0xFFFAEEDA);
  static const completed     = Color(0xFF3B6D11);
  static const completedBg   = Color(0xFFEAF3DE);
  static const error         = Color(0xFFE24B4A);
  static const bgLight       = Color(0xFFF7F6F2);
  static const cardLight     = Color(0xFFFFFFFF);
  static const borderLight   = Color(0xFFEAEAE4);
  static const textLight     = Color(0xFF1A1A22);
  static const mutedLight    = Color(0xFF767670);
  static const inputBgLight  = Color(0xFFF4F3EF);
  static const inputBorderLight = Color(0xFFDDDDD6);
  static const bgDark        = Color(0xFF16161A);
  static const cardDark      = Color(0xFF1E1E24);
  static const borderDark    = Color(0xFF2E2E38);
  static const textDark      = Color(0xFFF0EFE8);
  static const mutedDark     = Color(0xFF888880);
  static const inputBgDark   = Color(0xFF26262E);
  static const inputBorderDark = Color(0xFF3A3A46);
}

class AppTheme {
  static TextTheme _tt(Color text, Color muted) => TextTheme(
    displaySmall:   TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: text),
    headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: text),
    headlineSmall:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
    titleLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
    titleMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
    bodyLarge:      TextStyle(fontSize: 15, color: text, height: 1.6),
    bodyMedium:     TextStyle(fontSize: 14, color: text, height: 1.5),
    bodySmall:      TextStyle(fontSize: 12, color: muted),
    labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
  );

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary, secondary: AppColors.primaryLight,
      surface: AppColors.cardLight, background: AppColors.bgLight,
      error: AppColors.error, onPrimary: Colors.white, onSurface: AppColors.textLight,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    textTheme: _tt(AppColors.textLight, AppColors.mutedLight),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardLight, surfaceTintColor: Colors.transparent,
      elevation: 0, scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textLight),
      iconTheme: const IconThemeData(color: AppColors.textLight),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight, elevation: 0, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.inputBgLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorderLight, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorderLight, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: AppColors.mutedLight, fontSize: 14),
      hintStyle:  TextStyle(color: AppColors.mutedLight, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    )),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1, space: 1),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      elevation: 4, shape: CircleBorder()),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.primary : Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.primaryLight : AppColors.borderLight),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight, secondary: AppColors.primary,
      surface: AppColors.cardDark, background: AppColors.bgDark,
      error: AppColors.error, onPrimary: Colors.white, onSurface: AppColors.textDark,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    textTheme: _tt(AppColors.textDark, AppColors.mutedDark),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardDark, surfaceTintColor: Colors.transparent,
      elevation: 0, scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
      iconTheme: const IconThemeData(color: AppColors.textDark),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark, elevation: 0, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark, width: 1.5)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.inputBgDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorderDark, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorderDark, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: AppColors.mutedDark, fontSize: 14),
      hintStyle:  TextStyle(color: AppColors.mutedDark, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight, foregroundColor: Colors.white, elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.borderDark, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    )),
    dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 1, space: 1),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight, foregroundColor: Colors.white,
      elevation: 4, shape: CircleBorder()),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.primaryLight : Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.primary : AppColors.borderDark),
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 4 — HELPERS
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

  static String priorityLabel(Priority p) =>
      const {Priority.high: 'High', Priority.medium: 'Medium', Priority.low: 'Low'}[p]!;

  static String statusLabel(TaskStatus s) =>
      const {TaskStatus.todo: 'To Do', TaskStatus.inProgress: 'In Progress', TaskStatus.completed: 'Completed'}[s]!;

  static String statusIcon(TaskStatus s) =>
      const {TaskStatus.todo: '○', TaskStatus.inProgress: '◑', TaskStatus.completed: '●'}[s]!;

  static String priorityIcon(Priority p) =>
      const {Priority.high: '🔴', Priority.medium: '🟡', Priority.low: '🟢'}[p]!;

  static String fmtDate(DateTime? d) =>
      d == null ? '—' : DateFormat('MMM d, yyyy').format(d);

  static String fmtShort(DateTime? d) {
    if (d == null) return '—';
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
    final tom = now.add(const Duration(days: 1));
    if (d.year == tom.year && d.month == tom.month && d.day == tom.day) return 'Tomorrow';
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
      s == 'In Progress' ? TaskStatus.inProgress :
      s == 'Completed' ? TaskStatus.completed : TaskStatus.todo;
}

// ════════════════════════════════════════════════════════════
// SECTION 5 — PROVIDERS
// ════════════════════════════════════════════════════════════

class ThemeProvider extends ChangeNotifier {
  late Box _prefs;
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    _prefs = await Hive.openBox('prefs');
    _isDark = _prefs.get('isDark', defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    await _prefs.put('isDark', _isDark);
    notifyListeners();
  }
}

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
        (_filterStatus == 'In Progress' && t.status == TaskStatus.inProgress) ||
        (_filterStatus == 'Completed' && t.status == TaskStatus.completed);
    final mp = _filterPriority == 'All' ||
        (_filterPriority == 'High' && t.priority == Priority.high) ||
        (_filterPriority == 'Medium' && t.priority == Priority.medium) ||
        (_filterPriority == 'Low' && t.priority == Priority.low);
    final mq = _searchQuery.isEmpty ||
        t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(_searchQuery.toLowerCase());
    return ms && mp && mq;
  }).toList()..sort((a, b) {
    if (a.isOverdue && !b.isOverdue) return -1;
    if (!a.isOverdue && b.isOverdue) return 1;
    final po = {Priority.high: 0, Priority.medium: 1, Priority.low: 2};
    final pc = po[a.priority]!.compareTo(po[b.priority]!);
    if (pc != 0) return pc;
    if (a.deadline != null && b.deadline != null) return a.deadline!.compareTo(b.deadline!);
    return b.createdAt.compareTo(a.createdAt);
  });

  List<Task> get todayTasks =>
      _tasks.where((t) => t.isDueToday && t.status != TaskStatus.completed).toList();
  List<Task> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.status == TaskStatus.completed).toList();

  int get totalCount => _tasks.length;
  int get completedCount => completedTasks.length;
  int get todoCount => _tasks.where((t) => t.status == TaskStatus.todo).length;
  int get inProgressCount => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  double get completionRate => _tasks.isEmpty ? 0 : completedCount / _tasks.length;
  int get highCount => _tasks.where((t) => t.priority == Priority.high).length;
  int get mediumCount => _tasks.where((t) => t.priority == Priority.medium).length;
  int get lowCount => _tasks.where((t) => t.priority == Priority.low).length;
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
      map['${day.month}/${day.day}'] = completedTasks.where((t) =>
        t.createdAt.year == day.year &&
        t.createdAt.month == day.month &&
        t.createdAt.day == day.day).length;
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
      Task(id: _uuid.v4(), title: 'Team standup preparation',
        description: 'Prepare notes and blockers list.',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        priority: Priority.high, status: TaskStatus.todo,
        createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ];
    for (final t in samples) _box.put(t.id, t);
    _tasks = _box.values.toList();
  }

  Future<void> addTask(Task t) async {
    await _box.put(t.id, t); _tasks = _box.values.toList(); notifyListeners();
  }
  Future<void> updateTask(Task t) async {
    await _box.put(t.id, t); _tasks = _box.values.toList(); notifyListeners();
  }
  Future<void> deleteTask(String id) async {
    await _box.delete(id); _tasks = _box.values.toList(); notifyListeners();
  }
  Future<void> markComplete(String id) async {
    final t = _box.get(id);
    if (t != null) { await _box.put(id, t.copyWith(status: TaskStatus.completed)); }
    _tasks = _box.values.toList(); notifyListeners();
  }
  Future<void> clearAll() async { await _box.clear(); _tasks = []; notifyListeners(); }
  void setFilterStatus(String s) { _filterStatus = s; notifyListeners(); }
  void setFilterPriority(String s) { _filterPriority = s; notifyListeners(); }
  void setSearchQuery(String s) { _searchQuery = s; notifyListeners(); }

  Task newTask({required String title, String description = '',
    DateTime? deadline, Priority priority = Priority.medium,
    TaskStatus status = TaskStatus.todo}) =>
      Task(id: _uuid.v4(), title: title, description: description,
        deadline: deadline, priority: priority, status: status, createdAt: DateTime.now());

  String exportText() {
    final sb = StringBuffer();
    sb.writeln('EZZE TODO — Task Export');
    sb.writeln('Generated: ${DateTime.now().toString().split('.')[0]}');
    sb.writeln('Total: ${_tasks.length} tasks\n${'─' * 40}');
    for (final cat in ['To Do', 'In Progress', 'Completed']) {
      sb.writeln('\n$cat:');
      for (final t in _tasks.where((t) => H.statusLabel(t.status) == cat)) {
        sb.writeln('  [${H.priorityLabel(t.priority)}] ${t.title}');
        if (t.description.isNotEmpty) sb.writeln('    ${t.description}');
        if (t.deadline != null) sb.writeln('    Due: ${H.fmtDate(t.deadline)}');
      }
    }
    return sb.toString();
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 6 — SHARED WIDGETS
// ════════════════════════════════════════════════════════════

class PriorityBadge extends StatelessWidget {
  final Priority priority; final bool small;
  const PriorityBadge({super.key, required this.priority, this.small = false});
  @override Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 2 : 4),
    decoration: BoxDecoration(color: H.priorityBg(priority), borderRadius: BorderRadius.circular(20)),
    child: Text(H.priorityLabel(priority), style: TextStyle(
      fontSize: small ? 10 : 12, fontWeight: FontWeight.w600, color: H.priorityColor(priority))),
  );
}

class StatusBadge extends StatelessWidget {
  final TaskStatus status; final bool small;
  const StatusBadge({super.key, required this.status, this.small = false});
  @override Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 2 : 4),
    decoration: BoxDecoration(color: H.statusBg(status), borderRadius: BorderRadius.circular(20)),
    child: Text('${H.statusIcon(status)} ${H.statusLabel(status)}', style: TextStyle(
      fontSize: small ? 10 : 12, fontWeight: FontWeight.w600, color: H.statusColor(status))),
  );
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap, onComplete;
  final VoidCallback? onDelete;
  const TaskCard({super.key, required this.task, required this.onTap,
    required this.onComplete, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;
    final pc = H.priorityColor(task.priority);
    final cardColor = theme.brightness == Brightness.dark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = theme.brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 5, color: pc),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    GestureDetector(
                      onTap: onComplete,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        margin: const EdgeInsets.only(top: 1, right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? AppColors.completed : Colors.transparent,
                          border: Border.all(color: isCompleted ? AppColors.completed : pc, width: 2),
                        ),
                        child: isCompleted ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                      ),
                    ),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(task.title, style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        color: isCompleted
                          ? (theme.brightness == Brightness.dark ? AppColors.mutedDark : AppColors.mutedLight)
                          : (theme.brightness == Brightness.dark ? AppColors.textDark : AppColors.textLight),
                      ), maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(task.description,
                          style: TextStyle(fontSize: 12,
                            color: theme.brightness == Brightness.dark ? AppColors.mutedDark : AppColors.mutedLight),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ])),
                    if (onDelete != null)
                      GestureDetector(onTap: onDelete, child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.delete_outline_rounded, size: 18,
                          color:Colors.red),
                      )),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    PriorityBadge(priority: task.priority, small: true),
                    const SizedBox(width: 6),
                    StatusBadge(status: task.status, small: true),
                    const Spacer(),
                    if (task.deadline != null) Row(children: [
                      Icon(Icons.schedule_rounded, size: 12, color: H.deadlineColor(task, context)),
                      const SizedBox(width: 3),
                      Text(H.deadlineLabel(task), style: TextStyle(
                        fontSize: 11,
                        color: H.deadlineColor(task, context),
                        fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.w400,
                      )),
                    ]),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title; final String? trailing; final VoidCallback? onTrailingTap;
  const SectionHeader({super.key, required this.title, this.trailing, this.onTrailingTap});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const Spacer(),
      if (trailing != null) GestureDetector(onTap: onTrailingTap,
        child: Text(trailing!, style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary, fontWeight: FontWeight.w600))),
    ]),
  );
}

class FilterChipRow extends StatelessWidget {
  final List<String> options; final String selected; final ValueChanged<String> onChanged;
  const FilterChipRow({super.key, required this.options, required this.selected, required this.onChanged});
  @override Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final opt = options[i]; final isSel = opt == selected;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSel ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSel ? AppColors.primary : Theme.of(context).dividerColor, width: 1.5),
            ),
            child: Text(opt, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
              color: isSel ? Colors.white : Theme.of(context).textTheme.bodySmall?.color)),
          ),
        );
      },
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String emoji, title, subtitle; final String? actionLabel; final VoidCallback? onAction;
  const EmptyState({super.key, required this.emoji, required this.title,
    required this.subtitle, this.actionLabel, this.onAction});
  @override Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      if (actionLabel != null && onAction != null) ...[
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ]),
  ));
}

class StatBox extends StatelessWidget {
  final String label, value; final Color color, bgColor;
  const StatBox({super.key, required this.label, required this.value,
    required this.color, required this.bgColor});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    ]),
  );
}

class CircularProgressWidget extends StatelessWidget {
  final double value; final double size; final Color color;
  final String centerText; final String? label;
  const CircularProgressWidget({super.key, required this.value, this.size = 80,
    required this.color, required this.centerText, this.label});
  @override Widget build(BuildContext context) => Column(children: [
    SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [
      SizedBox(width: size, height: size, child: CircularProgressIndicator(
        value: value, strokeWidth: 8,
        backgroundColor: color.withOpacity(0.15),
        valueColor: AlwaysStoppedAnimation(color),
        strokeCap: StrokeCap.round,
      )),
      Text(centerText, style: TextStyle(fontSize: size * 0.2,
        fontWeight: FontWeight.w800, color: color)),
    ])),
    if (label != null) ...[const SizedBox(height: 8),
      Text(label!, style: Theme.of(context).textTheme.bodySmall)],
  ]);
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});
  @override Widget build(BuildContext context) =>
      Divider(color: Theme.of(context).dividerColor, height: 1, thickness: 1);
}

class SettingsTile extends StatelessWidget {
  final IconData icon; final String title; final String? subtitle;
  final Widget? trailing; final VoidCallback? onTap; final Color? iconColor;
  const SettingsTile({super.key, required this.icon, required this.title,
    this.subtitle, this.trailing, this.onTap, this.iconColor});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor ?? AppColors.primary)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall),
          ])),
          if (trailing != null) trailing!,
        ])),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 7 — SCREENS
// ════════════════════════════════════════════════════════════

// ─── HOME ────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final tp = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true, snap: true, titleSpacing: 16,
          title: RichText(text: TextSpan(children: [
            TextSpan(text: 'Ezze', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
            TextSpan(text: 'ToDo', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800,
              color: theme.textTheme.displaySmall?.color)),
          ])),
          actions: [
            if (p.overdueTasks.isNotEmpty)
              Container(margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: AppColors.highBg, borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.high),
                  const SizedBox(width: 4),
                  Text('${p.overdueTasks.length} overdue', style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.high)),
                ])),
            IconButton(
              icon: Icon(tp.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: theme.textTheme.bodySmall?.color),
              onPressed: tp.toggleTheme,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(delegate: SliverChildListDelegate([
            Text(greeting, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text("Let's get things done! 💪", style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            _ProgressBanner(p: p),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: StatBox(label: 'To Do', value: '${p.todoCount}',
                color: AppColors.todo, bgColor: AppColors.todoBg)),
              const SizedBox(width: 10),
              Expanded(child: StatBox(label: 'In Progress', value: '${p.inProgressCount}',
                color: AppColors.inProgress, bgColor: AppColors.inProgressBg)),
              const SizedBox(width: 10),
              Expanded(child: StatBox(label: 'Done', value: '${p.completedCount}',
                color: AppColors.completed, bgColor: AppColors.completedBg)),
            ]),
            const SizedBox(height: 24),
            SectionHeader(title: "Today's Tasks"),
            if (p.todayTasks.isEmpty)
              Container(padding: const EdgeInsets.symmetric(vertical: 32), alignment: Alignment.center,
                child: Column(children: [
                  const Text('🎉', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text('All caught up for today!', style: theme.textTheme.titleMedium),
                  Text('No tasks due today.', style: theme.textTheme.bodySmall),
                ]))
            else
              ...p.todayTasks.take(5).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskCard(task: t,
                  onTap: () => _goDetail(context, t.id),
                  onComplete: () => p.markComplete(t.id)),
              )),
            if (p.allTasks.any((t) => t.priority == Priority.high && t.status != TaskStatus.completed)) ...[
              SectionHeader(title: '🔴 High Priority'),
              ...p.allTasks.where((t) => t.priority == Priority.high && t.status != TaskStatus.completed)
                .take(3).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(task: t, onTap: () => _goDetail(context, t.id),
                    onComplete: () => p.markComplete(t.id)),
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

  void _goDetail(BuildContext ctx, String id) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: id)));
  void _goAdd(BuildContext ctx) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AddTaskScreen()));
}

class _ProgressBanner extends StatelessWidget {
  final TaskProvider p;
  const _ProgressBanner({required this.p});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF534AB7), Color(0xFF7F77DD)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(children: [
      SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: p.completionRate, strokeWidth: 8,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          strokeCap: StrokeCap.round),
        Text('${(p.completionRate * 100).round()}%', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      ])),
      const SizedBox(width: 20),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overall Progress', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        RichText(text: TextSpan(children: [
          TextSpan(text: '${p.completedCount}', style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          TextSpan(text: ' / ${p.totalCount}', style: TextStyle(
            fontSize: 16, color: Colors.white.withOpacity(0.7))),
        ])),
        const Text('tasks completed', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
    child: Text('$icon $label', style: const TextStyle(color: Colors.white, fontSize: 11)),
  );
}

// ─── TASK LIST ───────────────────────────────────────────────
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true, snap: true, titleSpacing: 16,
          title: _showSearch
            ? TextField(controller: _searchCtrl, autofocus: true,
                decoration: InputDecoration(hintText: 'Search tasks...', isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                onChanged: p.setSearchQuery)
            : Text('All Tasks', style: theme.textTheme.headlineMedium),
          actions: [
            IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search_rounded),
              onPressed: () {
                setState(() => _showSearch = !_showSearch);
                if (!_showSearch) { _searchCtrl.clear(); p.setSearchQuery(''); }
              }),
          ],
        ),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: FilterChipRow(
            options: const ['All', 'To Do', 'In Progress', 'Completed'],
            selected: p.filterStatus, onChanged: p.setFilterStatus))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(bottom: 12),
          child: FilterChipRow(
            options: const ['All', 'High', 'Medium', 'Low'],
            selected: p.filterPriority, onChanged: p.setFilterPriority))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('${p.filteredTasks.length} task${p.filteredTasks.length == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall))),
        p.filteredTasks.isEmpty
          ? SliverFillRemaining(hasScrollBody: false, child: EmptyState(
              emoji: '📭', title: 'No tasks found',
              subtitle: 'Try a different filter or add a new task',
              actionLabel: '+ Add Task',
              onAction: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()))))
          : SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
                final t = p.filteredTasks[i];
                return Padding(padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(task: t,
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(taskId: t.id))),
                    onComplete: () => p.markComplete(t.id),
                    onDelete: () => _confirmDelete(ctx, t.id, p)));
              }, childCount: p.filteredTasks.length))),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        child: const Icon(Icons.add_rounded, size: 28)),
    );
  }

  void _confirmDelete(BuildContext ctx, String id, TaskProvider p) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Task'),
      content: const Text('This task will be permanently deleted.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () { p.deleteTask(id); Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: const Text('Task deleted'), backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          }, child: const Text('Delete')),
      ],
    ));
  }
}

// ─── ADD / EDIT TASK ─────────────────────────────────────────
class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});
  @override State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _fk = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Priority _priority = Priority.medium;
  TaskStatus _status = TaskStatus.todo;
  DateTime? _deadline;
  bool _saving = false;

  bool get isEdit => widget.task != null;

  @override void initState() {
    super.initState();
    if (isEdit) {
      final t = widget.task!;
      _titleCtrl.text = t.title; _descCtrl.text = t.description;
      _priority = t.priority; _status = t.status; _deadline = t.deadline;
    }
  }
  @override void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary)),
        child: child!),
    );
    if (d != null) setState(() => _deadline = d);
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<TaskProvider>();
    try {
      if (isEdit) {
        await p.updateTask(widget.task!.copyWith(
          title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
          priority: _priority, status: _status, deadline: _deadline,
          clearDeadline: _deadline == null));
      } else {
        await p.addTask(p.newTask(title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(), deadline: _deadline,
          priority: _priority, status: _status));
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Task updated!' : 'Task added!'),
          backgroundColor: AppColors.completed, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        actions: [Padding(padding: const EdgeInsets.only(right: 12),
          child: TextButton(onPressed: _saving ? null : _save,
            child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEdit ? 'Save' : 'Add', style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15))))],
      ),
      body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(16), children: [
        _Lbl('Task Title *'),
        TextFormField(controller: _titleCtrl, maxLength: 100,
          decoration: const InputDecoration(hintText: 'What needs to be done?', counterText: ''),
          validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
          textCapitalization: TextCapitalization.sentences),
        const SizedBox(height: 16),
        _Lbl('Description'),
        TextFormField(controller: _descCtrl, maxLines: 3, maxLength: 500,
          decoration: const InputDecoration(hintText: 'Add details (optional)...'),
          textCapitalization: TextCapitalization.sentences),
        const SizedBox(height: 16),
        _Lbl('Deadline'),
        GestureDetector(onTap: _pickDate, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor,
            border: Border.all(color: _deadline != null ? AppColors.primary : theme.dividerColor, width: 1.5),
            borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(Icons.calendar_today_rounded, size: 18,
              color: _deadline != null ? AppColors.primary : theme.textTheme.bodySmall?.color),
            const SizedBox(width: 10),
            Text(_deadline != null
              ? DateFormat('EEEE, MMM d, yyyy').format(_deadline!)
              : 'Pick a deadline',
              style: TextStyle(fontSize: 14,
                color: _deadline != null ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodySmall?.color)),
            const Spacer(),
            if (_deadline != null) GestureDetector(onTap: () => setState(() => _deadline = null),
              child: Icon(Icons.close_rounded, size: 16, color: theme.textTheme.bodySmall?.color)),
          ]),
        )),
        const SizedBox(height: 16),
        _Lbl('Priority'),
        Row(children: Priority.values.map((pr) {
          final isSel = pr == _priority;
          final col = H.priorityColor(pr); final bg = H.priorityBg(pr);
          return Expanded(child: Padding(padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(onTap: () => setState(() => _priority = pr),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSel ? bg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? col : theme.dividerColor, width: isSel ? 2 : 1.5)),
                alignment: Alignment.center,
                child: Column(children: [
                  Text(H.priorityIcon(pr), style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(H.priorityLabel(pr), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isSel ? col : theme.textTheme.bodySmall?.color)),
                ])))));
        }).toList()),
        const SizedBox(height: 16),
        _Lbl('Status'),
        ...TaskStatus.values.map((s) {
          final isSel = s == _status; final col = H.statusColor(s);
          return Padding(padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(onTap: () => setState(() => _status = s),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSel ? H.statusBg(s) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? col : theme.dividerColor, width: isSel ? 2 : 1.5)),
                child: Row(children: [
                  Text(H.statusIcon(s), style: TextStyle(color: col, fontSize: 16)),
                  const SizedBox(width: 10),
                  Text(H.statusLabel(s), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: isSel ? col : theme.textTheme.bodyLarge?.color)),
                  const Spacer(),
                  if (isSel) Icon(Icons.check_circle_rounded, color: col, size: 18),
                ]))));
        }),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(isEdit ? 'Save Changes' : 'Add Task',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
      ])),
    );
  }
}

class _Lbl extends StatelessWidget {
  final String text;
  const _Lbl(this.text);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w600)));
}

// ─── TASK DETAIL ─────────────────────────────────────────────
class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final task = p.allTasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) return Scaffold(appBar: AppBar(title: const Text('Task')),
      body: const Center(child: Text('Task not found.')));

    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)))),
          IconButton(icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _del(context, task, p)),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          PriorityBadge(priority: task.priority),
          const SizedBox(width: 8),
          StatusBadge(status: task.status),
          if (task.isOverdue) ...[const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.highBg, borderRadius: BorderRadius.circular(20)),
              child: const Text('⚠ Overdue', style: TextStyle(
                color: AppColors.high, fontSize: 12, fontWeight: FontWeight.w600)))],
        ]),
        const SizedBox(height: 16),
        Text(task.title, style: theme.textTheme.displaySmall?.copyWith(
          decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          color: isCompleted ? theme.textTheme.bodySmall?.color : null)),
        const SizedBox(height: 12),
        if (task.description.isNotEmpty) ...[
          Text(task.description, style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 20),
        ],
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor, width: 1.5)),
          child: Column(children: [
            _IR(Icons.calendar_today_rounded, 'Deadline',
              task.deadline != null ? H.fmtDate(task.deadline) : 'No deadline',
              vc: task.isOverdue ? AppColors.high : null),
            const SizedBox(height: 8), const AppDivider(), const SizedBox(height: 8),
            _IR(Icons.flag_rounded, 'Priority', H.priorityLabel(task.priority),
              vc: H.priorityColor(task.priority)),
            const SizedBox(height: 8), const AppDivider(), const SizedBox(height: 8),
            _IR(Icons.circle_outlined, 'Status', H.statusLabel(task.status),
              vc: H.statusColor(task.status)),
            const SizedBox(height: 8), const AppDivider(), const SizedBox(height: 8),
            _IR(Icons.access_time_rounded, 'Created', H.fmtDate(task.createdAt)),
            if (task.deadline != null) ...[
              const SizedBox(height: 8), const AppDivider(), const SizedBox(height: 8),
              _IR(Icons.timer_rounded, 'Time Left',
                task.isOverdue
                  ? '${task.daysLeft.abs()} day${task.daysLeft.abs() == 1 ? '' : 's'} overdue'
                  : task.isDueToday ? 'Due today'
                  : '${task.daysLeft} day${task.daysLeft == 1 ? '' : 's'} left',
                vc: task.isOverdue ? AppColors.high : task.isDueToday ? AppColors.medium : null),
            ],
          ])),
        const SizedBox(height: 24),
        if (!isCompleted) SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () { p.markComplete(task.id); Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('✅ Task completed!'),
                backgroundColor: AppColors.completed, behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
            },
            icon: const Icon(Icons.check_rounded), label: const Text('Mark as Complete'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.completed))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AddTaskScreen(task: task))),
            icon: const Icon(Icons.edit_rounded, size: 16), label: const Text('Edit'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _del(context, task, p),
            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
            label: const Text('Delete', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.error)))),
        ]),
      ])),
    );
  }

  void _del(BuildContext ctx, Task t, TaskProvider p) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Task'),
      content: Text('Delete "${t.title}"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            p.deleteTask(t.id); Navigator.pop(ctx); Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: const Text('Task deleted'), backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          }, child: const Text('Delete')),
      ],
    ));
  }
}

class _IR extends StatelessWidget {
  final IconData icon; final String label, value; final Color? vc;
  const _IR(this.icon, this.label, this.value, {this.vc});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Icon(icon, size: 16, color: theme.textTheme.bodySmall?.color),
      const SizedBox(width: 8),
      Text(label, style: theme.textTheme.bodySmall),
      const Spacer(),
      Text(value, style: theme.textTheme.titleMedium?.copyWith(
        color: vc, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ─── STATS ───────────────────────────────────────────────────
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(floating: true, snap: true, titleSpacing: 16,
          title: Text('Productivity Stats', style: theme.textTheme.headlineMedium)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(delegate: SliverChildListDelegate([
            Row(children: [
              Expanded(child: StatBox(label: 'Completion Rate',
                value: '${(p.completionRate * 100).round()}%',
                color: AppColors.primary, bgColor: AppColors.primarySurface)),
              const SizedBox(width: 10),
              Expanded(child: StatBox(label: 'This Week',
                value: '${p.thisWeekCompleted.length}',
                color: AppColors.completed, bgColor: AppColors.completedBg)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: StatBox(label: 'Total Tasks', value: '${p.totalCount}',
                color: AppColors.todo, bgColor: AppColors.todoBg)),
              const SizedBox(width: 10),
              Expanded(child: StatBox(label: 'Overdue',
                value: '${p.overdueTasks.length}',
                color: p.overdueTasks.isEmpty ? AppColors.completed : AppColors.high,
                bgColor: p.overdueTasks.isEmpty ? AppColors.completedBg : AppColors.highBg)),
            ]),
            const SizedBox(height: 24),
            _Card(title: 'Completion Overview', child: Row(children: [
              CircularProgressWidget(value: p.completionRate, size: 100,
                color: AppColors.completed,
                centerText: '${(p.completionRate * 100).round()}%',
                label: 'Completed'),
              const SizedBox(width: 24),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _PRow('Completed', p.completedCount, p.totalCount, AppColors.completed),
                const SizedBox(height: 12),
                _PRow('In Progress', p.inProgressCount, p.totalCount, AppColors.inProgress),
                const SizedBox(height: 12),
                _PRow('To Do', p.todoCount, p.totalCount, AppColors.todo),
              ])),
            ])),
            const SizedBox(height: 16),
            _Card(title: 'By Priority', child: Row(children: [
              Expanded(child: _PTile('High', p.highCount, AppColors.high, AppColors.highBg)),
              const SizedBox(width: 10),
              Expanded(child: _PTile('Medium', p.mediumCount, AppColors.medium, AppColors.mediumBg)),
              const SizedBox(width: 10),
              Expanded(child: _PTile('Low', p.lowCount, AppColors.low, AppColors.lowBg)),
            ])),
            const SizedBox(height: 16),
            _Card(title: '7-Day Activity', child: SizedBox(height: 180,
              child: _BarChart(data: p.dailyCompletionMap))),
            const SizedBox(height: 16),
            if (p.totalCount > 0)
              _Card(title: 'Status Distribution', child: SizedBox(height: 200,
                child: Row(children: [
                  Expanded(child: PieChart(PieChartData(
                    sections: [
                      if (p.completedCount > 0) PieChartSectionData(
                        value: p.completedCount.toDouble(), color: AppColors.completed,
                        title: '${p.completedCount}', radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      if (p.inProgressCount > 0) PieChartSectionData(
                        value: p.inProgressCount.toDouble(), color: AppColors.inProgress,
                        title: '${p.inProgressCount}', radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      if (p.todoCount > 0) PieChartSectionData(
                        value: p.todoCount.toDouble(), color: AppColors.todo,
                        title: '${p.todoCount}', radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                    sectionsSpace: 3, centerSpaceRadius: 30,
                  ))),
                  const SizedBox(width: 20),
                  Column(mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _LI(AppColors.completed, 'Completed'),
                    const SizedBox(height: 10),
                    _LI(AppColors.inProgress, 'In Progress'),
                    const SizedBox(height: 10),
                    _LI(AppColors.todo, 'To Do'),
                  ]),
                ]))),
          ])),
        ),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final String title; final Widget child;
  const _Card({required this.title, required this.child});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor, width: 1.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16), child,
    ]));
}

class _PRow extends StatelessWidget {
  final String label; final int count, total; final Color color;
  const _PRow(this.label, this.count, this.total, this.color);
  @override Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: pct, minHeight: 6,
          backgroundColor: color.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation(color))),
    ]);
  }
}

class _PTile extends StatelessWidget {
  final String label; final int count; final Color color, bg;
  const _PTile(this.label, this.count, this.color, this.bg);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text('$count', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]));
}

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  const _BarChart({required this.data});
  @override Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = data.values.fold(0, (a, b) => a > b ? a : b);
    return BarChart(BarChartData(
      maxY: (maxVal + 1).toDouble(),
      barGroups: List.generate(entries.length, (i) => BarChartGroupData(x: i,
        barRods: [BarChartRodData(
          toY: entries[i].value == 0 ? 0.2 : entries[i].value.toDouble(),
          color: entries[i].value > 0 ? AppColors.primary : AppColors.primarySurface,
          width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))])),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= entries.length) return const SizedBox();
            return Padding(padding: const EdgeInsets.only(top: 6),
              child: Text(entries[i].key, style: TextStyle(fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color)));
          })),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1)),
    ));
  }
}

class _LI extends StatelessWidget {
  final Color color; final String label;
  const _LI(this.color, this.label);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    Text(label, style: Theme.of(context).textTheme.bodySmall),
  ]);
}

// ─── SETTINGS ────────────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context) {
    final tp = context.watch<TaskProvider>();
    final thp = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(floating: true, snap: true, titleSpacing: 16,
          title: Text('Settings', style: theme.textTheme.headlineMedium)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _GL('Appearance'),
            _SC(children: [
              SettingsTile(icon: thp.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                title: 'Dark Mode',
                subtitle: thp.isDark ? 'Dark theme active' : 'Light theme active',
                iconColor: AppColors.primaryLight,
                trailing: Switch(value: thp.isDark, onChanged: (_) => thp.toggleTheme())),
            ]),
            const SizedBox(height: 16),
            _GL('Data & Backup'),
            _SC(children: [
              SettingsTile(icon: Icons.share_rounded, title: 'Export / Backup Tasks',
                subtitle: 'Share your task list as text', iconColor: AppColors.todo,
                onTap: () async {
                  try { await Share.share(tp.exportText(), subject: 'EzzeToDo Export'); }
                  catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Export failed.'), backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                  }
                }),
              const AppDivider(),
              SettingsTile(icon: Icons.delete_sweep_outlined, title: 'Clear All Tasks',
                subtitle: 'Permanently delete all tasks', iconColor: AppColors.error,
                onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Clear All Tasks'),
                  content: const Text('This will permanently delete ALL your tasks.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () { tp.clearAll(); Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('All tasks cleared'),
                          backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                      }, child: const Text('Clear All')),
                  ]))),
            ]),
            const SizedBox(height: 16),
            _GL('Notifications'),
            _SC(children: [
              SettingsTile(icon: Icons.notifications_rounded, title: 'Task Reminders',
                subtitle: 'Get notified about upcoming deadlines', iconColor: AppColors.medium,
                trailing: Switch(value: true, onChanged: (_) {})),
              const AppDivider(),
              SettingsTile(icon: Icons.today_rounded, title: 'Daily Summary',
                subtitle: 'Morning summary of today\'s tasks', iconColor: AppColors.inProgress,
                trailing: Switch(value: false, onChanged: (_) {})),
            ]),
            const SizedBox(height: 16),
            _GL('About'),
            _SC(children: [
              SettingsTile(icon: Icons.info_outline_rounded, title: 'App Version', subtitle: '1.0.0',
                iconColor: AppColors.mutedLight),
              const AppDivider(),
              SettingsTile(icon: Icons.favorite_rounded, title: 'Ezze ToDo',
                subtitle: 'Built with Flutter & ❤️', iconColor: AppColors.error),
            ]),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF534AB7), Color(0xFF7F77DD)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Quick Summary', style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(children: [
                  _SP('${tp.totalCount} Total'),
                  const SizedBox(width: 8), _SP('${tp.completedCount} Done'),
                  const SizedBox(width: 8), _SP('${tp.overdueTasks.length} Overdue'),
                ]),
              ])),
          ])),
        ),
      ]),
    );
  }
}

class _GL extends StatelessWidget {
  final String text; const _GL(this.text);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
      color: Theme.of(context).textTheme.bodySmall?.color, letterSpacing: 1.2)));
}

class _SC extends StatelessWidget {
  final List<Widget> children; const _SC({required this.children});
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor, width: 1.5)),
    clipBehavior: Clip.hardEdge,
    child: Column(children: children));
}

class _SP extends StatelessWidget {
  final String label; const _SP(this.label);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)));
}

// ════════════════════════════════════════════════════════════
// SECTION 8 — MAIN APP + NAVIGATION
// ════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Hive.initFlutter();
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskAdapter());
  final taskProvider = TaskProvider();
  final themeProvider = ThemeProvider();
  await taskProvider.init();
  await themeProvider.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: taskProvider),
      ChangeNotifierProvider.value(value: themeProvider),
    ],
    child: const EzzeTodoApp(),
  ));
}

class EzzeTodoApp extends StatelessWidget {
  const EzzeTodoApp({super.key});
  @override Widget build(BuildContext context) {
    final thp = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Ezze ToDo', debugShowCheckedModeBanner: false,
      theme: AppTheme.light(), darkTheme: AppTheme.dark(),
      themeMode: thp.themeMode, home: const MainNav());
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _idx = 0;
  static const _screens = [HomeScreen(), TaskListScreen(), StatsScreen(), SettingsScreen()];

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          border: Border(top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5))),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NI(Icons.home_rounded, Icons.home_outlined, 'Home', 0, _idx, activeColor, inactiveColor, (i) => setState(() => _idx = i)),
              _NI(Icons.checklist_rounded, Icons.checklist_outlined, 'Tasks', 1, _idx, activeColor, inactiveColor, (i) => setState(() => _idx = i)),
              _NI(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Stats', 2, _idx, activeColor, inactiveColor, (i) => setState(() => _idx = i)),
              _NI(Icons.settings_rounded, Icons.settings_outlined, 'Settings', 3, _idx, activeColor, inactiveColor, (i) => setState(() => _idx = i)),
            ]),
        )),
      ),
    );
  }
}

class _NI extends StatelessWidget {
  final IconData icon, outIcon; final String label;
  final int index, current; final Color activeColor, inactiveColor;
  final ValueChanged<int> onTap;
  const _NI(this.icon, this.outIcon, this.label, this.index, this.current,
    this.activeColor, this.inactiveColor, this.onTap);
  @override Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: isActive ? BoxDecoration(
          color: activeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)) : null,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? icon : outIcon, color: isActive ? activeColor : inactiveColor, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? activeColor : inactiveColor)),
        ])),
    ));
  }
}

// NOTE: Remove the 'part' directive at the top and this comment when
// using as a single-file app (no .g.dart needed since adapters are inline above).

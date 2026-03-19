import 'package:hive_flutter/hive_flutter.dart';

// ════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════

@HiveType(typeId: 0)
enum Priority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  DateTime? deadline;
  @HiveField(4)
  Priority priority;
  @HiveField(5)
  TaskStatus status;
  @HiveField(6)
  DateTime createdAt;
  @HiveField(7)
  bool reminderSet;

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
    String? title,
    String? description,
    DateTime? deadline,
    Priority? priority,
    TaskStatus? status,
    bool? reminderSet,
    bool clearDeadline = false,
  }) =>
      Task(
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
// HIVE ADAPTERS
// ════════════════════════════════════════════════════════════

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 0;

  @override
  Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Priority.high;
      case 2:
        return Priority.low;
      default:
        return Priority.medium;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    writer.writeByte(obj.index);
  }
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 1;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return TaskStatus.inProgress;
      case 2:
        return TaskStatus.completed;
      default:
        return TaskStatus.todo;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeByte(obj.index);
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;

  @override
  Task read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read()
    };
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

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.reminderSet);
  }
}

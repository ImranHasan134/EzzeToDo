import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

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
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String description;
  @HiveField(3) final DateTime? deadline;
  @HiveField(4) final Priority priority;
  @HiveField(5) final TaskStatus status;
  @HiveField(6) final DateTime createdAt;
  @HiveField(7) final DateTime? completedAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.deadline,
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    Priority? priority,
    TaskStatus? status,
    DateTime? completedAt,
    bool clearDeadline = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // ... copyWith method ...

  bool get isOverdue {
    if (deadline == null || status == TaskStatus.completed) return false;
    final now = DateTime.now();
    return DateTime(deadline!.year, deadline!.month, deadline!.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  // Add the missing getter right here:
  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    return deadline!.year == now.year &&
        deadline!.month == now.month &&
        deadline!.day == now.day;
  }
} // <-- End of Task class

// ════════════════════════════════════════════════════════════
// HIVE ADAPTERS (Required for the generated .g.dart file)
// ════════════════════════════════════════════════════════════
class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 0;
  @override
  Priority read(BinaryReader reader) => Priority.values[reader.readByte()];
  @override
  void write(BinaryWriter writer, Priority obj) => writer.writeByte(obj.index);
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 1;
  @override
  TaskStatus read(BinaryReader reader) => TaskStatus.values[reader.readByte()];
  @override
  void write(BinaryWriter writer, TaskStatus obj) => writer.writeByte(obj.index);
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;
  @override
  Task read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0, n = reader.readByte(); i < n; i++) reader.readByte(): reader.read()
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      deadline: fields[3] as DateTime?,
      priority: fields[4] as Priority,
      status: fields[5] as TaskStatus,
      createdAt: fields[6] as DateTime,
      completedAt: fields[7] as DateTime?,
    );
  }
  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.description)
      ..writeByte(3)..write(obj.deadline)
      ..writeByte(4)..write(obj.priority)
      ..writeByte(5)..write(obj.status)
      ..writeByte(6)..write(obj.createdAt)
      ..writeByte(7)..write(obj.completedAt);
  }
}
// lib/models/task.dart

enum TaskStatus {
  todo,
  inProgress,
  done;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String get value {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final int? blockedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isBlocked => blockedById != null;

  bool get isOverdue =>
      status != TaskStatus.done &&
      dueDate.isBefore(DateTime.now().copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
      ));

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    Object? blockedById = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById == _sentinel
          ? this.blockedById
          : blockedById as int?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status.value,
      'blocked_by_id': blockedById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['due_date'] as String),
      status: TaskStatus.fromString(map['status'] as String),
      blockedById: map['blocked_by_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Task && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Sentinel for optional null override
const Object _sentinel = Object();

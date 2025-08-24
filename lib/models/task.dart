import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  bool hasAlarm;

  @HiveField(6)
  String? note;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? completedAt;

  @HiveField(9)
  int priority; // 0: Low, 1: Medium, 2: High

  @HiveField(10)
  String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.hasAlarm = false,
    this.note,
    required this.createdAt,
    this.completedAt,
    this.priority = 1,
    this.category = 'General',
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    bool? hasAlarm,
    String? note,
    DateTime? createdAt,
    DateTime? completedAt,
    int? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'hasAlarm': hasAlarm,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
      'category': category,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      hasAlarm: json['hasAlarm'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      priority: json['priority'],
      category: json['category'],
    );
  }
}

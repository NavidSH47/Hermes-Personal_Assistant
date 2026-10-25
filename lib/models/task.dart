enum TaskCategory { daily, general }

enum TaskStatus { pending, done, postponed, canceled }

class Task {
  final String id;
  final String title;
  final String notes;
  final TaskCategory category;
  final String? targetDateJalali; // e.g. "1403-08-23"
  final TaskStatus status;
  final int orderIndex;
  final int postponedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.category = TaskCategory.daily,
    this.targetDateJalali,
    this.status = TaskStatus.pending,
    this.orderIndex = 0,
    this.postponedCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    TaskCategory? category,
    String? targetDateJalali,
    TaskStatus? status,
    int? orderIndex,
    int? postponedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      targetDateJalali: targetDateJalali ?? this.targetDateJalali,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
      postponedCount: postponedCount ?? this.postponedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'category': category.name,
      'targetDateJalali': targetDateJalali,
      'status': status.name,
      'orderIndex': orderIndex,
      'postponedCount': postponedCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: (json['notes'] as String?) ?? '',
      category: TaskCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TaskCategory.daily,
      ),
      targetDateJalali: json['targetDateJalali'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      orderIndex: (json['orderIndex'] as int?) ?? 0,
      postponedCount: (json['postponedCount'] as int?) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

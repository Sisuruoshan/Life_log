class GoalModel {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String status;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    this.category = 'Health',
    this.status = 'Pending',
    this.deadline,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'category': category,
      'status': status,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map, String id) {
    return GoalModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Health',
      status: map['status'] ?? 'Pending',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  GoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? status,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

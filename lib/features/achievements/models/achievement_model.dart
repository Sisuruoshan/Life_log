class AchievementModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.category = 'Academic',
    this.unlockedAt,
  }) : isUnlocked = unlockedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  factory AchievementModel.fromMap(Map<String, dynamic> map, String id) {
    return AchievementModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Academic',
      unlockedAt: map['unlockedAt'] != null 
          ? DateTime.parse(map['unlockedAt']) 
          : null,
    );
  }

  AchievementModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class BookModel {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String category;
  final String status;
  final String imageUrl;
  final DateTime createdAt;

  BookModel({
    required this.id,
    required this.userId,
    required this.title,
    this.author = '',
    this.category = '',
    this.status = 'Reading',
    this.imageUrl = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'author': author,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    return BookModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'Reading',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  BookModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    String? category,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

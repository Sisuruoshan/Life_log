import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String id;
  final String userId;
  final String title;
  final String genre;
  final double rating;
  final bool isWatched;
  final String imageUrl;
  final DateTime createdAt;

  MovieModel({
    required this.id,
    required this.userId,
    required this.title,
    this.genre = '',
    this.rating = 0.0,
    this.isWatched = false,
    this.imageUrl = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'genre': genre,
      'rating': rating,
      'isWatched': isWatched,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map, String id) {
    final createdAtRaw = map['createdAt'];

    return MovieModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      genre: map['genre'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isWatched: map['isWatched'] ?? false,
      imageUrl: map['imageUrl'] ?? '',
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : createdAtRaw is String
              ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  MovieModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? genre,
    double? rating,
    bool? isWatched,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return MovieModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      isWatched: isWatched ?? this.isWatched,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

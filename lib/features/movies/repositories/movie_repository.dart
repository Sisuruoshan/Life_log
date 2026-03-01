import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MovieRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MovieModel>> getMovies(String userId) {
    return _firestore
        .collection('movies')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final movies = snapshot.docs
          .map((doc) => MovieModel.fromMap(doc.data(), doc.id))
          .toList();
      movies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return movies;
    });
  }

  Future<void> addMovie(MovieModel movie) async {
    await _firestore.collection('movies').add(movie.toMap());
  }

  Future<void> updateMovie(MovieModel movie) async {
    await _firestore.collection('movies').doc(movie.id).update(movie.toMap());
  }

  Future<void> deleteMovie(String id) async {
    await _firestore.collection('movies').doc(id).delete();
  }
}

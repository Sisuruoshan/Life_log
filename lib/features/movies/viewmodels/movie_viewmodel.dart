import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../repositories/movie_repository.dart';

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repository = MovieRepository();
  StreamSubscription? _subscription;
  
  List<MovieModel> _movies = [];
  bool _isLoading = false;

  List<MovieModel> get movies => _movies;
  bool get isLoading => _isLoading;

  void loadMovies(String userId) {
    if (_subscription != null) return; // Prevent multiple subscriptions
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.getMovies(userId).listen((movieList) {
      _movies = movieList;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _movies = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addMovie(MovieModel movie) async {
    await _repository.addMovie(movie);
  }

  Future<void> updateMovie(MovieModel movie) async {
    await _repository.updateMovie(movie);
  }

  Future<void> deleteMovie(String id) async {
    await _repository.deleteMovie(id);
  }

  Future<void> toggleMovieWatched(MovieModel movie) async {
    final updatedMovie = movie.copyWith(isWatched: !movie.isWatched);
    await _repository.updateMovie(updatedMovie);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

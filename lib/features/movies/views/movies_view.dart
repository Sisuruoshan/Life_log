import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/movies/viewmodels/movie_viewmodel.dart';
import 'package:life_log/features/movies/models/movie_model.dart';
import 'package:life_log/features/movies/views/add_edit_movie_view.dart';

class MoviesView extends StatefulWidget {
  const MoviesView({super.key});

  @override
  State<MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<MoviesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<MovieViewModel>().loadMovies(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Tracker'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Watched'),
            Tab(text: 'Watchlist'),
            Tab(text: 'Favourites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoviesGrid(context, 'Watched'),
          _buildMoviesGrid(context, 'Watchlist'),
          _buildMoviesGrid(context, 'Favourites'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditMovieView()),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildMoviesGrid(BuildContext context, String filter) {
    final movieViewModel = context.watch<MovieViewModel>();

    if (movieViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final movies = movieViewModel.movies.where((m) {
      if (filter == 'Watched') return m.isWatched;
      if (filter == 'Watchlist') return !m.isWatched;
      if (filter == 'Favourites') return m.isWatched && m.rating >= 4.0;
      return true;
    }).toList();

    if (movies.isEmpty) {
      return const Center(child: Text('No movies found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return _buildMovieCard(context, movies[index]);
      },
    );
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {}
    }
    return NetworkImage(imageUrl);
  }

  Widget _buildMovieCard(BuildContext context, MovieModel movie) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditMovieView(isEditing: true, movie: movie)),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: movie.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: _getImageProvider(movie.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: movie.imageUrl.isEmpty 
                    ? const Icon(Icons.movie_creation_rounded, size: 60, color: Colors.purpleAccent) 
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(movie.rating.toStringAsFixed(1), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre.isNotEmpty ? movie.genre : 'No Genre',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

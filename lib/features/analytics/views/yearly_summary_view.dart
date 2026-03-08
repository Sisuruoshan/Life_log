import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/achievements/viewmodels/achievement_viewmodel.dart';
import 'package:life_log/features/books/viewmodels/book_viewmodel.dart';
import 'package:life_log/features/movies/viewmodels/movie_viewmodel.dart';
import 'package:life_log/features/tasks/viewmodels/task_viewmodel.dart';

class YearlySummaryView extends StatefulWidget {
  const YearlySummaryView({super.key});

  @override
  State<YearlySummaryView> createState() => _YearlySummaryViewState();
}

class _YearlySummaryViewState extends State<YearlySummaryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<AchievementViewModel>().loadAchievements(user.uid);
        context.read<BookViewModel>().loadBooks(user.uid);
        context.read<MovieViewModel>().loadMovies(user.uid);
        context.read<TaskViewModel>().loadTasks(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get data from ViewModels
    final achievementVM = context.watch<AchievementViewModel>();
    final bookVM = context.watch<BookViewModel>();
    final movieVM = context.watch<MovieViewModel>();
    final taskVM = context.watch<TaskViewModel>();
    
    // Calculate stats
    final totalAchievements = achievementVM.achievements.length;
    final totalBooks = bookVM.books.length;
    final completedBooks = bookVM.books.where((b) => b.status == 'Completed').length;
    final totalMovies = movieVM.movies.length;
    final watchedMovies = movieVM.movies.where((m) => m.isWatched).length;
    
    // Calculate active days (days with completed tasks or activities in current year)
    final now = DateTime.now();
    final currentYear = now.year;
    final activeDates = <DateTime>{};
    
    for (var task in taskVM.tasks) {
      if (task.createdAt.year == currentYear) {
        activeDates.add(DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day));
      }
    }
    for (var book in bookVM.books) {
      if (book.createdAt.year == currentYear) {
        activeDates.add(DateTime(book.createdAt.year, book.createdAt.month, book.createdAt.day));
      }
    }
    for (var movie in movieVM.movies) {
      if (movie.createdAt.year == currentYear) {
        activeDates.add(DateTime(movie.createdAt.year, movie.createdAt.month, movie.createdAt.day));
      }
    }
    for (var achievement in achievementVM.achievements) {
      final unlockedAt = achievement.unlockedAt;
      if (unlockedAt != null && unlockedAt.year == currentYear) {
        activeDates.add(DateTime(unlockedAt.year, unlockedAt.month, unlockedAt.day));
      }
    }
    
    final activeDaysCount = activeDates.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Yearly Review 2026',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have grown so much this year!',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Your Year in Numbers', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              children: [
                _buildStatCard(context, 'Achievements', '$totalAchievements', Icons.emoji_events_rounded, Colors.amber),
                _buildStatCard(context, 'Active Days', '$activeDaysCount', Icons.local_fire_department_rounded, Colors.orange),
                _buildStatCard(context, 'Books Read', '$completedBooks/$totalBooks', Icons.menu_book_rounded, Colors.blue),
                _buildStatCard(context, 'Movies Watched', '$watchedMovies/$totalMovies', Icons.movie_creation_rounded, Colors.purple),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

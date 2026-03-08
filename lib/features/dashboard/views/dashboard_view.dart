import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:life_log/features/books/viewmodels/book_viewmodel.dart';
import 'package:life_log/features/movies/viewmodels/movie_viewmodel.dart';
import 'package:life_log/features/goals/viewmodels/goal_viewmodel.dart';
import 'package:life_log/features/achievements/viewmodels/achievement_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Watch providers
    final authVM = context.watch<AuthViewModel>();
    final taskVM = context.watch<TaskViewModel>();
    final bookVM = context.watch<BookViewModel>();
    final movieVM = context.watch<MovieViewModel>();
    final goalVM = context.watch<GoalViewModel>();
    final achievementVM = context.watch<AchievementViewModel>();

    final userName = authVM.userModel?.name.split(' ').first ?? 'User';
    final pendingTasks = taskVM.tasks.where((t) => !t.isCompleted).toList();
    final readBooks = bookVM.books.where((b) => b.status == 'Completed').length;
    final totalBooks = bookVM.books.length;
    final watchedMovies = movieVM.movies.where((m) => m.isWatched).length;
    final totalMovies = movieVM.movies.length;
    
    int completedGoals = goalVM.goals.where((g) => g.status == 'Completed').length;
    int totalGoals = goalVM.goals.length;
    double progress = totalGoals == 0 ? 0.0 : (completedGoals / totalGoals);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeLog Dashboard'),
        actions: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.spa_rounded, size: 22, color: theme.primaryColor),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to conquer the year, $userName?',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s a snapshot of your progress.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Progress Summary Hero Card
              _buildProgressHero(context, progress, completedGoals, totalGoals),
              const SizedBox(height: 20),
              
              // Today's Tasks
              _buildSectionTitle(context, 'Pending Focus', Icons.local_fire_department_rounded),
              _buildTasksList(context, pendingTasks),
              const SizedBox(height: 20),
              
              // Books & Movies Row
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'Books', '$readBooks/$totalBooks Read', Icons.auto_stories_rounded, Colors.orangeAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(context, 'Movies', '$watchedMovies/$totalMovies Watched', Icons.movie_creation_rounded, Colors.purpleAccent)),
                ],
              ),
              const SizedBox(height: 20),
              
              // Achievements
              if (achievementVM.achievements.isNotEmpty) ...[
                 _buildSectionTitle(context, 'Latest Achievement', Icons.emoji_events_rounded),
                 _buildAchievementCard(context, achievementVM.achievements.first),
                 const SizedBox(height: 20),
              ],
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.secondary, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHero(BuildContext context, double progress, int completed, int total) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Goals Progress',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% Completed',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completed of $total Goals',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  color: theme.colorScheme.secondary,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const Icon(Icons.show_chart_rounded, color: Colors.white, size: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List pendingTasks) {
    if (pendingTasks.isEmpty) {
      return const Text("Hooray! No pending tasks right now.");
    }
    
    final tasksToShow = pendingTasks.take(3).toList();
    
    return Column(
      children: tasksToShow.map((t) => Padding(
         padding: const EdgeInsets.only(bottom: 8.0),
         child: _buildTaskItem(context, t.title, false),
      )).toList(),
    );
  }

  Widget _buildTaskItem(BuildContext context, String title, bool isCompleted) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? theme.colorScheme.secondary : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, dynamic achievement) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(achievement.category.isNotEmpty ? achievement.category : 'General', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

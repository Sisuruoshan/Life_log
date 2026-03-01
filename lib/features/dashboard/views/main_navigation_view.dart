import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:life_log/features/books/viewmodels/book_viewmodel.dart';
import 'package:life_log/features/movies/viewmodels/movie_viewmodel.dart';
import 'package:life_log/features/goals/viewmodels/goal_viewmodel.dart';
import 'package:life_log/features/achievements/viewmodels/achievement_viewmodel.dart';

import 'package:life_log/features/dashboard/views/dashboard_view.dart';
import 'package:life_log/features/tasks/views/tasks_view.dart';
import 'package:life_log/features/books/views/books_view.dart';
import 'package:life_log/features/movies/views/movies_view.dart';
import 'package:life_log/features/dashboard/views/more_options_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const TasksView(),
    const BooksView(),
    const MoviesView(),
    const MoreOptionsView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<TaskViewModel>().loadTasks(user.uid);
        context.read<BookViewModel>().loadBooks(user.uid);
        context.read<MovieViewModel>().loadMovies(user.uid);
        context.read<GoalViewModel>().loadGoals(user.uid);
        context.read<AchievementViewModel>().loadAchievements(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Books',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_rounded),
              label: 'Movies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:life_log/core/config/app_theme.dart';
import 'package:life_log/features/auth/views/auth_wrapper.dart';

// ViewModels
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:life_log/features/movies/viewmodels/movie_viewmodel.dart';
import 'package:life_log/features/books/viewmodels/book_viewmodel.dart';
import 'package:life_log/features/goals/viewmodels/goal_viewmodel.dart';
import 'package:life_log/features/achievements/viewmodels/achievement_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase when configured
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LifeLogApp());
}

class LifeLogApp extends StatelessWidget {
  const LifeLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => MovieViewModel()),
        ChangeNotifierProvider(create: (_) => BookViewModel()),
        ChangeNotifierProvider(create: (_) => GoalViewModel()),
        ChangeNotifierProvider(create: (_) => AchievementViewModel()),
      ],
      child: MaterialApp(
        title: 'LifeLog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Auto switch based on OS
        home: const AuthWrapper(),
      ),
    );
  }
}

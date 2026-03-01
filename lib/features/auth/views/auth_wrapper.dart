import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/views/main_navigation_view.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'welcome_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    if (authViewModel.user != null) {
      // Once authenticated, we can optionally load the user's data into the ViewModels 
      // globally here if not done continuously by the viewmodels or per-view.
      // E.g. context.read<TaskViewModel>().loadTasks(authViewModel.user!.uid);
      return const MainNavigationView();
    } else {
      return const WelcomeView();
    }
  }
}

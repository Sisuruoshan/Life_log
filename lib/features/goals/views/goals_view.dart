import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/goals/viewmodels/goal_viewmodel.dart';
import 'package:life_log/features/goals/models/goal_model.dart';
import 'package:life_log/features/goals/views/add_edit_goal_view.dart';
import 'package:intl/intl.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<GoalViewModel>().loadGoals(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalViewModel = context.watch<GoalViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
      ),
      body: goalViewModel.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : goalViewModel.goals.isEmpty
          ? const Center(child: Text('No goals added.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: goalViewModel.goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = goalViewModel.goals[index];
                return _buildGoalCard(context, goal);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditGoalView()),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    final theme = Theme.of(context);
    final isCompleted = goal.status == 'Completed' || goal.isCompleted;
    final dateStr = goal.deadline != null ? DateFormat('MMM d, yyyy').format(goal.deadline!) : 'No deadline';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditGoalView(isEditing: true, goal: goal)),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.track_changes_rounded,
              color: isCompleted ? Colors.green : Colors.orange,
            ),
          ),
          title: Text(
            goal.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? Colors.grey : null
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(goal.category, style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor)),
              const SizedBox(height: 4),
              Text('Deadline: $dateStr', style: theme.textTheme.bodyMedium),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              final updatedGoal = goal.copyWith(
                isCompleted: !goal.isCompleted,
                status: !goal.isCompleted ? 'Completed' : 'Pending',
              );
              context.read<GoalViewModel>().updateGoal(updatedGoal);
            },
          ),
        ),
      ),
    );
  }
}

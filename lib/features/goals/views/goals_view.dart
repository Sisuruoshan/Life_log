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

class _GoalsViewState extends State<GoalsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  void _init() {
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    _init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<GoalViewModel>().loadGoals(user.uid);
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
        title: const Text('My Goals'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatsHeader(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGoalsList(context, 'All'),
                _buildGoalsList(context, 'Pending'),
                _buildGoalsList(context, 'Completed'),
              ],
            ),
          ),
        ],
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

  Widget _buildStatsHeader(BuildContext context) {
    final goals = context.watch<GoalViewModel>().goals;
    final total = goals.length;
    final completed = goals.where((g) => g.isCompleted || g.status == 'Completed').length;
    final pending = total - completed;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      color: Theme.of(context).cardTheme.color,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(context, 'Total', '$total', Colors.blue),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Pending',
              '$pending',
              Colors.orange,
            ),
          ),
          Expanded(
            child: _buildStatItem(context, 'Completed', '$completed', Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String count,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          count,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(BuildContext context, String filter) {
    final goalViewModel = context.watch<GoalViewModel>();

    if (goalViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final goals = goalViewModel.goals.where((g) {
      final isCompleted = g.isCompleted || g.status == 'Completed';
      if (filter == 'Completed') return isCompleted;
      if (filter == 'Pending') return !isCompleted;
      return true; // All
    }).toList();

    // Sort by deadline for pending goals
    if (filter == 'Pending') {
      goals.sort(_comparePendingByDeadline);
    }

    // Sort for 'All': pending first (sorted by deadline), then completed
    if (filter == 'All') {
      goals.sort((a, b) {
        final aCompleted = a.isCompleted || a.status == 'Completed';
        final bCompleted = b.isCompleted || b.status == 'Completed';
        
        if (aCompleted != bCompleted) {
          return aCompleted ? 1 : -1; // Pending first
        }
        if (!aCompleted && !bCompleted) {
          return _comparePendingByDeadline(a, b);
        }
        return b.createdAt.compareTo(a.createdAt); // Most recent completed first
      });
    }

    if (goals.isEmpty) {
      return const Center(child: Text('No goals found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildGoalCard(context, goals[index]);
      },
    );
  }

  int _comparePendingByDeadline(GoalModel a, GoalModel b) {
    final aDeadline = a.deadline;
    final bDeadline = b.deadline;

    // Both have no deadline
    if (aDeadline == null && bDeadline == null) {
      return b.createdAt.compareTo(a.createdAt); // Most recent first
    }
    // Only a has no deadline - push to end
    if (aDeadline == null) return 1;
    // Only b has no deadline - push to end
    if (bDeadline == null) return -1;

    // Both have deadlines - sort by nearest deadline first
    final dateCompare = aDeadline.compareTo(bDeadline);
    if (dateCompare != 0) return dateCompare;
    // Same deadline - most recent first
    return b.createdAt.compareTo(a.createdAt);
  }

  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    final theme = Theme.of(context);
    final isCompleted = goal.status == 'Completed' || goal.isCompleted;
    final now = DateTime.now();
    final isOverdue = goal.deadline != null && !isCompleted && goal.deadline!.isBefore(now);
    
    final dateStr = goal.deadline != null 
        ? DateFormat('MMM d, yyyy').format(goal.deadline!) 
        : 'No deadline';
    
    final dueDateStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isOverdue ? Colors.redAccent : null,
      fontWeight: isOverdue ? FontWeight.w600 : null,
    );

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
              Text('Deadline: $dateStr', style: dueDateStyle),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: isCompleted ? Colors.green : null,
            ),
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

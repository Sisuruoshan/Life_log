import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:life_log/features/tasks/models/task_model.dart';
import 'package:life_log/features/tasks/views/add_edit_task_view.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView>
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
        context.read<TaskViewModel>().loadTasks(user.uid);
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
        title: const Text('Planner & Tasks'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Done'),
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
                _buildTasksList(context, 'All'),
                _buildTasksList(context, 'Pending'),
                _buildTasksList(context, 'Done'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskView()),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    final tasks = context.watch<TaskViewModel>().tasks;
    final total = tasks.length;
    final done = tasks.where((t) => t.isCompleted).length;
    final pending = total - done;

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
            child: _buildStatItem(context, 'Done', '$done', Colors.green),
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

  Widget _buildTasksList(BuildContext context, String filter) {
    final taskViewModel = context.watch<TaskViewModel>();

    if (taskViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tasks = taskViewModel.tasks.where((t) {
      if (filter == 'Done') return t.isCompleted;
      if (filter == 'Pending') return !t.isCompleted;
      return true; // All
    }).toList();

    if (filter == 'Pending') {
      tasks.sort(_comparePendingByDeadline);
    }

    if (filter == 'All') {
      tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (!a.isCompleted && !b.isCompleted) {
          return _comparePendingByDeadline(a, b);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
    }

    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildTaskCard(context, tasks[index]);
      },
    );
  }

  int _comparePendingByDeadline(TaskModel a, TaskModel b) {
    final aDueDate = a.dueDate;
    final bDueDate = b.dueDate;

    if (aDueDate == null && bDueDate == null) {
      return b.createdAt.compareTo(a.createdAt);
    }
    if (aDueDate == null) return 1;
    if (bDueDate == null) return -1;

    final dateCompare = aDueDate.compareTo(bDueDate);
    if (dateCompare != 0) return dateCompare;
    return b.createdAt.compareTo(a.createdAt);
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;
    final now = DateTime.now();
    final isOverdue =
        task.dueDate != null && !isDone && task.dueDate!.isBefore(now);
    final dueDateText = task.dueDate != null
        ? 'Deadline: ${MaterialLocalizations.of(context).formatCompactDate(task.dueDate!)}'
        : null;
    final dueDateStyle = theme.textTheme.bodySmall?.copyWith(
      color: isOverdue ? Colors.redAccent : null,
      fontWeight: isOverdue ? FontWeight.w600 : null,
    );

    Widget? subtitle;
    if (task.description.isNotEmpty && dueDateText != null) {
      subtitle = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(task.description),
          const SizedBox(height: 2),
          Text(dueDateText, style: dueDateStyle),
        ],
      );
    } else if (task.description.isNotEmpty) {
      subtitle = Text(task.description);
    } else if (dueDateText != null) {
      subtitle = Text(dueDateText, style: dueDateStyle);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: InkWell(
          onTap: () {
            context.read<TaskViewModel>().toggleTaskCompletion(task);
          },
          child: Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isDone ? theme.colorScheme.secondary : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditTaskView(isEditing: true, task: task),
              ),
            );
          },
        ),
      ),
    );
  }
}

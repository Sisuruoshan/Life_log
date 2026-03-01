import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/core/widgets/custom_text_field.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/goals/viewmodels/goal_viewmodel.dart';
import 'package:life_log/features/goals/models/goal_model.dart';
import 'package:intl/intl.dart';

class AddEditGoalView extends StatefulWidget {
  final bool isEditing;
  final GoalModel? goal;

  const AddEditGoalView({super.key, this.isEditing = false, this.goal});

  @override
  State<AddEditGoalView> createState() => _AddEditGoalViewState();
}

class _AddEditGoalViewState extends State<AddEditGoalView> {
  final _titleController = TextEditingController();
  String _category = 'Health';
  String _status = 'Pending';
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _category = widget.goal!.category;
      _status = widget.goal!.status;
      _deadline = widget.goal!.deadline;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _deadline != null ? DateFormat('MMM d, yyyy').format(_deadline!) : 'Select Date';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Goal' : 'Add Goal'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                if (widget.goal != null) {
                  await context.read<GoalViewModel>().deleteGoal(widget.goal!.id);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () async {
              final user = context.read<AuthViewModel>().user;
              if (user == null || _titleController.text.trim().isEmpty) return;
              
              final goalViewModel = context.read<GoalViewModel>();
              final isCompleted = _status == 'Completed';

              if (widget.isEditing && widget.goal != null) {
                 final updatedGoal = widget.goal!.copyWith(
                   title: _titleController.text.trim(),
                   category: _category,
                   status: _status,
                   deadline: _deadline,
                   isCompleted: isCompleted,
                 );
                 await goalViewModel.updateGoal(updatedGoal);
              } else {
                 final newGoal = GoalModel(
                   id: '',
                   userId: user.uid,
                   title: _titleController.text.trim(),
                   category: _category,
                   status: _status,
                   deadline: _deadline,
                   isCompleted: isCompleted,
                   createdAt: DateTime.now(),
                 );
                 await goalViewModel.addGoal(newGoal);
              }
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Goal Title',
                controller: _titleController,
                hint: 'What do you want to achieve?',
              ),
              const SizedBox(height: 20),

              Text('Category', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: theme.inputDecorationTheme.border,
                ),
                items: const [
                  DropdownMenuItem(value: 'Health', child: Text('Health')),
                  DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                  DropdownMenuItem(value: 'Career', child: Text('Career')),
                  DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                  DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                ],
                onChanged: (v) => v != null ? setState(() => _category = v) : null,
              ),
              const SizedBox(height: 20),

              Text('Status', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: theme.inputDecorationTheme.border,
                ),
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                ],
                onChanged: (v) => v != null ? setState(() => _status = v) : null,
              ),
              const SizedBox(height: 20),

              Text('Deadline', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(dateStr, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

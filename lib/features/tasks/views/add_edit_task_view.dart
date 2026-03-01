import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/core/widgets/custom_text_field.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:life_log/features/tasks/models/task_model.dart';

class AddEditTaskView extends StatefulWidget {
  final bool isEditing;
  final TaskModel? task;

  const AddEditTaskView({super.key, this.isEditing = false, this.task});

  @override
  State<AddEditTaskView> createState() => _AddEditTaskViewState();
}

class _AddEditTaskViewState extends State<AddEditTaskView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _selectedDueDate = widget.task!.dueDate;
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialDate.hour,
        initialDate.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                if (widget.task != null) {
                  if (mounted) Navigator.pop(context);
                  context.read<TaskViewModel>().deleteTask(widget.task!.id);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () {
              final user = context.read<AuthViewModel>().user;
              if (user == null || _titleController.text.trim().isEmpty) return;

              final taskViewModel = context.read<TaskViewModel>();
              
              if (mounted) Navigator.pop(context);

              if (widget.isEditing && widget.task != null) {
                final updatedTask = widget.task!.copyWith(
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  dueDate: _selectedDueDate,
                );
                taskViewModel.updateTask(updatedTask).catchError((e) {
                   debugPrint('Error updating task: $e');
                });
              } else {
                final newTask = TaskModel(
                  id: '', // Firestore sets this on add
                  userId: user.uid,
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  createdAt: DateTime.now(),
                  dueDate: _selectedDueDate,
                );
                taskViewModel.addTask(newTask).catchError((e) {
                   debugPrint('Error adding task: $e');
                });
              }
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
                label: 'Task Title',
                controller: _titleController,
                hint: 'What do you need to do?',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Description (Optional)',
                controller: _descController,
                hint: 'Any details?',
              ),
              const SizedBox(height: 24),
              Text(
                'Deadline',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDueDate == null
                              ? 'Select Deadline Date'
                              : MaterialLocalizations.of(
                                  context,
                                ).formatCompactDate(_selectedDueDate!),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
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

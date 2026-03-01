import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/core/widgets/custom_text_field.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/achievements/viewmodels/achievement_viewmodel.dart';
import 'package:life_log/features/achievements/models/achievement_model.dart';
import 'package:intl/intl.dart';

class AddEditAchievementView extends StatefulWidget {
  final bool isEditing;
  final AchievementModel? achievement;

  const AddEditAchievementView({super.key, this.isEditing = false, this.achievement});

  @override
  State<AddEditAchievementView> createState() => _AddEditAchievementViewState();
}

class _AddEditAchievementViewState extends State<AddEditAchievementView> {
  final _titleController = TextEditingController();
  String _category = 'Academic';
  DateTime? _unlockedAt;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.achievement != null) {
      _titleController.text = widget.achievement!.title;
      _category = widget.achievement!.category;
      _unlockedAt = widget.achievement!.unlockedAt;
    } else {
      _unlockedAt = DateTime.now(); // default to now
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _unlockedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _unlockedAt = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _unlockedAt != null ? DateFormat('MMM d, yyyy').format(_unlockedAt!) : 'Select Date';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Achievement' : 'Add Achievement'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                if (widget.achievement != null) {
                  await context.read<AchievementViewModel>().deleteAchievement(widget.achievement!.id);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () async {
              final user = context.read<AuthViewModel>().user;
              if (user == null || _titleController.text.trim().isEmpty) return;
              
              final achievementViewModel = context.read<AchievementViewModel>();

              if (widget.isEditing && widget.achievement != null) {
                 final updatedAchievement = widget.achievement!.copyWith(
                   title: _titleController.text.trim(),
                   category: _category,
                   unlockedAt: _unlockedAt,
                 );
                 await achievementViewModel.updateAchievement(updatedAchievement);
              } else {
                 final newAchievement = AchievementModel(
                   id: '',
                   userId: user.uid,
                   title: _titleController.text.trim(),
                   category: _category,
                   unlockedAt: _unlockedAt,
                 );
                 await achievementViewModel.addAchievement(newAchievement);
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
                label: 'Achievement Title',
                controller: _titleController,
                hint: 'What did you achieve?',
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
                  DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                  DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                  DropdownMenuItem(value: 'Fitness', child: Text('Fitness')),
                  DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                ],
                onChanged: (v) => v != null ? setState(() => _category = v) : null,
              ),
              const SizedBox(height: 20),

              Text('Date Achieved', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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

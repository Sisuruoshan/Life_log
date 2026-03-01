import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/achievements/viewmodels/achievement_viewmodel.dart';
import 'package:life_log/features/achievements/models/achievement_model.dart';
import 'package:life_log/features/achievements/views/add_edit_achievement_view.dart';
import 'package:intl/intl.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<AchievementViewModel>().loadAchievements(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievementViewModel = context.watch<AchievementViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: achievementViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : achievementViewModel.achievements.isEmpty
              ? const Center(child: Text('No achievements found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: achievementViewModel.achievements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final achievement = achievementViewModel.achievements[index];
                    return _buildAchievementCard(context, achievement);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditAchievementView()),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, AchievementModel achievement) {
    final theme = Theme.of(context);
    final dateStr = achievement.unlockedAt != null ? DateFormat('MMM d, yyyy').format(achievement.unlockedAt!) : 'Not unlocked';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditAchievementView(isEditing: true, achievement: achievement)),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(achievement.title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Earned on: $dateStr', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(achievement.category.isNotEmpty ? achievement.category : 'General', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditAchievementView(isEditing: true, achievement: achievement)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

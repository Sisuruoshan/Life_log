import 'package:flutter/material.dart';
import 'package:life_log/features/goals/views/goals_view.dart';
import 'package:life_log/features/achievements/views/achievements_view.dart';
import 'package:life_log/features/calendar/views/calendar_view.dart';
import 'package:life_log/features/analytics/views/yearly_summary_view.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';

class MoreOptionsView extends StatelessWidget {
  const MoreOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Features'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuTile(
            context,
            'Goals',
            'Track your yearly and monthly goals',
            Icons.track_changes_rounded,
            Colors.teal,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsView())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            'Achievements',
            'View and add new milestones',
            Icons.emoji_events_rounded,
            Colors.amber,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsView())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            'Calendar',
            'Monthly view of your events and deadlines',
            Icons.calendar_month_rounded,
            theme.primaryColor,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarView())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            'Yearly Summary',
            'Your entire year in statistics',
            Icons.summarize_rounded,
            Colors.deepPurpleAccent,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YearlySummaryView())),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              try {
                await context.read<AuthViewModel>().signOut();
                // AuthWrapper will automatically redirect to WelcomeView
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

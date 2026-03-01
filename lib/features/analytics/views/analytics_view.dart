import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Session & Study Time
            Row(
              children: [
                Expanded(child: _buildInfoCard(context, 'Study Time Today', '4h 30m', Icons.timer_rounded, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard(context, 'Active Session', 'Ongoing', Icons.play_circle_fill_rounded, Colors.green)),
              ],
            ),
            const SizedBox(height: 24),

            // Goal Progress %
            Text('Overall Goal Progress', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildGoalProgressWidget(context),
            const SizedBox(height: 32),

            // Weekly Chart (Bar Chart)
            Text('Weekly Study Time (hours)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildWeeklyChart(context),
            const SizedBox(height: 32),

            // Most used study apps
            Text('Most Used Apps/Resources', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildAppList(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildGoalProgressWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Annual Target', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              Text('65%', style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.65,
            minHeight: 10,
            backgroundColor: Colors.white,
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1.6,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.cardTheme.color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 8,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(days[value.toInt()], style: theme.textTheme.bodySmall),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                _makeBarGroup(0, 4, theme.primaryColor),
                _makeBarGroup(1, 5.5, theme.primaryColor),
                _makeBarGroup(2, 3, theme.primaryColor),
                _makeBarGroup(3, 6, theme.primaryColor),
                _makeBarGroup(4, 7, theme.primaryColor),
                _makeBarGroup(5, 2, Colors.grey.shade400),
                _makeBarGroup(6, 4, theme.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAppList(BuildContext context) {
    return Column(
      children: [
        _buildAppResourceTile(context, 'Notion', 'Note-taking & Planning', '2h 15m', Colors.black87),
        const SizedBox(height: 8),
        _buildAppResourceTile(context, 'Forest', 'Focus Timer', '1h 30m', Colors.green),
        const SizedBox(height: 8),
        _buildAppResourceTile(context, 'VS Code', 'Development', '45m', Colors.blue),
      ],
    );
  }

  Widget _buildAppResourceTile(BuildContext context, String name, String category, String time, Color iconColor) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.apps_rounded, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(category, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

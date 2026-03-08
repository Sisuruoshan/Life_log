import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_log/features/achievements/viewmodels/achievement_viewmodel.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/books/viewmodels/book_viewmodel.dart';
import 'package:life_log/features/goals/viewmodels/goal_viewmodel.dart';
import 'package:life_log/features/movies/viewmodels/movie_viewmodel.dart';
import 'package:life_log/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  List<_CalendarEvent> _buildEventsForDay({
    required DateTime day,
    required TaskViewModel taskVM,
    required GoalViewModel goalVM,
    required BookViewModel bookVM,
    required MovieViewModel movieVM,
    required AchievementViewModel achievementVM,
  }) {
    final targetDate = _normalizeDate(day);
    final events = <_CalendarEvent>[];

    for (final task in taskVM.tasks) {
      final taskDate = _normalizeDate(task.dueDate ?? task.createdAt);
      if (taskDate == targetDate) {
        events.add(
          _CalendarEvent(
            title: task.title,
            category: 'Task',
            timeLabel: task.dueDate != null ? DateFormat.jm().format(task.dueDate!) : 'No time',
            color: Colors.orange,
          ),
        );
      }
    }

    for (final goal in goalVM.goals) {
      final sourceDate = goal.deadline ?? goal.createdAt;
      final goalDate = _normalizeDate(sourceDate);
      if (goalDate == targetDate) {
        events.add(
          _CalendarEvent(
            title: goal.title,
            category: 'Goal',
            timeLabel: goal.deadline != null ? DateFormat.yMMMd().format(goal.deadline!) : 'Created',
            color: Colors.green,
          ),
        );
      }
    }

    for (final book in bookVM.books) {
      final bookDate = _normalizeDate(book.createdAt);
      if (bookDate == targetDate) {
        events.add(
          _CalendarEvent(
            title: book.title,
            category: 'Book',
            timeLabel: book.status,
            color: Colors.blue,
          ),
        );
      }
    }

    for (final movie in movieVM.movies) {
      final movieDate = _normalizeDate(movie.createdAt);
      if (movieDate == targetDate) {
        events.add(
          _CalendarEvent(
            title: movie.title,
            category: 'Movie',
            timeLabel: movie.isWatched ? 'Watched' : 'Added',
            color: Colors.purple,
          ),
        );
      }
    }

    for (final achievement in achievementVM.achievements) {
      final unlockedAt = achievement.unlockedAt;
      if (unlockedAt == null) continue;
      final achievementDate = _normalizeDate(unlockedAt);
      if (achievementDate == targetDate) {
        events.add(
          _CalendarEvent(
            title: achievement.title,
            category: 'Achievement',
            timeLabel: DateFormat.jm().format(unlockedAt),
            color: Colors.amber,
          ),
        );
      }
    }

    events.sort((a, b) => a.category.compareTo(b.category));
    return events;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user == null) return;

      context.read<TaskViewModel>().loadTasks(user.uid);
      context.read<GoalViewModel>().loadGoals(user.uid);
      context.read<BookViewModel>().loadBooks(user.uid);
      context.read<MovieViewModel>().loadMovies(user.uid);
      context.read<AchievementViewModel>().loadAchievements(user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskVM = context.watch<TaskViewModel>();
    final goalVM = context.watch<GoalViewModel>();
    final bookVM = context.watch<BookViewModel>();
    final movieVM = context.watch<MovieViewModel>();
    final achievementVM = context.watch<AchievementViewModel>();

    final selectedDay = _selectedDay ?? _focusedDay;
    final selectedDayEvents = _buildEventsForDay(
      day: selectedDay,
      taskVM: taskVM,
      goalVM: goalVM,
      bookVM: bookVM,
      movieVM: movieVM,
      achievementVM: achievementVM,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              eventLoader: (day) => _buildEventsForDay(
                day: day,
                taskVM: taskVM,
                goalVM: goalVM,
                bookVM: bookVM,
                movieVM: movieVM,
                achievementVM: achievementVM,
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              DateFormat('EEE, MMM d').format(selectedDay),
              style: theme.textTheme.titleLarge,
            ),
          ),
          
          Expanded(
            child: selectedDayEvents.isEmpty
                ? Center(
                    child: Text(
                      'No events for this day',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: selectedDayEvents.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildEventCard(context, selectedDayEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, _CalendarEvent event) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: event.color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text('${event.category} • ${event.timeLabel}', style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarEvent {
  final String title;
  final String category;
  final String timeLabel;
  final Color color;

  _CalendarEvent({
    required this.title,
    required this.category,
    required this.timeLabel,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';
import 'new_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final liveHabit = hp.habits.firstWhere(
      (item) => item.id == habit.id,
      orElse: () => habit,
    );
    final done = liveHabit.doneToday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Detail'),
        actions: [
          IconButton(
            tooltip: 'Edit habit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewHabitScreen(habit: liveHabit),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
        children: [
          ResponsivePage(
            padding: EdgeInsets.zero,
            maxWidth: 1040,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroCard(habit: liveHabit, done: done),
                const SizedBox(height: 14),
                _ActionDeck(habit: liveHabit),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 820;
                    final stats = _StatsCard(habit: liveHabit);
                    final detail = _DetailCard(habit: liveHabit);
                    if (!wide) {
                      return Column(children: [
                        stats,
                        const SizedBox(height: 14),
                        detail,
                      ]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: stats),
                        const SizedBox(width: 14),
                        Expanded(child: detail),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                _HeatmapCard(habit: liveHabit),
                const SizedBox(height: 14),
                _ReflectionCard(habit: liveHabit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Habit habit;
  final bool done;

  const _HeroCard({required this.habit, required this.done});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(habit.icon, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WhitePill(label: habit.category),
                    _WhitePill(label: habit.priority),
                    if (habit.paused) const _WhitePill(label: 'Paused'),
                    if (habit.archived) const _WhitePill(label: 'Archived'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  habit.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${habit.scheduleLabel} at ${habit.reminderTime} - ${done ? 'completed today' : 'ready for today'}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionDeck extends StatelessWidget {
  final Habit habit;

  const _ActionDeck({required this.habit});

  @override
  Widget build(BuildContext context) {
    final hp = context.read<HabitProvider>();
    final done = habit.doneToday();
    return AppCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilledButton.icon(
            onPressed: () => hp.toggle(habit),
            icon: Icon(done ? Icons.undo_rounded : Icons.check_rounded),
            label: Text(done ? 'Undo Complete' : 'Complete Today'),
          ),
          OutlinedButton.icon(
            onPressed: () => hp.pauseHabit(habit, !habit.paused),
            icon: Icon(habit.paused
                ? Icons.play_arrow_rounded
                : Icons.pause_circle_outline_rounded),
            label: Text(habit.paused ? 'Resume' : 'Pause'),
          ),
          OutlinedButton.icon(
            onPressed: habit.streakFreezes <= 0
                ? null
                : () => hp.useStreakFreeze(habit),
            icon: const Icon(Icons.shield_outlined),
            label: Text('Freeze (${habit.streakFreezes})'),
          ),
          OutlinedButton.icon(
            onPressed: () => hp.duplicateHabit(habit),
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Duplicate'),
          ),
          OutlinedButton.icon(
            onPressed: habit.archived ? null : () => hp.archiveHabit(habit),
            icon: const Icon(Icons.archive_outlined),
            label: const Text('Archive'),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Habit habit;

  const _StatsCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final completionRate = habit.completedDates.isEmpty
        ? 0
        : (habit.completedDates.length / 30).clamp(0, 1);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Performance',
            subtitle: 'Streak, consistency, and recovery status.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _Metric(label: 'Current', value: '${habit.streak}d')),
              const SizedBox(width: 10),
              Expanded(
                  child: _Metric(label: 'Best', value: '${habit.bestStreak}d')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Done',
                  value: '${habit.completedDates.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  label: 'Score',
                  value: '${(completionRate * 100).round()}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: completionRate.toDouble(),
            minHeight: 9,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppColors.card2,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Habit habit;

  const _DetailCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Schedule', habit.scheduleLabel, Icons.calendar_month_rounded),
      ('Goal type', _goalText(habit), Icons.flag_rounded),
      ('Difficulty', habit.difficulty, Icons.fitness_center_rounded),
      ('Reminder', habit.reminderTime, Icons.notifications_active_outlined),
      if (habit.locationLabel.isNotEmpty)
        ('Location cue', habit.locationLabel, Icons.location_on_outlined),
      if (habit.tags.isNotEmpty)
        ('Tags', habit.tags.join(', '), Icons.sell_outlined),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Habit System',
            subtitle: 'The rules and cues behind the routine.',
          ),
          const SizedBox(height: 12),
          for (final item in items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.$3, color: AppColors.primary),
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(item.$2),
            ),
        ],
      ),
    );
  }

  String _goalText(Habit habit) {
    if (habit.goalType == 'Quantity') return '${habit.quantityTarget} units';
    if (habit.goalType == 'Timer') return '${habit.timerMinutes} minutes';
    return habit.goalType;
  }
}

class _HeatmapCard extends StatelessWidget {
  final Habit habit;

  const _HeatmapCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final done = habit.completedDates.toSet();
    final frozen = habit.freezeDates.toSet();
    final today = DateTime.now();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Calendar Heatmap',
            subtitle: 'Fourteen weeks of action history.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(98, (index) {
              final date = today.subtract(Duration(days: 97 - index));
              final key = Habit.dateKey(date);
              final isDone = done.contains(key);
              final isFrozen = frozen.contains(key);
              return Tooltip(
                message:
                    '$key ${isDone ? 'completed' : isFrozen ? 'frozen' : 'open'}',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.primary
                        : isFrozen
                            ? AppColors.accent
                            : AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final Habit habit;

  const _ReflectionCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final hp = context.read<HabitProvider>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumSectionHeader(
            title: 'Notes & Recovery',
            subtitle: habit.notes.isEmpty
                ? 'Add reflections after wins or missed days.'
                : habit.notes,
            trailing: TextButton.icon(
              onPressed: () async {
                final note = await _askReflection(context);
                if (note != null) await hp.addReflection(habit, note);
              },
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Reflect'),
            ),
          ),
          const SizedBox(height: 12),
          if (habit.reflectionNotes.isEmpty)
            const Text(
              'No reflections yet. Use this space for missed-day handling, proof notes, or what changed this week.',
              style: TextStyle(color: AppColors.muted),
            )
          else
            for (final note in habit.reflectionNotes.reversed)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(note),
              ),
        ],
      ),
    );
  }

  Future<String?> _askReflection(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add reflection'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What helped, what got in the way, or what changed?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhitePill extends StatelessWidget {
  final String label;

  const _WhitePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

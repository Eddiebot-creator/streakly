import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final best = [...hp.habits]..sort((a, b) => b.streak.compareTo(a.streak));
    final weakest = [...hp.habits]..sort(
        (a, b) => a.completedDates.length.compareTo(b.completedDates.length));
    final score = _consistencyScore(hp);
    final risk = _riskLevel(hp);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          ResponsivePage(
            padding: EdgeInsets.zero,
            maxWidth: 1080,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Smart Coach',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _coach(hp),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _recommend(hp),
                              style: const TextStyle(
                                  color: Colors.white70, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      if (MediaQuery.sizeOf(context).width >= 620) ...[
                        const SizedBox(width: 18),
                        ProgressRing(value: score / 100, label: 'score'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth >= 760;
                  final cards = [
                    _SignalCard(
                      icon: Icons.psychology_rounded,
                      title: 'Consistency score',
                      value: '$score',
                      body: 'Based on today and recent completions',
                    ),
                    _SignalCard(
                      icon: Icons.shield_rounded,
                      title: 'Streak risk',
                      value: risk,
                      body: risk == 'Low'
                          ? 'Protected today'
                          : 'Needs action today',
                    ),
                    _SignalCard(
                      icon: Icons.schedule_rounded,
                      title: 'Best time',
                      value: _bestTime(hp),
                      body: 'Your strongest reminder window',
                    ),
                  ];
                  if (!wide) return Column(children: cards);
                  return Row(
                    children: [
                      for (final card in cards)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: card,
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PremiumSectionHeader(
                        title: 'Best Performing Habits',
                        subtitle:
                            'Your strongest routines deserve to be protected.',
                      ),
                      const SizedBox(height: 14),
                      if (best.isEmpty)
                        const Text('Create habits to see insights.',
                            style: TextStyle(color: AppColors.muted))
                      else
                        ...best.take(5).map((habit) =>
                            _HabitInsightRow(habit: habit, strong: true)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PremiumSectionHeader(
                        title: 'Needs Attention',
                        subtitle: 'These are the routines most likely to slip.',
                      ),
                      const SizedBox(height: 14),
                      if (weakest.isEmpty)
                        const Text('No weak spots yet.',
                            style: TextStyle(color: AppColors.muted))
                      else
                        ...weakest.take(3).map((habit) =>
                            _HabitInsightRow(habit: habit, strong: false)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _WeeklyReview(hp: hp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _consistencyScore(HabitProvider hp) {
    if (hp.habits.isEmpty) return 0;
    final base = (hp.progress * 60).round();
    final streakBonus = hp.bestStreak.clamp(0, 10) * 3;
    final volumeBonus = hp.totalCompleted.clamp(0, 20);
    return (base + streakBonus + volumeBonus).clamp(0, 100);
  }

  String _riskLevel(HabitProvider hp) {
    if (hp.habits.isEmpty) return 'None';
    if (hp.progress >= .8) return 'Low';
    if (hp.completedToday > 0) return 'Medium';
    return 'High';
  }

  String _bestTime(HabitProvider hp) {
    if (hp.habits.isEmpty) return '--';
    final hours = hp.habits
        .map((habit) => int.tryParse(habit.reminderTime.split(':').first) ?? 8)
        .toList()
      ..sort();
    final hour = hours[hours.length ~/ 2];
    if (hour < 12) return 'Morning';
    if (hour < 18) return 'Afternoon';
    return 'Evening';
  }

  String _coach(HabitProvider hp) {
    if (hp.habits.isEmpty) return 'Start with three habits, not twenty.';
    if (hp.progress == 1) return 'Perfect day. Keep the loop alive tomorrow.';
    if (hp.progress >= .5) {
      return 'You have momentum. Finish the next easiest habit.';
    }
    return 'Protect the streak with one tiny win right now.';
  }

  String _recommend(HabitProvider hp) {
    if (hp.habits.length < 3) {
      return 'Add two more simple habits so your dashboard has a balanced routine.';
    }
    if (hp.bestStreak < 3) {
      return 'Use reminders and easier goals until you reach your first 3-day streak.';
    }
    if (hp.progress < .5) {
      return 'Your next best move is not intensity. It is reducing friction.';
    }
    return 'You are ready for a weekly challenge. Try completing all habits for 3 straight days.';
  }
}

class _SignalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String body;

  const _SignalCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(body,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _HabitInsightRow extends StatelessWidget {
  final Habit habit;
  final bool strong;

  const _HabitInsightRow({required this.habit, required this.strong});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (strong ? AppColors.green : AppColors.accent)
                  .withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(habit.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                      color: AppColors.textStrong, fontWeight: FontWeight.w800),
                ),
                Text(
                  strong
                      ? '${habit.streak} current streak'
                      : '${habit.completedDates.length} total completions',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            strong ? Icons.trending_up_rounded : Icons.priority_high_rounded,
            color: strong ? AppColors.green : AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _WeeklyReview extends StatelessWidget {
  final HabitProvider hp;

  const _WeeklyReview({required this.hp});

  @override
  Widget build(BuildContext context) {
    final weekly = hp.weeklyCompleted();
    final bestDay = weekly.isEmpty ? 0 : weekly.reduce((a, b) => a > b ? a : b);
    final total = weekly.fold<int>(0, (sum, value) => sum + value);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Weekly Review',
            subtitle: 'A calm summary of what changed this week.',
          ),
          const SizedBox(height: 14),
          Text(
            total == 0
                ? 'No completions logged this week yet. Start with one simple habit today.'
                : 'You logged $total completions this week. Your strongest day had $bestDay completed habit(s).',
            style: const TextStyle(color: AppColors.muted, height: 1.45),
          ),
        ],
      ),
    );
  }
}

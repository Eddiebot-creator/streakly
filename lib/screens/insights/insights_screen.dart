import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';
import '../habit/habit_detail_screen.dart';
import '../habit/new_habit_screen.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final active = hp.activeHabits;
    final score = _consistencyScore(hp);
    final risk = _riskLevel(hp);
    final best = [...active]..sort((a, b) => b.streak.compareTo(a.streak));
    final atRisk = [...active]..sort((a, b) {
        final aDone = a.doneToday() ? 1 : 0;
        final bDone = b.doneToday() ? 1 : 0;
        return aDone.compareTo(bDone);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('AI Coach')),
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
          children: [
            ResponsivePage(
              padding: EdgeInsets.zero,
              maxWidth: 1120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CoachHero(hp: hp, score: score),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth >= 840;
                    final cards = [
                      _SignalCard(
                        icon: Icons.psychology_rounded,
                        title: 'Consistency',
                        value: '$score',
                        body: _scoreLabel(score),
                        color: AppColors.primary,
                      ),
                      _SignalCard(
                        icon: Icons.shield_rounded,
                        title: 'Streak risk',
                        value: risk,
                        body: _riskBody(risk),
                        color:
                            risk == 'Low' ? AppColors.green : AppColors.accent,
                      ),
                      _SignalCard(
                        icon: Icons.schedule_rounded,
                        title: 'Best window',
                        value: _bestTime(hp),
                        body: 'Smart reminder suggestion',
                        color: AppColors.secondary,
                      ),
                      _SignalCard(
                        icon: Icons.balance_rounded,
                        title: 'Balance',
                        value: '${_balanceScore(active)}%',
                        body: 'Category spread health',
                        color: AppColors.pink,
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
                  const SizedBox(height: 16),
                  _ActionPlan(hp: hp),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth >= 880;
                    final strongest = _HabitListCard(
                      title: 'Protect These',
                      subtitle: 'Your strongest streak engines.',
                      habits: best.take(4).toList(),
                      empty: 'Create habits to reveal your strongest routines.',
                      strong: true,
                    );
                    final recovery = _HabitListCard(
                      title: 'Needs Recovery',
                      subtitle: 'Finish these before they slip.',
                      habits: atRisk.take(4).toList(),
                      empty: 'No weak spots yet. That is a clean dashboard.',
                      strong: false,
                    );
                    if (!wide) {
                      return Column(children: [
                        strongest,
                        const SizedBox(height: 16),
                        recovery,
                      ]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: strongest),
                        const SizedBox(width: 16),
                        Expanded(child: recovery),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  _PatternLab(hp: hp),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewHabitScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit'),
      ),
    );
  }

  int _consistencyScore(HabitProvider hp) {
    if (hp.activeHabits.isEmpty) return 0;
    final base = (hp.progress * 55).round();
    final streakBonus = hp.bestStreak.clamp(0, 10) * 3;
    final volumeBonus = hp.totalCompleted.clamp(0, 15);
    final dueBonus =
        hp.dueTodayHabits.where((habit) => habit.doneToday()).length * 4;
    return (base + streakBonus + volumeBonus + dueBonus).clamp(0, 100);
  }

  String _riskLevel(HabitProvider hp) {
    if (hp.activeHabits.isEmpty) return 'None';
    if (hp.progress >= .85) return 'Low';
    if (hp.completedToday > 0) return 'Medium';
    return 'High';
  }

  String _bestTime(HabitProvider hp) {
    if (hp.activeHabits.isEmpty) return '--';
    final hours = hp.activeHabits
        .map((habit) => int.tryParse(habit.reminderTime.split(':').first) ?? 8)
        .toList()
      ..sort();
    final hour = hours[hours.length ~/ 2];
    if (hour < 12) return 'Morning';
    if (hour < 18) return 'Afternoon';
    return 'Evening';
  }

  int _balanceScore(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    final categories = habits.map((habit) => habit.category).toSet().length;
    return ((categories / habits.length).clamp(.25, 1) * 100).round();
  }

  String _scoreLabel(int score) {
    if (score >= 85) return 'Elite rhythm';
    if (score >= 65) return 'Strong momentum';
    if (score >= 35) return 'Building up';
    return 'Needs one win';
  }

  String _riskBody(String risk) {
    if (risk == 'Low') return 'Protected today';
    if (risk == 'Medium') return 'One more win helps';
    if (risk == 'High') return 'Start with easiest habit';
    return 'No habits yet';
  }
}

class _CoachHero extends StatelessWidget {
  final HabitProvider hp;
  final int score;

  const _CoachHero({required this.hp, required this.score});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(26),
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
                      color: Colors.white70, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _recommendation,
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(
                        label:
                            '${hp.completedToday}/${hp.dueTodayHabits.length} done'),
                    _HeroPill(label: '${hp.bestStreak} best streak'),
                    _HeroPill(label: '${hp.totalCompleted} lifetime wins'),
                  ],
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 620) ...[
            const SizedBox(width: 18),
            ProgressRing(value: score / 100, label: 'coach'),
          ],
        ],
      ),
    );
  }

  String get _headline {
    if (hp.activeHabits.isEmpty) {
      return 'Build a routine with three tiny anchors.';
    }
    if (hp.progress == 1) return 'Perfect day secured. Tomorrow is the play.';
    if (hp.progress >= .5) {
      return 'Momentum is live. Finish the easiest next habit.';
    }
    return 'One tiny win will restart the engine.';
  }

  String get _recommendation {
    if (hp.activeHabits.length < 3) {
      return 'Add one health habit, one focus habit, and one personal habit so Streakly can coach a balanced day.';
    }
    if (hp.bestStreak < 3) {
      return 'Keep targets easy until the first three-day streak. Consistency beats intensity here.';
    }
    if (hp.progress < .5) {
      return 'Reduce friction: lower the quantity target, move the reminder earlier, or use a streak freeze today.';
    }
    return 'You are ready for a stretch quest: protect all due habits for the next three days.';
  }
}

class _ActionPlan extends StatelessWidget {
  final HabitProvider hp;

  const _ActionPlan({required this.hp});

  @override
  Widget build(BuildContext context) {
    final actions = _actions;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Next Best Actions',
            subtitle: 'A concrete coaching queue instead of vague motivation.',
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < actions.length; i++)
            _ActionRow(number: i + 1, text: actions[i]),
        ],
      ),
    );
  }

  List<String> get _actions {
    if (hp.activeHabits.isEmpty) {
      return [
        'Create three starter habits with different categories.',
        'Set reminder times you already trust.',
        'Keep each first target small enough to finish in two minutes.',
      ];
    }
    if (hp.completedToday == 0) {
      return [
        'Complete the lowest-friction habit now.',
        'Pause or adjust any habit that no longer fits today.',
        'Add a reflection if a streak is at risk.',
      ];
    }
    if (hp.progress < 1) {
      return [
        'Finish one more due habit before your next reminder.',
        'Use a streak freeze only for a real missed day.',
        'Review the needs-recovery list below.',
      ];
    }
    return [
      'Keep the perfect day untouched.',
      'Review tomorrow reminders while motivation is high.',
      'Duplicate your best habit pattern into another category.',
    ];
  }
}

class _PatternLab extends StatelessWidget {
  final HabitProvider hp;

  const _PatternLab({required this.hp});

  @override
  Widget build(BuildContext context) {
    final weekly = hp.weeklyCompleted();
    final total = weekly.fold<int>(0, (sum, value) => sum + value);
    final bestDay = weekly.isEmpty ? 0 : weekly.reduce((a, b) => a > b ? a : b);
    final recovery =
        hp.activeHabits.where((habit) => !habit.doneToday()).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Pattern Lab',
            subtitle: 'Weekly behavior signals from your real data.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PatternChip(
                  icon: Icons.calendar_view_week_rounded,
                  label: '$total this week'),
              _PatternChip(
                  icon: Icons.trending_up_rounded, label: '$bestDay best day'),
              _PatternChip(
                  icon: Icons.healing_rounded,
                  label: '$recovery recovery items'),
              _PatternChip(icon: Icons.schedule_rounded, label: _nextReminder),
            ],
          ),
        ],
      ),
    );
  }

  String get _nextReminder {
    final due = hp.dueTodayHabits.where((habit) => !habit.doneToday()).toList()
      ..sort((a, b) => a.reminderTime.compareTo(b.reminderTime));
    if (due.isEmpty) return 'No reminder pressure';
    return 'Next: ${due.first.reminderTime}';
  }
}

class _SignalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String body;
  final Color color;

  const _SignalCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
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

class _HabitListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Habit> habits;
  final String empty;
  final bool strong;

  const _HabitListCard({
    required this.title,
    required this.subtitle,
    required this.habits,
    required this.empty,
    required this.strong,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumSectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 14),
          if (habits.isEmpty)
            Text(empty, style: const TextStyle(color: AppColors.muted))
          else
            for (final habit in habits)
              _HabitInsightRow(habit: habit, strong: strong),
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
    final color = strong ? AppColors.green : AppColors.accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(habit.icon, style: const TextStyle(fontSize: 23)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        color: AppColors.textStrong,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      strong
                          ? '${habit.streak} current streak - ${habit.scheduleLabel}'
                          : habit.doneToday()
                              ? 'Recovered today'
                              : 'Due now - ${habit.reminderTime}',
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                strong
                    ? Icons.trending_up_rounded
                    : Icons.priority_high_rounded,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final int number;
  final String text;

  const _ActionRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.primary.withValues(alpha: .12),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: const TextStyle(color: AppColors.text))),
        ],
      ),
    );
  }
}

class _PatternChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PatternChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({required this.label});

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

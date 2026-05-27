import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';
import '../habit/new_habit_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final xp = hp.totalCompleted * 12 +
        hp.bestStreak * 30 +
        hp.activeHabits.length * 20;
    final league = _leagueFor(xp);
    final challenges = [
      _Challenge(
          'Daily Spark',
          'Complete one habit today',
          Icons.flash_on_rounded,
          hp.completedToday >= 1,
          hp.completedToday.clamp(0, 1),
          1,
          40),
      _Challenge(
          'Perfect Day',
          'Complete every habit today',
          Icons.verified_rounded,
          hp.dueTodayHabits.isNotEmpty &&
              hp.completedToday == hp.dueTodayHabits.length,
          hp.completedToday,
          hp.dueTodayHabits.isEmpty ? 1 : hp.dueTodayHabits.length,
          90),
      _Challenge(
          'Habit Builder',
          'Create 5 habits',
          Icons.add_task_rounded,
          hp.activeHabits.length >= 5,
          hp.activeHabits.length.clamp(0, 5),
          5,
          120),
      _Challenge(
          'Streak Master',
          'Reach a 10-day best streak',
          Icons.local_fire_department_rounded,
          hp.bestStreak >= 10,
          hp.bestStreak.clamp(0, 10),
          10,
          180),
      _Challenge(
          'Consistency Club',
          'Complete 25 total habits',
          Icons.workspace_premium_rounded,
          hp.totalCompleted >= 25,
          hp.totalCompleted.clamp(0, 25),
          25,
          220),
    ];
    final completed =
        challenges.where((challenge) => challenge.complete).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
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
                  child: LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth >= 700;
                    return Flex(
                      direction: wide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: wide
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: wide ? 1 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Streak League',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                league,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$xp XP earned from completions, streaks, and habit building.',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        if (wide)
                          const SizedBox(width: 24)
                        else
                          const SizedBox(height: 20),
                        _LeagueBadge(
                            xp: xp,
                            completed: completed,
                            total: challenges.length),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 22),
                PremiumSectionHeader(
                  title: 'Quest Board',
                  subtitle:
                      'Duolingo-style motivation, built from your real habit data.',
                  trailing: TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewHabitScreen()),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New habit'),
                  ),
                ),
                const SizedBox(height: 12),
                ...challenges
                    .map((challenge) => _ChallengeTile(challenge: challenge)),
                const SizedBox(height: 18),
                _RewardPath(challenges: challenges),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _leagueFor(int xp) {
    if (xp >= 1800) return 'Diamond League';
    if (xp >= 1000) return 'Gold League';
    if (xp >= 500) return 'Silver League';
    return 'Starter League';
  }
}

class _ChallengeTile extends StatelessWidget {
  final _Challenge challenge;

  const _ChallengeTile({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final progress =
        challenge.target == 0 ? 0.0 : challenge.current / challenge.target;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        color: challenge.complete
            ? AppColors.secondary.withValues(alpha: .08)
            : AppColors.surface,
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: challenge.complete
                    ? AppColors.green.withValues(alpha: .14)
                    : AppColors.primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                challenge.icon,
                color: challenge.complete ? AppColors.green : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: const TextStyle(
                            color: AppColors.textStrong,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '+${challenge.xp} XP',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    challenge.body,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: AppColors.card2,
                    valueColor: AlwaysStoppedAnimation(
                      challenge.complete ? AppColors.green : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              challenge.complete
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: challenge.complete ? AppColors.green : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeagueBadge extends StatelessWidget {
  final int xp;
  final int completed;
  final int total;

  const _LeagueBadge(
      {required this.xp, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 44),
          const SizedBox(height: 10),
          Text(
            '$completed/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text('quests cleared', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('$xp XP',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _RewardPath extends StatelessWidget {
  final List<_Challenge> challenges;

  const _RewardPath({required this.challenges});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Reward Path',
            subtitle: 'Milestones that make long-term effort visible.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < challenges.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: challenges[i].complete
                            ? AppColors.primary
                            : AppColors.card2,
                        child: Icon(
                          challenges[i].icon,
                          color: challenges[i].complete
                              ? Colors.white
                              : AppColors.muted,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${challenges[i].xp}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != challenges.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: challenges[i].complete
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Challenge {
  final String title;
  final String body;
  final IconData icon;
  final bool complete;
  final int current;
  final int target;
  final int xp;

  const _Challenge(
    this.title,
    this.body,
    this.icon,
    this.complete,
    this.current,
    this.target,
    this.xp,
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../habit/new_habit_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final challenges = [
      (
        '7-Day Consistency',
        'Complete at least one habit daily for 7 days',
        Icons.local_fire_department_rounded,
        hp.totalCompleted >= 7
      ),
      (
        'Perfect Day',
        'Complete every habit today',
        Icons.verified_rounded,
        hp.habits.isNotEmpty && hp.completedToday == hp.habits.length
      ),
      (
        'Habit Builder',
        'Create 5 habits',
        Icons.add_task_rounded,
        hp.habits.length >= 5
      ),
      (
        'Streak Master',
        'Reach a best streak of 10',
        Icons.workspace_premium_rounded,
        hp.bestStreak >= 10
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        ResponsivePage(
            padding: EdgeInsets.zero,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppCard(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark]),
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily challenges',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                              color: Colors.white)),
                      SizedBox(height: 6),
                      Text(
                          'Complete real goals from your saved habits. Progress updates automatically.',
                          style: TextStyle(color: Colors.white)),
                    ]),
              ),
              const SizedBox(height: 18),
              ...challenges.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                        child: Row(children: [
                      Icon(c.$3,
                          color: c.$4 ? AppColors.green : AppColors.accent,
                          size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(c.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textStrong)),
                            Text(c.$2,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 12)),
                          ])),
                      Icon(
                          c.$4
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: c.$4 ? AppColors.green : AppColors.muted),
                    ])),
                  )),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewHabitScreen())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Challenge Habit'),
              ),
            ])),
      ]),
    );
  }
}

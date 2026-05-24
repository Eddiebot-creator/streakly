import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final best = [...hp.habits]..sort((a, b) => b.streak.compareTo(a.streak));
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        ResponsivePage(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppCard(gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.purple]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Smart Coach', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(_coach(hp), style: const TextStyle(color: Colors.white70)),
          ])),
          const SizedBox(height: 18),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Best Performing Habits', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 12),
            if (best.isEmpty) const Text('Create habits to see insights.', style: TextStyle(color: AppColors.muted))
            else ...best.take(5).map((h) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Text(h.icon, style: const TextStyle(fontSize: 22)), const SizedBox(width: 12), Expanded(child: Text(h.title)), Text('${h.streak} 🔥', style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900))]))),
          ])),
          const SizedBox(height: 14),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Recommendation', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            Text(_recommend(hp), style: const TextStyle(color: AppColors.muted)),
          ])),
        ])),
      ]),
    );
  }

  String _coach(HabitProvider hp) {
    if (hp.habits.isEmpty) return 'Start with 3 habits: one health, one learning, and one personal goal.';
    if (hp.progress == 1) return 'Perfect day. Keep the streak alive tomorrow.';
    if (hp.progress >= .5) return 'Good pace. Finish one more habit to strengthen today’s momentum.';
    return 'Start small. Complete your easiest habit first to avoid losing momentum.';
  }

  String _recommend(HabitProvider hp) {
    if (hp.habits.length < 3) return 'Add two more simple habits so your dashboard has a balanced routine.';
    if (hp.bestStreak < 3) return 'Use reminders and choose easier goals until you reach your first 3-day streak.';
    return 'You are ready for a weekly challenge. Try completing all habits for 3 straight days.';
  }
}

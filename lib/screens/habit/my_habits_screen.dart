import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import 'new_habit_screen.dart';

class MyHabitsScreen extends StatefulWidget {
  const MyHabitsScreen({super.key});

  @override
  State<MyHabitsScreen> createState() => _MyHabitsScreenState();
}

class _MyHabitsScreenState extends State<MyHabitsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HabitProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Alex';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('My Habits', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text('Tuesday, Oct 24', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ])),
                  CircleAvatar(backgroundColor: AppColors.purple, child: Text(name.isEmpty ? 'A' : name[0].toUpperCase())),
                ]),
                const SizedBox(height: 16),
                AppCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(7, (i) {
                  final done = i < hp.weeklyCompleted().where((e) => e > 0).length;
                  return Column(children: [
                    Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i], style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                    const SizedBox(height: 5),
                    Container(width: 28, height: 28, decoration: BoxDecoration(color: done ? AppColors.green : AppColors.card2, borderRadius: BorderRadius.circular(6)), child: done ? const Icon(Icons.check, size: 16) : null),
                  ]);
                }))),
                const SizedBox(height: 18),
                Row(children: [
                  _MiniStat(label: 'Success', value: '${(hp.progress * 100).round()}%'),
                  const SizedBox(width: 12),
                  _MiniStat(label: 'Streak', value: '${hp.totalStreak} Days'),
                ]),
                const SizedBox(height: 22),
                Row(children: [
                  const Expanded(child: Text("Today's Focus", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                  TextButton(onPressed: () {}, child: const Text('View All')),
                ]),
                if (hp.loading) const Center(child: CircularProgressIndicator())
                else if (hp.habits.isEmpty) const AppCard(child: Text('No habits yet. Tap New Habit to add one.'))
                else ...hp.habits.map((h) => _FocusTile(habit: h)),
                const SizedBox(height: 14),
                AppCard(child: Row(children: const [
                  Icon(Icons.emoji_events, color: AppColors.yellow, size: 42),
                  SizedBox(width: 12),
                  Expanded(child: Text('Almost there! Complete one more habit to reach your daily goal.')),
                ])),
                const SizedBox(height: 20),
                SizedBox(height: 54, child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewHabitScreen())),
                  icon: const Icon(Icons.add), label: const Text('New Habit'),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))])));
}

class _FocusTile extends StatelessWidget {
  final Habit habit;
  const _FocusTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final done = habit.doneToday();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.purple.withOpacity(.18), borderRadius: BorderRadius.circular(10)), child: Text(habit.icon)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(habit.title, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${habit.category} • ${habit.reminderTime}', style: const TextStyle(color: AppColors.muted, fontSize: 12))])),
          Checkbox(value: done, onChanged: (_) => context.read<HabitProvider>().toggle(habit)),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => NewHabitScreen(habit: habit)));
              if (v == 'delete') context.read<HabitProvider>().deleteHabit(habit);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
          ),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: done ? 1 : .45, minHeight: 8, borderRadius: BorderRadius.circular(10), backgroundColor: AppColors.card2, valueColor: const AlwaysStoppedAnimation(AppColors.purple)),
        const SizedBox(height: 6),
        Text('Daily Goal: ${done ? 'Completed' : 'In progress'}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ])),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/responsive_page.dart';
import '../habit/new_habit_screen.dart';

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
    final initial = (user?.email?.isNotEmpty ?? false) ? user!.email![0].toUpperCase() : 'S';
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: ListView(children: [
          ResponsivePage(
            maxWidth: MediaQuery.of(context).size.width >= 900 ? 1040 : 460,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My Habits', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text('Tuesday, Oct 24', style: TextStyle(color: AppColors.muted))])),
                CircleAvatar(backgroundColor: AppColors.purple, child: Text(initial)),
              ]),
              const SizedBox(height: 22),
              _WeekProgress(hp: hp),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Metric(label: 'Success', value: '${(hp.progress * 100).round()}%')),
                const SizedBox(width: 12),
                Expanded(child: _Metric(label: 'Streak', value: '${hp.totalStreak} Days')),
              ]),
              const SizedBox(height: 28),
              Row(children: [
                const Expanded(child: Text("Today's Focus", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ]),
              if (hp.loading)
                const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
              else if (hp.habits.isEmpty)
                const AppCard(child: Text('No focus habits yet. Create one with + New Habit.'))
              else
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 760;
                  if (wide) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 4.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: hp.habits.length,
                      itemBuilder: (_, i) => _FocusTile(habit: hp.habits[i]),
                    );
                  }
                  return Column(children: hp.habits.map((h) => _FocusTile(habit: h)).toList());
                }),
              const SizedBox(height: 20),
              AppCard(child: Row(children: const [Icon(Icons.emoji_events, color: AppColors.yellow, size: 40), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Almost there!', style: TextStyle(fontWeight: FontWeight.w900)), Text('Complete a habit today to protect your streak.', style: TextStyle(color: AppColors.muted))])), Text('Keep Going', style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900))])),
              const SizedBox(height: 80),
            ]),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.purple,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewHabitScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
    );
  }
}

class _WeekProgress extends StatelessWidget {
  final HabitProvider hp;
  const _WeekProgress({required this.hp});
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: today.weekday - 1 - i)));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return AppCard(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(7, (i) {
        final key = Habit.dateKey(days[i]);
        final done = hp.habits.any((h) => h.completedDates.contains(key));
        return Column(children: [Text(labels[i], style: const TextStyle(color: AppColors.muted)), const SizedBox(height: 8), Container(width: 38, height: 38, decoration: BoxDecoration(color: done ? AppColors.green : AppColors.card2, borderRadius: BorderRadius.circular(10)), child: done ? const Icon(Icons.check) : null)]);
      })),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.muted)), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))]));
}

class _FocusTile extends StatelessWidget {
  final Habit habit;
  const _FocusTile({required this.habit});
  @override
  Widget build(BuildContext context) {
    final done = habit.doneToday();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(children: [
          Row(children: [
            Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.purple.withOpacity(.22), borderRadius: BorderRadius.circular(14)), child: Text(habit.icon, style: const TextStyle(fontSize: 22))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(habit.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), Text('${habit.category} • ${habit.reminderTime}', style: const TextStyle(color: AppColors.muted))])),
            IconButton(onPressed: () => context.read<HabitProvider>().toggle(habit), icon: Icon(done ? Icons.check_box : Icons.check_box_outline_blank, color: done ? AppColors.green : Colors.white)),
            PopupMenuButton<String>(onSelected: (v) async { if (v == 'delete') await context.read<HabitProvider>().deleteHabit(habit); }, itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete'))]),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: done ? 1 : .45, backgroundColor: AppColors.card2, valueColor: AlwaysStoppedAnimation(done ? AppColors.green : AppColors.purple), borderRadius: BorderRadius.circular(30)),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: Text(done ? 'Daily Goal: Completed' : 'Daily Goal: In progress', style: const TextStyle(color: AppColors.muted))),
        ]),
      ),
    );
  }
}

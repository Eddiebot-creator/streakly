import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Habits')),
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  children: [
                    AppCard(
                      gradient: const LinearGradient(colors: [AppColors.purple2, AppColors.pink]),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 34),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${hp.habits.length} active habits • ${hp.completedToday} completed today', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    if (hp.loading) const CircularProgressIndicator() else if (hp.habits.isEmpty) const AppCard(child: Text('No habits yet. Create your first habit.')) else ...hp.habits.map((h) => _ManageHabitTile(habit: h)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewHabitScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
    );
  }
}

class _ManageHabitTile extends StatelessWidget {
  final Habit habit;
  const _ManageHabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final hp = context.read<HabitProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(children: [
          Text(habit.icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text('${habit.category} • ${habit.frequency} • ${habit.reminderTime}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            Text('🔥 ${habit.streak} current • 🏆 ${habit.bestStreak} best', style: const TextStyle(color: AppColors.yellow, fontSize: 12)),
          ])),
          IconButton(onPressed: () => hp.toggle(habit), icon: Icon(habit.doneToday() ? Icons.check_circle : Icons.radio_button_unchecked, color: habit.doneToday() ? AppColors.green : AppColors.muted)),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewHabitScreen(habit: habit))), icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete habit?'), content: Text('Delete ${habit.title}?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
            if (ok == true) await hp.deleteHabit(habit);
          }, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
        ]),
      ),
    );
  }
}

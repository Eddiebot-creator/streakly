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
    final habits = context.read<HabitProvider>();
    Future.microtask(habits.load);
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
            ResponsivePage(
              padding: EdgeInsets.zero,
              maxWidth: 980,
              child: Column(children: [
                AppCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 34, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${hp.habits.length} active habits - ${hp.completedToday} completed today',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                if (hp.loading)
                  const CircularProgressIndicator()
                else if (hp.habits.isEmpty)
                  const AppCard(
                      child: Text('No habits yet. Create your first habit.',
                          style: TextStyle(color: AppColors.muted)))
                else
                  ...hp.habits.map((h) => _ManageHabitTile(habit: h)),
              ]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NewHabitScreen())),
        icon: const Icon(Icons.add_rounded),
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
    final done = habit.doneToday();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        color:
            done ? AppColors.secondary.withValues(alpha: .08) : AppColors.card,
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.green.withValues(alpha: .14)
                  : AppColors.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(habit.icon, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(habit.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textStrong)),
                Text(
                    '${habit.category} - ${habit.frequency} - ${habit.reminderTime}',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
                Text('${habit.streak} current - ${habit.bestStreak} best',
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ])),
          IconButton(
            onPressed: () => hp.toggle(habit),
            icon: Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.green : AppColors.muted),
          ),
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NewHabitScreen(habit: habit))),
            icon: const Icon(Icons.edit_outlined, color: AppColors.muted),
          ),
          IconButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete habit?'),
                  content: Text('Delete ${habit.title}?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true) {
                await hp.deleteHabit(habit);
              }
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ]),
      ),
    );
  }
}

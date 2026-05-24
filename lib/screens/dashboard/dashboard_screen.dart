import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../challenges/challenges_screen.dart';
import '../habit/new_habit_screen.dart';
import '../insights/insights_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HabitProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Streakly User';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= 900;
          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              ResponsivePage(
                padding: EdgeInsets.zero,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Good Morning, $name 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('You are one step closer today. Keep it up!', style: TextStyle(color: AppColors.muted)),
                    ])),
                    Image.asset('assets/icon/streakly_logo.png', width: 54, height: 54),
                  ]),
                  const SizedBox(height: 18),
                  if (wide)
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 3, child: _ProgressCard(hp: hp)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _QuickStats(hp: hp)),
                    ])
                  else ...[
                    _ProgressCard(hp: hp),
                    const SizedBox(height: 16),
                    _QuickStats(hp: hp),
                  ],
                  const SizedBox(height: 22),
                  Row(children: [
                    const Expanded(child: Text("Today's Habits", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
                    TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewHabitScreen())), icon: const Icon(Icons.add), label: const Text('Add')),
                  ]),
                  const SizedBox(height: 10),
                  if (hp.loading)
                    const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()))
                  else if (hp.error != null)
                    AppCard(child: Text(hp.error!, style: const TextStyle(color: Colors.redAccent)))
                  else if (hp.habits.isEmpty)
                    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('No habits yet', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 6),
                      const Text('Create your first habit and start building momentum.', style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewHabitScreen())), icon: const Icon(Icons.add), label: const Text('Create Habit')),
                    ]))
                  else
                    ...hp.habits.take(5).map((h) => HabitTile(habit: h)),
                  const SizedBox(height: 22),
                  const Text('Explore Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: wide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: wide ? 1.45 : 1.35,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _Tool(icon: Icons.emoji_events, title: 'Challenges', sub: 'Join events', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen()))),
                      _Tool(icon: Icons.insights, title: 'Insights', sub: 'Smart habit data', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen()))),
                      _Tool(icon: Icons.alarm, title: 'Reminder', sub: 'Open add habit', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewHabitScreen()))),
                      _Tool(icon: Icons.download, title: 'Export', sub: 'Copy CSV', onTap: () async { await hp.exportCsvToClipboard(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard'))); }),
                    ],
                  ),
                ]),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final HabitProvider hp;
  const _ProgressCard({required this.hp});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      gradient: const LinearGradient(colors: [AppColors.purple, AppColors.cyan]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Daily Goal Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${(hp.progress * 100).round()}%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
        LinearProgressIndicator(value: hp.progress, minHeight: 12, borderRadius: BorderRadius.circular(20), backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(AppColors.yellow)),
        const SizedBox(height: 8),
        Text('${hp.completedToday} of ${hp.habits.length} habits completed'),
      ]),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final HabitProvider hp;
  const _QuickStats({required this.hp});
  @override
  Widget build(BuildContext context) => AppCard(child: Column(children: [
    _MiniStat('Current streaks', '${hp.totalStreak}', Icons.local_fire_department),
    const Divider(color: Colors.white12),
    _MiniStat('Best streak', '${hp.bestStreak}', Icons.workspace_premium),
    const Divider(color: Colors.white12),
    _MiniStat('Completed', '${hp.totalCompleted}', Icons.check_circle),
  ]));
}

class _MiniStat extends StatelessWidget {
  final String title, value; final IconData icon;
  const _MiniStat(this.title, this.value, this.icon);
  @override Widget build(BuildContext context) => Row(children: [Icon(icon, color: AppColors.yellow), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: AppColors.muted))), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]);
}

class HabitTile extends StatelessWidget {
  final Habit habit;
  const HabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final done = habit.doneToday();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        color: done ? const Color(0xFF163A38) : AppColors.card,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: done ? AppColors.green.withOpacity(.2) : AppColors.purple.withOpacity(.18), borderRadius: BorderRadius.circular(16)), child: Text(habit.icon, style: const TextStyle(fontSize: 24))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('${habit.category} • ${habit.frequency}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            Text('🔥 ${habit.streak} day streak', style: const TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
          ])),
          IconButton(onPressed: () => context.read<HabitProvider>().toggle(habit), icon: Icon(done ? Icons.check_box : Icons.add_box_outlined, color: done ? AppColors.green : AppColors.muted, size: 34)),
        ]),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon; final String title, sub; final VoidCallback onTap;
  const _Tool({required this.icon, required this.title, required this.sub, required this.onTap});
  @override Widget build(BuildContext context) => AppCard(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: AppColors.yellow), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 12))]));
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';
import '../habit/habit_detail_screen.dart';
import '../habit/new_habit_screen.dart';

class MyHabitsScreen extends StatefulWidget {
  const MyHabitsScreen({super.key});

  @override
  State<MyHabitsScreen> createState() => _MyHabitsScreenState();
}

class _MyHabitsScreenState extends State<MyHabitsScreen> {
  final search = TextEditingController();
  String filter = 'Active';

  @override
  void initState() {
    super.initState();
    Future.microtask(context.read<HabitProvider>().load);
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final habits = _filteredHabits(hp);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Studio')),
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
          children: [
            ResponsivePage(
              padding: EdgeInsets.zero,
              maxWidth: 1080,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroSummary(hp: hp),
                  const SizedBox(height: 14),
                  _Controls(
                    search: search,
                    filter: filter,
                    onFilter: (value) => setState(() => filter = value),
                    onSearch: () => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  if (hp.loading)
                    const _LoadingList()
                  else if (habits.isEmpty)
                    PremiumEmptyState(
                      icon: Icons.auto_awesome_rounded,
                      title: 'No habits in this view',
                      body:
                          'Adjust the filter or create a habit with schedule, priority, goal type, notes, tags, and recovery.',
                      actionLabel: 'New Habit',
                      onAction: _openNewHabit,
                    )
                  else
                    ...habits.map((habit) => _ManageHabitTile(habit: habit)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewHabit,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit'),
      ),
    );
  }

  List<Habit> _filteredHabits(HabitProvider hp) {
    Iterable<Habit> source = hp.habits;
    if (filter == 'Active') {
      source = source.where((habit) => habit.isActive);
    } else if (filter == 'Due today') {
      source = source.where((habit) => habit.isDueToday);
    } else if (filter == 'Paused') {
      source = source.where((habit) => habit.paused && !habit.archived);
    } else if (filter == 'Archived') {
      source = source.where((habit) => habit.archived);
    } else if (filter == 'High priority') {
      source = source.where((habit) => habit.priority == 'High');
    }

    final query = search.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      source = source.where((habit) {
        final haystack = [
          habit.title,
          habit.category,
          habit.priority,
          habit.difficulty,
          habit.goalType,
          habit.tags.join(' '),
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      });
    }

    return source.toList()
      ..sort((a, b) {
        final priority = {'High': 0, 'Medium': 1, 'Low': 2};
        return (priority[a.priority] ?? 3).compareTo(priority[b.priority] ?? 3);
      });
  }

  void _openNewHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewHabitScreen()),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  final HabitProvider hp;

  const _HeroSummary({required this.hp});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      child: Row(
        children: [
          ProgressRing(value: hp.progress, label: 'today', size: 92),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Habit Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${hp.activeHabits.length} active - ${hp.dueTodayHabits.length} due today - ${hp.archivedHabits.length} archived',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(label: '${hp.completedToday} completed'),
                    _HeroPill(label: '${hp.totalStreak} streak points'),
                    _HeroPill(
                        label:
                            hp.offlineMode ? 'Offline ready' : 'Cloud synced'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final TextEditingController search;
  final String filter;
  final ValueChanged<String> onFilter;
  final VoidCallback onSearch;

  const _Controls({
    required this.search,
    required this.filter,
    required this.onFilter,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      'Active',
      'Due today',
      'Paused',
      'Archived',
      'High priority',
      'All',
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: search,
            onChanged: (_) => onSearch(),
            decoration: const InputDecoration(
              labelText: 'Search habits, tags, category, priority',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in filters)
                ChoiceChip(
                  label: Text(item),
                  selected: filter == item,
                  onSelected: (_) => onFilter(item),
                ),
            ],
          ),
        ],
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        ),
        color:
            done ? AppColors.secondary.withValues(alpha: .08) : AppColors.card,
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.green.withValues(alpha: .14)
                    : AppColors.primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(habit.icon, style: const TextStyle(fontSize: 26)),
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
                          habit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.textStrong,
                          ),
                        ),
                      ),
                      _StatusPill(habit: habit),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${habit.category} - ${habit.scheduleLabel} - ${habit.reminderTime}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _TinyPill(label: '${habit.streak} current'),
                      _TinyPill(label: '${habit.bestStreak} best'),
                      _TinyPill(label: habit.priority),
                      _TinyPill(label: habit.goalType),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: done ? 'Undo complete' : 'Complete today',
              onPressed: () => hp.toggle(habit),
              icon: Icon(done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded),
              color: done ? AppColors.green : AppColors.primary,
            ),
            PopupMenuButton<String>(
              tooltip: 'More actions',
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NewHabitScreen(habit: habit)),
                  );
                }
                if (value == 'pause') await hp.pauseHabit(habit, !habit.paused);
                if (value == 'duplicate') await hp.duplicateHabit(habit);
                if (value == 'freeze') await hp.useStreakFreeze(habit);
                if (value == 'archive') await hp.archiveHabit(habit);
                if (value == 'delete' && context.mounted) {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete habit?'),
                      content: Text('Delete ${habit.title}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await hp.deleteHabit(habit);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'pause',
                  child: Text(habit.paused ? 'Resume' : 'Pause'),
                ),
                const PopupMenuItem(
                    value: 'duplicate', child: Text('Duplicate')),
                PopupMenuItem(
                  value: 'freeze',
                  enabled: habit.streakFreezes > 0,
                  child: Text('Use freeze (${habit.streakFreezes})'),
                ),
                const PopupMenuItem(value: 'archive', child: Text('Archive')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Habit habit;

  const _StatusPill({required this.habit});

  @override
  Widget build(BuildContext context) {
    final label = habit.archived
        ? 'Archived'
        : habit.paused
            ? 'Paused'
            : habit.isDueToday
                ? 'Due'
                : 'Later';
    final color = habit.archived
        ? AppColors.hint
        : habit.paused
            ? AppColors.accent
            : habit.isDueToday
                ? AppColors.primary
                : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  final String label;

  const _TinyPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
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

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.card2,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 180,
                        decoration: BoxDecoration(
                          color: AppColors.card2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 10,
                        width: 260,
                        decoration: BoxDecoration(
                          color: AppColors.card2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/habit_templates.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';
import '../challenges/challenges_screen.dart';
import '../habit/new_habit_screen.dart';
import '../insights/insights_screen.dart';
import '../statistics/statistics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final habits = context.read<HabitProvider>();
    Future.microtask(habits.load);
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final name =
        user?.displayName ?? user?.email?.split('@').first ?? 'Streakly User';
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 110),
          children: [
            ResponsivePage(
              padding: EdgeInsets.zero,
              maxWidth: 1240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(name: name),
                  const SizedBox(height: 18),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _CommandCenter(hp: hp)),
                        const SizedBox(width: 16),
                        Expanded(flex: 4, child: _MomentumPanel(hp: hp)),
                      ],
                    )
                  else ...[
                    _CommandCenter(hp: hp),
                    const SizedBox(height: 16),
                    _MomentumPanel(hp: hp),
                  ],
                  const SizedBox(height: 26),
                  PremiumSectionHeader(
                    title: "Today's Focus",
                    subtitle: _focusSubtitle(hp),
                    trailing: TextButton.icon(
                      onPressed: () => _openNewHabit(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (hp.loading)
                    const _DashboardLoading()
                  else if (hp.error != null)
                    _ErrorCard(message: hp.error!, onRetry: hp.load)
                  else if (hp.habits.isEmpty)
                    PremiumEmptyState(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Your future routine starts here',
                      body:
                          'Add a habit or use a starter template to build momentum in under a minute.',
                      actionLabel: 'Create Habit',
                      onAction: () => _openNewHabit(context),
                    )
                  else
                    _HabitFocusList(habits: hp.habits.take(6).toList()),
                  const SizedBox(height: 26),
                  if (hp.habits.isEmpty)
                    _StarterTemplateStrip(onPick: (template) async {
                      await hp.addHabit(
                        template.title,
                        template.category,
                        template.icon,
                        template.frequency,
                        template.reminder,
                      );
                    })
                  else
                    _AnalyticsPreview(hp: hp),
                  const SizedBox(height: 26),
                  _ToolGrid(wide: wide),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewHabit(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit'),
      ),
    );
  }

  String _focusSubtitle(HabitProvider hp) {
    if (hp.habits.isEmpty) return 'Set up your first streak-worthy action.';
    if (hp.progress == 1) return 'Perfect day. You protected every streak.';
    return '${hp.habits.length - hp.completedToday} habit(s) left to complete today.';
  }

  void _openNewHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewHabitScreen()),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String name;

  const _DashboardHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_dayPart()}, $name',
                style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _dateLabel(DateTime.now()),
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            _initials(name),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  static String _dayPart() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  static String _dateLabel(DateTime date) {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY'
    ];
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER'
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  static String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'SU';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _CommandCenter extends StatelessWidget {
  final HabitProvider hp;

  const _CommandCenter({required this.hp});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(26),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -44,
            top: -46,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today Command Center',
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _headline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _body,
                      style:
                          const TextStyle(color: Colors.white70, height: 1.45),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _CommandPill(
                          icon: Icons.check_circle_rounded,
                          label:
                              '${hp.completedToday}/${hp.habits.length} done',
                        ),
                        _CommandPill(
                          icon: Icons.local_fire_department_rounded,
                          label: '${hp.totalStreak} streak points',
                        ),
                        _CommandPill(
                          icon: Icons.workspace_premium_rounded,
                          label: '${hp.bestStreak} best',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width >= 560) ...[
                const SizedBox(width: 20),
                ProgressRing(value: hp.progress, label: 'today'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String get _headline {
    if (hp.habits.isEmpty) return 'Design your first winning day.';
    if (hp.progress == 1) return 'Perfect day secured.';
    if (hp.completedToday == 0) return 'Start with the easiest win.';
    return 'Momentum is active. Finish strong.';
  }

  String get _body {
    if (hp.habits.isEmpty) {
      return 'Pick a starter habit, set a reminder, and let Streakly turn progress into a visible streak.';
    }
    if (hp.progress == 1) {
      return 'Every habit is complete today. Come back tomorrow and protect the streak.';
    }
    return 'Complete one more habit now. Small actions compound when they are visible.';
  }
}

class _MomentumPanel extends StatelessWidget {
  final HabitProvider hp;

  const _MomentumPanel({required this.hp});

  @override
  Widget build(BuildContext context) {
    final dates = hp.habits.expand((habit) => habit.completedDates).toSet();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Momentum Map',
            subtitle: 'Last 35 days of completions',
          ),
          const SizedBox(height: 16),
          MiniHeatmap(completedDates: dates),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: _SmallMetric(
                      label: 'Total done', value: '${hp.totalCompleted}')),
              const SizedBox(width: 10),
              Expanded(
                  child: _SmallMetric(
                      label: 'Completion',
                      value: '${(hp.progress * 100).round()}%')),
            ],
          ),
          const SizedBox(height: 14),
          _AchievementRow(hp: hp),
        ],
      ),
    );
  }
}

class _HabitFocusList extends StatelessWidget {
  final List<Habit> habits;

  const _HabitFocusList({required this.habits});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: habits.map((habit) => HabitTile(habit: habit)).toList());
  }
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
        color:
            done ? AppColors.secondary.withValues(alpha: .08) : AppColors.card,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.green.withValues(alpha: .14)
                    : AppColors.primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textStrong,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${habit.category} - ${habit.frequency} - ${habit.reminderTime}',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: done ? 1 : .45,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: AppColors.card2,
                    valueColor: AlwaysStoppedAnimation(
                        done ? AppColors.green : AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () => context.read<HabitProvider>().toggle(habit),
              icon: Icon(done ? Icons.check_rounded : Icons.add_rounded),
              color: done ? AppColors.green : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsPreview extends StatelessWidget {
  final HabitProvider hp;

  const _AnalyticsPreview({required this.hp});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumSectionHeader(
            title: 'Smart preview',
            subtitle: 'Signals that make the app feel alive.',
            trailing: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              ),
              child: const Text('Open stats'),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth >= 720;
            final cards = [
              _InsightCard(
                icon: Icons.trending_up_rounded,
                title: 'Consistency score',
                value: '${(hp.progress * 100).round()}',
                body: 'Today performance',
              ),
              _InsightCard(
                icon: Icons.shield_rounded,
                title: 'Streak risk',
                value: hp.progress == 1 ? 'Low' : 'Active',
                body:
                    hp.progress == 1 ? 'Protected today' : 'Complete one more',
              ),
              _InsightCard(
                icon: Icons.emoji_events_rounded,
                title: 'Next milestone',
                value: '${(hp.bestStreak + 3).clamp(3, 999)}d',
                body: 'Your next badge target',
              ),
            ];
            if (wide) {
              return Row(children: [
                for (final card in cards)
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: card)),
              ]);
            }
            return Column(children: cards);
          }),
        ],
      ),
    );
  }
}

class _StarterTemplateStrip extends StatelessWidget {
  final Future<void> Function(HabitTemplate template) onPick;

  const _StarterTemplateStrip({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Starter templates',
            subtitle:
                'Use proven habits instead of starting from a blank page.',
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: starterHabitTemplates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final template = starterHabitTemplates[index];
                return SizedBox(
                  width: 230,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onPick(template),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: template.color.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: template.color.withValues(alpha: .24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(template.icon,
                              style: const TextStyle(fontSize: 28)),
                          const Spacer(),
                          Text(
                            template.title,
                            style: const TextStyle(
                                color: AppColors.textStrong,
                                fontWeight: FontWeight.w900),
                          ),
                          Text(template.benefit,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolGrid extends StatelessWidget {
  final bool wide;

  const _ToolGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolData(
          Icons.emoji_events_rounded,
          'Challenges',
          'Badges, streak quests, and milestone pressure.',
          const ChallengesScreen()),
      _ToolData(Icons.insights_rounded, 'Insights',
          'Recommendations and performance signals.', const InsightsScreen()),
      _ToolData(Icons.bar_chart_rounded, 'Statistics',
          'Charts, heatmaps, and weekly reports.', const StatisticsScreen()),
      _ToolData(
          Icons.add_task_rounded,
          'New Habit',
          'Create a precise habit with reminder rules.',
          const NewHabitScreen()),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionHeader(
          title: 'Power tools',
          subtitle:
              'The pieces that make Streakly feel like a serious product.',
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: wide ? 1.25 : 1.05,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            for (final tool in tools)
              AppCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => tool.page),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(tool.icon, color: AppColors.primary),
                    const Spacer(),
                    Text(tool.title,
                        style: const TextStyle(
                            color: AppColors.textStrong,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(tool.body,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ToolData {
  final IconData icon;
  final String title;
  final String body;
  final Widget page;

  const _ToolData(this.icon, this.title, this.body, this.page);
}

class _AchievementRow extends StatelessWidget {
  final HabitProvider hp;

  const _AchievementRow({required this.hp});

  @override
  Widget build(BuildContext context) {
    final badges = [
      (Icons.flag_rounded, 'Starter', hp.habits.isNotEmpty),
      (Icons.bolt_rounded, 'Perfect', hp.progress == 1 && hp.habits.isNotEmpty),
      (Icons.local_fire_department_rounded, 'Streak 7', hp.bestStreak >= 7),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final badge in badges)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: badge.$3
                  ? AppColors.primary.withValues(alpha: .10)
                  : AppColors.card2,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badge.$1,
                    size: 16,
                    color: badge.$3 ? AppColors.primary : AppColors.hint),
                const SizedBox(width: 5),
                Text(
                  badge.$2,
                  style: TextStyle(
                    color: badge.$3 ? AppColors.primary : AppColors.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String body;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          Text(body,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SmallMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _CommandPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CommandPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            child: Row(
              children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: AppColors.card2,
                        borderRadius: BorderRadius.circular(16))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 12,
                          width: 160,
                          decoration: BoxDecoration(
                              color: AppColors.card2,
                              borderRadius: BorderRadius.circular(999))),
                      const SizedBox(height: 10),
                      Container(
                          height: 10,
                          width: 230,
                          decoration: BoxDecoration(
                              color: AppColors.card2,
                              borderRadius: BorderRadius.circular(999))),
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

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: AppColors.danger))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

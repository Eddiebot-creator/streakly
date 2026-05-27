import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    final habits = context.read<HabitProvider>();
    Future.microtask(habits.load);
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final weekly = hp.weeklyCompleted();
    final completedDates =
        hp.habits.expand((habit) => habit.completedDates).toSet();
    final categories = _categoryTotals(hp);
    final velocity = _velocity(weekly);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            ResponsivePage(
              padding: EdgeInsets.zero,
              maxWidth: 1120,
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
                                  'Performance Lab',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your progress, made visible.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _summary(hp),
                                  style: const TextStyle(
                                      color: Colors.white70, height: 1.45),
                                ),
                              ],
                            ),
                          ),
                          if (wide)
                            const SizedBox(width: 22)
                          else
                            const SizedBox(height: 18),
                          ProgressRing(value: hp.progress, label: 'today'),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth >= 820;
                    final cards = [
                      _MetricCard('Today', '${(hp.progress * 100).round()}%',
                          Icons.today_rounded, AppColors.primary),
                      _MetricCard('Best streak', '${hp.bestStreak}',
                          Icons.workspace_premium_rounded, AppColors.accent),
                      _MetricCard('Completed', '${hp.totalCompleted}',
                          Icons.check_circle_rounded, AppColors.green),
                      _MetricCard('Velocity', velocity, Icons.speed_rounded,
                          AppColors.secondary),
                    ];
                    if (wide) {
                      return Row(
                        children: [
                          for (final card in cards)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: card,
                              ),
                            ),
                        ],
                      );
                    }
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: cards,
                    );
                  }),
                  const SizedBox(height: 18),
                  _ExecutiveSummary(hp: hp),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PremiumSectionHeader(
                          title: 'Last 7 Days',
                          subtitle:
                              'A Strava-style view of weekly completion volume.',
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                            height: 240, child: _WeeklyChart(values: weekly)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _YearHeatmap(completedDates: completedDates),
                  const SizedBox(height: 18),
                  LayoutBuilder(builder: (context, c) {
                    final wide = c.maxWidth >= 860;
                    final heatmap = AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PremiumSectionHeader(
                            title: 'Consistency Heatmap',
                            subtitle: 'Last 35 days with tap-level clarity.',
                          ),
                          const SizedBox(height: 16),
                          MiniHeatmap(completedDates: completedDates),
                        ],
                      ),
                    );
                    final category = _CategoryBreakdown(categories: categories);
                    if (!wide) {
                      return Column(children: [
                        heatmap,
                        const SizedBox(height: 18),
                        category,
                      ]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: heatmap),
                        const SizedBox(width: 18),
                        Expanded(child: category),
                      ],
                    );
                  }),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PremiumSectionHeader(
                          title: 'Smart Insight',
                          subtitle: 'What Streakly would tell you today.',
                        ),
                        const SizedBox(height: 10),
                        Text(_insight(hp),
                            style: const TextStyle(
                                color: AppColors.muted, height: 1.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _categoryTotals(HabitProvider hp) {
    final totals = <String, int>{};
    for (final habit in hp.habits) {
      totals[habit.category] =
          (totals[habit.category] ?? 0) + habit.completedDates.length;
    }
    return totals;
  }

  String _velocity(List<int> weekly) {
    if (weekly.length < 7) return '0%';
    final firstHalf = weekly.take(3).fold<int>(0, (sum, value) => sum + value);
    final secondHalf = weekly.skip(4).fold<int>(0, (sum, value) => sum + value);
    if (firstHalf == 0 && secondHalf == 0) return '0%';
    if (firstHalf == 0) return '+100%';
    final change = ((secondHalf - firstHalf) / firstHalf * 100).round();
    return change >= 0 ? '+$change%' : '$change%';
  }

  String _summary(HabitProvider hp) {
    if (hp.habits.isEmpty) {
      return 'Create a few habits and this page becomes your personal performance dashboard.';
    }
    return '${hp.completedToday} habits completed today, ${hp.totalCompleted} total completions, and a best streak of ${hp.bestStreak}.';
  }

  String _insight(HabitProvider hp) {
    if (hp.habits.isEmpty) {
      return 'Create habits to unlock personalized insights.';
    }
    if (hp.progress >= .8) {
      return 'Great momentum today. You are close to a perfect day.';
    }
    if (hp.completedToday == 0) {
      return 'Start with one easy habit now to protect your momentum.';
    }
    return 'You have completed ${hp.completedToday} habit(s). Finish the rest before your reminder time.';
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<int> values;

  const _WeeklyChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty
        ? 1.0
        : values
            .reduce((a, b) => a > b ? a : b)
            .toDouble()
            .clamp(1, 999)
            .toDouble();
    return BarChart(
      BarChartData(
        maxY: max + 1,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[index],
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          7,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index].toDouble(),
                width: 20,
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExecutiveSummary extends StatelessWidget {
  final HabitProvider hp;

  const _ExecutiveSummary({required this.hp});

  @override
  Widget build(BuildContext context) {
    final due = hp.dueTodayHabits.length;
    final completed = hp.completedToday;
    final skipped = (due - completed).clamp(0, 999);
    final frozen = hp.habits.fold<int>(
      0,
      (sum, habit) => sum + habit.freezeDates.length,
    );
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 780;
      final cards = [
        _SummaryTile(
          icon: Icons.flag_rounded,
          title: 'Due today',
          value: '$due',
          body: '$completed complete, $skipped open',
          color: AppColors.primary,
        ),
        _SummaryTile(
          icon: Icons.local_fire_department_rounded,
          title: 'Streak power',
          value: '${hp.totalStreak}',
          body: '${hp.bestStreak} best streak',
          color: AppColors.accent,
        ),
        _SummaryTile(
          icon: Icons.shield_rounded,
          title: 'Recovery used',
          value: '$frozen',
          body: 'Streak freeze days',
          color: AppColors.secondary,
        ),
      ];
      if (!wide) return Column(children: cards);
      return Row(
        children: [
          for (final card in cards)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: card,
              ),
            ),
        ],
      );
    });
  }
}

class _YearHeatmap extends StatelessWidget {
  final Set<String> completedDates;

  const _YearHeatmap({required this.completedDates});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Yearly Heatmap',
            subtitle: 'A GitHub-style view of the last 12 months.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(182, (index) {
              final date = today.subtract(Duration(days: 181 - index));
              final key = Habit.dateKey(date);
              final done = completedDates.contains(key);
              return Tooltip(
                message: '$key ${done ? 'completed' : 'open'}',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, int> categories;

  const _CategoryBreakdown({required this.categories});

  @override
  Widget build(BuildContext context) {
    final max = categories.values.isEmpty
        ? 1
        : categories.values.reduce((a, b) => a > b ? a : b);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Category Breakdown',
            subtitle: 'Where your effort is going.',
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            const Text('Complete habits to see category data.',
                style: TextStyle(color: AppColors.muted))
          else
            ...categories.entries.map((entry) {
              final value = entry.value / max;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(entry.key,
                              style: const TextStyle(
                                  color: AppColors.textStrong,
                                  fontWeight: FontWeight.w800)),
                        ),
                        Text('${entry.value}',
                            style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                      backgroundColor: AppColors.card2,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String body;
  final Color color;

  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(body,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}

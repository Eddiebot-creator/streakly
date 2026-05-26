import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

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
    final today = DateTime.now();
    final weekDates =
        List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: RefreshIndicator(
        onRefresh: hp.load,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            ResponsivePage(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth >= 850;
                final cards = [
                  _Stat(
                      'Today', '${(hp.progress * 100).round()}%', Icons.today),
                  _Stat('Best Streak', '${hp.bestStreak}',
                      Icons.workspace_premium),
                  _Stat(
                      'Completed', '${hp.totalCompleted}', Icons.check_circle),
                  _Stat('Habits', '${hp.habits.length}', Icons.list_alt),
                ];
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark]),
                        child: Row(children: [
                          SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                  value: hp.progress,
                                  strokeWidth: 16,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white))),
                          const SizedBox(width: 24),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                const Text('TODAY COMPLETION',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w800)),
                                Text('${(hp.progress * 100).round()}%',
                                    style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white)),
                                Text(
                                    '${hp.completedToday} of ${hp.habits.length} habits completed',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ])),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      const Text('Last 7 Days',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      AppCard(
                          child: SizedBox(
                              height: 240,
                              child: BarChart(BarChartData(
                                maxY: hp.habits.isEmpty
                                    ? 1
                                    : hp.habits.length.toDouble(),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final i = value.toInt();
                                            if (i < 0 ||
                                                i >= weekDates.length) {
                                              return const SizedBox.shrink();
                                            }
                                            const labels = [
                                              'M',
                                              'T',
                                              'W',
                                              'T',
                                              'F',
                                              'S',
                                              'S'
                                            ];
                                            return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Text(
                                                    labels[
                                                        weekDates[i].weekday -
                                                            1],
                                                    style: const TextStyle(
                                                        color: AppColors.muted,
                                                        fontSize: 12)));
                                          })),
                                ),
                                barGroups: List.generate(
                                    7,
                                    (i) => BarChartGroupData(x: i, barRods: [
                                          BarChartRodData(
                                              toY: weekly[i].toDouble(),
                                              width: 16,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: AppColors.primary)
                                        ])),
                              )))),
                      const SizedBox(height: 16),
                      GridView.count(
                          crossAxisCount: wide ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: wide ? 1.5 : 1.6,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: cards),
                      const SizedBox(height: 16),
                      AppCard(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Smart Insight',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 8),
                            Text(_insight(hp),
                                style: const TextStyle(color: AppColors.muted)),
                          ])),
                    ]);
              }),
            ),
          ],
        ),
      ),
    );
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

class _Stat extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _Stat(this.title, this.value, this.icon);
  @override
  Widget build(BuildContext context) => AppCard(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textStrong))
          ]));
}

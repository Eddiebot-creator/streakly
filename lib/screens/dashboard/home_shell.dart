import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../challenges/challenges_screen.dart';
import '../habits/my_habits_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';
import 'dashboard_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final pages = const [
    DashboardScreen(),
    MyHabitsScreen(),
    StatisticsScreen(),
    ChallengesScreen(),
    LeaderboardScreen(),
    SettingsScreen(),
  ];

  final items = const [
    (Icons.home_rounded, 'Home'),
    (Icons.check_circle_rounded, 'Habits'),
    (Icons.bar_chart_rounded, 'Stats'),
    (Icons.bolt_rounded, 'Challenge'),
    (Icons.emoji_events_rounded, 'Ranks'),
    (Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final desktop = c.maxWidth >= 900;
      if (desktop) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                backgroundColor: AppColors.card.withOpacity(.96),
                selectedIndex: index,
                onDestinationSelected: (v) => setState(() => index = v),
                extended: c.maxWidth >= 1120,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Image.asset('assets/icon/streakly_logo.png', width: 48, height: 48),
                ),
                destinations: [
                  for (final item in items) NavigationRailDestination(icon: Icon(item.$1), label: Text(item.$2)),
                ],
              ),
              Expanded(child: pages[index]),
            ],
          ),
        );
      }
      return Scaffold(
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
          destinations: [
            for (final item in items.take(5)) NavigationDestination(icon: Icon(item.$1), label: item.$2),
          ],
        ),
      );
    });
  }
}

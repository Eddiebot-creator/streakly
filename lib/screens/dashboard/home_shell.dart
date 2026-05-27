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
    _ShellItem(Icons.home_rounded, 'Today', 'Command center'),
    _ShellItem(Icons.check_circle_rounded, 'Habits', 'Your routines'),
    _ShellItem(Icons.bar_chart_rounded, 'Stats', 'Progress lab'),
    _ShellItem(Icons.bolt_rounded, 'Quests', 'Challenges'),
    _ShellItem(Icons.emoji_events_rounded, 'Ranks', 'Leaderboard'),
    _ShellItem(Icons.settings_rounded, 'Settings', 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final desktop = c.maxWidth >= 980;
      if (desktop) {
        return Scaffold(
          body: Row(
            children: [
              Container(
                width: c.maxWidth >= 1180 ? 248 : 92,
                margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                      child: Row(
                        mainAxisAlignment: c.maxWidth >= 1180
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/icon/streakly_logo.png',
                              width: 44, height: 44),
                          if (c.maxWidth >= 1180) ...[
                            const SizedBox(width: 10),
                            const Text(
                              'Streakly',
                              style: TextStyle(
                                color: AppColors.textStrong,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          for (var i = 0; i < items.length; i++)
                            _RailButton(
                              item: items[i],
                              selected: index == i,
                              extended: c.maxWidth >= 1180,
                              onTap: () => setState(() => index = i),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: pages[index]),
            ],
          ),
        );
      }
      return Scaffold(
        body: pages[index],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              backgroundColor: AppColors.surface,
              selectedIndex: index > 4 ? 4 : index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: [
                for (final item in items.take(5))
                  NavigationDestination(
                      icon: Icon(item.icon), label: item.label),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _RailButton extends StatelessWidget {
  final _ShellItem item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  const _RailButton({
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 14 : 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: .10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment:
                extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(item.icon,
                  color: selected ? AppColors.primary : AppColors.muted),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellItem {
  final IconData icon;
  final String label;
  final String subtitle;

  const _ShellItem(this.icon, this.label, this.subtitle);
}

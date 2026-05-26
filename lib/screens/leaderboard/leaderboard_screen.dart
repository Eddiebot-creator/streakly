import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });
      rows = await FirestoreService.instance.leaderboard();
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Streak Leaderboard')),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(padding: const EdgeInsets.all(22), children: [
            ResponsivePage(
                padding: EdgeInsets.zero,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark]),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ELITE RANKINGS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70)),
                              SizedBox(height: 8),
                              Text('STREAK\nLEADERBOARD',
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                      color: Colors.white)),
                            ]),
                      ),
                      const SizedBox(height: 20),
                      if (loading)
                        const Center(child: CircularProgressIndicator())
                      else if (error != null)
                        AppCard(
                            child: Text(error!,
                                style:
                                    const TextStyle(color: AppColors.danger)))
                      else if (rows.isEmpty)
                        const AppCard(
                            child: Text(
                                'No leaderboard data yet. Complete habits to appear here.',
                                style: TextStyle(color: AppColors.muted)))
                      else
                        ...List.generate(rows.length, (i) {
                          final r = rows[i];
                          final name =
                              (r['name'] ?? 'Streakly User').toString();
                          final completed = r['totalCompleted'] ?? 0;
                          final streak = r['totalStreak'] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                                child: Row(children: [
                              CircleAvatar(
                                backgroundColor: i == 0
                                    ? AppColors.accent
                                    : AppColors.primary,
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textStrong)),
                                    Text('$completed completed habits',
                                        style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12)),
                                  ])),
                              Text('$streak streak',
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w900)),
                            ])),
                          );
                        }),
                    ])),
          ]),
        ),
      );
}

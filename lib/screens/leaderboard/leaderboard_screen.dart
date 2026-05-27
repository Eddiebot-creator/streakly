import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  String? error;
  String mode = 'Weekly';

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
  Widget build(BuildContext context) {
    final sorted = [...rows]..sort((a, b) => _score(b).compareTo(_score(a)));
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final myRank = sorted.indexWhere((row) => row['id'] == userId) + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Leagues')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
          children: [
            ResponsivePage(
              padding: EdgeInsets.zero,
              maxWidth: 1080,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LeagueHero(
                    rows: sorted,
                    myRank: myRank,
                    mode: mode,
                    onMode: (value) => setState(() => mode = value),
                  ),
                  const SizedBox(height: 16),
                  if (loading)
                    const _LoadingBoard()
                  else if (error != null)
                    AppCard(
                      child: Text(error!,
                          style: const TextStyle(color: AppColors.danger)),
                    )
                  else if (sorted.isEmpty)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.emoji_events_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No league data yet',
                            style: TextStyle(
                              color: AppColors.textStrong,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Complete habits to appear here. This page is ready for friend leagues, weekly leagues, and private groups.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _Podium(rows: sorted.take(3).toList()),
                    const SizedBox(height: 16),
                    const PremiumSectionHeader(
                      title: 'Rankings',
                      subtitle:
                          'Social progress, streak pressure, and friendly competition.',
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(sorted.length, (i) {
                      return _LeaderboardRow(
                        row: sorted[i],
                        rank: i + 1,
                        score: _score(sorted[i]),
                        isMe: sorted[i]['id'] == userId,
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _score(Map<String, dynamic> row) {
    final completed = _asInt(row['totalCompleted']);
    final streak = _asInt(row['totalStreak']);
    return completed * 12 + streak * 30;
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}

class _LeagueHero extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final int myRank;
  final String mode;
  final ValueChanged<String> onMode;

  const _LeagueHero({
    required this.rows,
    required this.myRank,
    required this.mode,
    required this.onMode,
  });

  @override
  Widget build(BuildContext context) {
    final leader = rows.isEmpty ? null : rows.first;
    final leaderName = leader == null
        ? 'No leader yet'
        : (leader['name'] ?? 'Streakly User').toString();
    return AppCard(
      padding: const EdgeInsets.all(26),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak League',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Compete with momentum.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in const ['Weekly', 'Friends', 'Global'])
                ChoiceChip(
                  label: Text(item),
                  selected: mode == item,
                  onSelected: (_) => onMode(item),
                  selectedColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: .12),
                  labelStyle: TextStyle(
                    color: mode == item ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  side: BorderSide(color: Colors.white.withValues(alpha: .18)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(label: 'Leader: $leaderName'),
              _HeroPill(
                  label: myRank > 0
                      ? 'Your rank: #$myRank'
                      : 'Your rank: unlisted'),
              _HeroPill(label: '${rows.length} competitors'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const _Podium({required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            title: 'Podium',
            subtitle: 'Top performers by completions and streak pressure.',
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              final row = index < rows.length ? rows[index] : null;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _PodiumTile(row: row, rank: index + 1),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PodiumTile extends StatelessWidget {
  final Map<String, dynamic>? row;
  final int rank;

  const _PodiumTile({required this.row, required this.rank});

  @override
  Widget build(BuildContext context) {
    final height = rank == 1
        ? 138.0
        : rank == 2
            ? 112.0
            : 94.0;
    final name = row == null
        ? 'Open slot'
        : (row!['name'] ?? 'Streakly User').toString();
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rank == 1
            ? AppColors.accent.withValues(alpha: .14)
            : AppColors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rank == 1
              ? AppColors.accent.withValues(alpha: .28)
              : AppColors.divider,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: rank == 1 ? AppColors.accent : AppColors.primary,
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final Map<String, dynamic> row;
  final int rank;
  final int score;
  final bool isMe;

  const _LeaderboardRow({
    required this.row,
    required this.rank,
    required this.score,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final name = (row['name'] ?? 'Streakly User').toString();
    final completed = row['totalCompleted'] ?? 0;
    final streak = row['totalStreak'] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        color: isMe ? AppColors.primary.withValues(alpha: .08) : AppColors.card,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: rank == 1
                  ? AppColors.accent
                  : isMe
                      ? AppColors.secondary
                      : AppColors.primary,
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMe ? '$name (You)' : name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textStrong,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$completed completions - $streak streak points',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'XP',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBoard extends StatelessWidget {
  const _LoadingBoard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.card2),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 170,
                        decoration: BoxDecoration(
                          color: AppColors.card2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 10,
                        width: 240,
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

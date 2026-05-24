import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Streakly User';
    final email = user?.email ?? 'No email connected';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        ResponsivePage(padding: EdgeInsets.zero, child: Column(children: [
          AppCard(child: Row(children: [
            CircleAvatar(radius: 32, backgroundColor: AppColors.purple, child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), Text(email, style: const TextStyle(color: AppColors.muted))])),
          ])),
          const SizedBox(height: 18),
          _SettingTile(icon: Icons.notifications_active_outlined, title: 'Test Notification', subtitle: 'Send a real notification now', onTap: () async {
            await NotificationService.instance.show('Streakly reminder', 'This is how your habit reminders will appear.');
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent')));
          }),
          _SettingTile(icon: Icons.download_outlined, title: 'Export Data', subtitle: 'Copy your habits as CSV', onTap: () async {
            await context.read<HabitProvider>().exportCsvToClipboard();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard')));
          }),
          _SettingTile(icon: Icons.cloud_done_outlined, title: 'Cloud Backup', subtitle: 'Firebase sync is active for this account', onTap: () => _info(context, 'Cloud Backup', 'Your habits are saved in Firebase Firestore and sync when you sign in.')),
          _SettingTile(icon: Icons.dark_mode_outlined, title: 'Appearance', subtitle: 'Dark premium theme enabled', onTap: () => _info(context, 'Appearance', 'Streakly currently uses the premium dark responsive theme.')),
          _SettingTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', subtitle: 'View app privacy summary', onTap: () => _info(context, 'Privacy', 'Streakly stores only your email, habits, streaks, and progress data in Firebase.')),
          _SettingTile(icon: Icons.help_outline, title: 'Help Center', subtitle: 'How to use Streakly', onTap: () => _info(context, 'Help Center', 'Create a habit, complete it daily, track streaks, view stats, and export your data from settings.')),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async => context.read<StreaklyAuthProvider>().signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ])),
      ]),
    );
  }

  void _info(BuildContext context, String title, String body) {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(body), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppCard(onTap: onTap, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), child: Row(children: [
      Icon(icon, color: AppColors.yellow),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12))])),
      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
    ])),
  );
}

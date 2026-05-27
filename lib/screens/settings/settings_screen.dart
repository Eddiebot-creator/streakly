import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool smartReminders = true;
  bool haptics = true;
  bool reducedMotion = false;
  bool compactMode = false;
  bool analyticsOptIn = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      smartReminders = prefs.getBool('streakly_smart_reminders') ?? true;
      haptics = prefs.getBool('streakly_haptics') ?? true;
      reducedMotion = prefs.getBool('streakly_reduced_motion') ?? false;
      compactMode = prefs.getBool('streakly_compact_mode') ?? false;
      analyticsOptIn = prefs.getBool('streakly_analytics_opt_in') ?? false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name =
        user?.displayName ?? user?.email?.split('@').first ?? 'Streakly User';
    final email = user?.email ?? 'No email connected';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          ResponsivePage(
            padding: EdgeInsets.zero,
            maxWidth: 980,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            Text(email,
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _StatusPill(
                                  label: user?.emailVerified == true
                                      ? 'Email verified'
                                      : 'Email not verified',
                                  icon: user?.emailVerified == true
                                      ? Icons.verified_rounded
                                      : Icons.mark_email_unread_rounded,
                                ),
                                const _StatusPill(
                                  label: 'Cloud sync active',
                                  icon: Icons.cloud_done_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const PremiumSectionHeader(
                  title: 'Account',
                  subtitle: 'Profile, login, and identity controls.',
                ),
                const SizedBox(height: 10),
                _SettingTile(
                  icon: Icons.badge_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your display name',
                  onTap: () => _editProfile(context, name),
                ),
                _SettingTile(
                  icon: Icons.password_rounded,
                  title: 'Reset Password',
                  subtitle: 'Send a password reset email',
                  onTap: () => _resetPassword(context, email),
                ),
                _SettingTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Verify Email',
                  subtitle: user?.emailVerified == true
                      ? 'Your email is already verified'
                      : 'Send a verification email',
                  onTap: () => _verifyEmail(context),
                ),
                const SizedBox(height: 18),
                const PremiumSectionHeader(
                  title: 'Data & Trust',
                  subtitle: 'Export, privacy, cloud backup, and safety.',
                ),
                const SizedBox(height: 10),
                _SettingTile(
                  icon: Icons.download_outlined,
                  title: 'Export Data',
                  subtitle: 'Copy your habits as CSV',
                  onTap: () async {
                    await context.read<HabitProvider>().exportCsvToClipboard();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('CSV copied to clipboard')),
                      );
                    }
                  },
                ),
                _SettingTile(
                  icon: Icons.upload_file_rounded,
                  title: 'Import Data',
                  subtitle: 'CSV import surface ready for release packaging',
                  onTap: () => _info(
                    context,
                    'Import Data',
                    'CSV import is planned for the release build. Export is available today, and the settings surface is ready for the import workflow.',
                  ),
                ),
                _SettingTile(
                  icon: Icons.cloud_done_outlined,
                  title: 'Cloud Backup',
                  subtitle: 'Firebase sync is active for this account',
                  onTap: () => _info(
                    context,
                    'Cloud Backup',
                    'Your habits are saved in Firebase Firestore and sync when you sign in.',
                  ),
                ),
                _SettingTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Controls',
                  subtitle:
                      'Export, privacy summary, and delete-account access',
                  onTap: () => _privacySheet(context),
                ),
                const SizedBox(height: 18),
                const PremiumSectionHeader(
                  title: 'Experience',
                  subtitle: 'Notifications, onboarding, appearance, and help.',
                ),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    children: [
                      _PreferenceSwitch(
                        icon: Icons.notifications_active_outlined,
                        title: 'Smart reminders',
                        subtitle:
                            'Use habit timing signals for reminder suggestions.',
                        value: smartReminders,
                        onChanged: (value) {
                          setState(() => smartReminders = value);
                          _savePref('streakly_smart_reminders', value);
                        },
                      ),
                      _PreferenceSwitch(
                        icon: Icons.vibration_rounded,
                        title: 'Sound and haptics',
                        subtitle: 'Allow tactile feedback for completions.',
                        value: haptics,
                        onChanged: (value) {
                          setState(() => haptics = value);
                          _savePref('streakly_haptics', value);
                        },
                      ),
                      _PreferenceSwitch(
                        icon: Icons.motion_photos_off_outlined,
                        title: 'Reduced motion',
                        subtitle: 'Prefer calmer transitions and effects.',
                        value: reducedMotion,
                        onChanged: (value) {
                          setState(() => reducedMotion = value);
                          _savePref('streakly_reduced_motion', value);
                        },
                      ),
                      _PreferenceSwitch(
                        icon: Icons.view_agenda_outlined,
                        title: 'Compact mode',
                        subtitle:
                            'Save the preference for denser power-user layouts.',
                        value: compactMode,
                        onChanged: (value) {
                          setState(() => compactMode = value);
                          _savePref('streakly_compact_mode', value);
                        },
                      ),
                      _PreferenceSwitch(
                        icon: Icons.query_stats_rounded,
                        title: 'Product analytics opt-in',
                        subtitle: 'Let future releases measure feature health.',
                        value: analyticsOptIn,
                        onChanged: (value) {
                          setState(() => analyticsOptIn = value);
                          _savePref('streakly_analytics_opt_in', value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Test Notification',
                  subtitle: 'Send a real notification now',
                  onTap: () async {
                    await NotificationService.instance.show(
                      'Streakly reminder',
                      'This is how your habit reminders will appear.',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification sent')),
                      );
                    }
                  },
                ),
                _SettingTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Replay Onboarding',
                  subtitle: 'Show goal setup again on next launch',
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('streakly_onboarding_complete', false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Onboarding will show next time you open Streakly')),
                      );
                    }
                  },
                ),
                _SettingTile(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Light Streakly design enabled',
                  onTap: () => _info(
                    context,
                    'Appearance',
                    'Streakly is using the premium light design system. Dark mode and custom accent colors are ready for the next theme pass.',
                  ),
                ),
                _SettingTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'How to use Streakly',
                  onTap: () => _info(
                    context,
                    'Help Center',
                    'Create habits, complete them daily, track streaks, review stats, use challenges, and export your data from settings.',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger),
                  onPressed: () async =>
                      context.read<StreaklyAuthProvider>().signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await FirebaseAuth.instance.currentUser
                    ?.updateDisplayName(name);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context, String email) async {
    if (!email.contains('@')) {
      _info(context, 'Reset Password',
          'No email address is attached to this account.');
      return;
    }
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset sent to $email')),
      );
    }
  }

  Future<void> _verifyEmail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (user.emailVerified) {
      _info(context, 'Verify Email', 'Your email is already verified.');
      return;
    }
    await user.sendEmailVerification();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent')),
      );
    }
  }

  void _privacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Controls',
              style: TextStyle(
                color: AppColors.textStrong,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Streakly stores your email, habits, streaks, and completion dates in Firebase so your progress can sync.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<HabitProvider>().exportCsvToClipboard();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV copied to clipboard')),
                  );
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export my data'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _info(
                context,
                'Delete Account',
                'For safety, delete-account should require recent reauthentication before it is enabled in production.',
              ),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              label: const Text('Delete account request',
                  style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }

  void _info(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textStrong,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textStrong),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.muted),
            ],
          ),
        ),
      );
}

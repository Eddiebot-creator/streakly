import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/home_shell.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    runApp(StreaklyStartupError(error: error.toString()));
    return;
  }

  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Notifications should never prevent users from opening the app.
  }

  runApp(const StreaklyApp());
}

class StreaklyStartupError extends StatelessWidget {
  final String error;
  const StreaklyStartupError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Streakly',
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Streakly could not start',
                      style: TextStyle(
                        color: AppColors.textStrong,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Check your Firebase configuration, then restart the app.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      error,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StreaklyApp extends StatelessWidget {
  const StreaklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StreaklyAuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Streakly',
        theme: AppTheme.light,
        home: Consumer<StreaklyAuthProvider>(
          builder: (context, auth, _) {
            return auth.isSignedIn ? const HomeShell() : const LoginScreen();
          },
        ),
      ),
    );
  }
}

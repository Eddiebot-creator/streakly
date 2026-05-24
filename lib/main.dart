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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.init();

  runApp(const StreaklyApp());
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
        theme: AppTheme.dark,
        home: Consumer<StreaklyAuthProvider>(
          builder: (context, auth, _) {
            return auth.isSignedIn
                ? const HomeShell()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
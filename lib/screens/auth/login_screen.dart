import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool signUp = false;
  bool busy = false;
  String? error;

  Future<void> _submit() async {
    setState(() { busy = true; error = null; });
    final auth = context.read<StreaklyAuthProvider>();
    final result = signUp
        ? await auth.signUp(name.text, email.text, pass.text)
        : await auth.signIn(email.text, pass.text);
    if (!mounted) return;
    setState(() { busy = false; error = result; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF080B18), Color(0xFF1A1140), Color(0xFF080B18)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Padding(
                padding: EdgeInsets.all(wide ? 32 : 18),
                child: wide
                    ? Row(children: [Expanded(child: _HeroPanel()), const SizedBox(width: 26), Expanded(child: _FormCard())])
                    : ListView(children: [_HeroPanel(compact: true), const SizedBox(height: 18), _FormCard()]),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _HeroPanel({bool compact = false}) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 22 : 34),
      gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset('assets/icon/streakly_logo.png', height: compact ? 92 : 135)),
          SizedBox(height: compact ? 16 : 28),
          const Text('Build streaks\nthat actually last.', style: TextStyle(fontSize: 38, height: 1, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('Track habits, complete daily goals, keep your momentum, and view real progress from Firebase.', style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 22),
          Wrap(spacing: 10, runSpacing: 10, children: const [
            _Pill('🔥 Streaks'), _Pill('📊 Analytics'), _Pill('⏰ Reminders'), _Pill('🏆 Leaderboard'),
          ]),
        ],
      ),
    );
  }

  Widget _FormCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      color: AppColors.bg2.withOpacity(.92),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(signUp ? 'Create account' : 'Welcome back', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(signUp ? 'Start your first streak today.' : 'Sign in to continue your streak.', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 22),
          if (signUp) ...[
            TextField(controller: name, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
          ],
          TextField(controller: email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined))),
          const SizedBox(height: 12),
          TextField(controller: pass, obscureText: true, onSubmitted: (_) => _submit(), decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: busy ? null : _submit,
            child: busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(signUp ? 'Create Account' : 'Sign In'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() { signUp = !signUp; error = null; }),
            child: Text(signUp ? 'Already have an account? Sign in' : 'New here? Create account'),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(99)),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}

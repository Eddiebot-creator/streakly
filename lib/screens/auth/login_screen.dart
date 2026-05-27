import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/streakly_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  late final AnimationController entrance;
  late final Animation<double> fade;
  late final Animation<Offset> slide;
  bool signUp = false;
  bool busy = false;
  bool obscurePassword = true;
  String? error;
  String? notice;

  @override
  void initState() {
    super.initState();
    entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    fade = CurvedAnimation(parent: entrance, curve: Curves.easeOutCubic);
    slide = Tween(begin: const Offset(0, .06), end: Offset.zero).animate(
      CurvedAnimation(parent: entrance, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      busy = true;
      error = null;
      notice = null;
    });
    final auth = context.read<StreaklyAuthProvider>();
    final result = signUp
        ? await auth.signUp(name.text, email.text, pass.text)
        : await auth.signIn(email.text, pass.text);
    if (!mounted) return;
    setState(() {
      busy = false;
      error = result;
    });
  }

  Future<void> _resetPassword() async {
    final address = email.text.trim();
    if (address.isEmpty || !address.contains('@')) {
      setState(() {
        error = 'Enter your email first, then tap forgot password.';
        notice = null;
      });
      return;
    }
    setState(() {
      busy = true;
      error = null;
      notice = null;
    });
    final result =
        await context.read<StreaklyAuthProvider>().sendPasswordReset(address);
    if (!mounted) return;
    setState(() {
      busy = false;
      error = result;
      notice = result == null ? 'Password reset sent to $address.' : null;
    });
  }

  @override
  void dispose() {
    entrance.dispose();
    name.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 920;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8FAFC),
                Color(0xFFEFF6FF),
                Color(0xFFEDE9FE),
                Color(0xFFF8FAFC),
              ],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -120,
                right: -80,
                child: _GlowOrb(size: 280, color: AppColors.primary),
              ),
              const Positioned(
                bottom: -140,
                left: -80,
                child: _GlowOrb(size: 300, color: AppColors.secondary),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(wide ? 34 : 18),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: FadeTransition(
                        opacity: fade,
                        child: SlideTransition(
                          position: slide,
                          child: wide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(flex: 11, child: _heroPanel()),
                                    const SizedBox(width: 28),
                                    Expanded(flex: 9, child: _formCard()),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _heroPanel(compact: true),
                                    const SizedBox(height: 18),
                                    _formCard(),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _heroPanel({bool compact = false}) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 22 : 34),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -44,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  StreaklyLogo(size: compact ? 58 : 70),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streakly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Habit OS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: compact ? 22 : 42),
              Text(
                signUp
                    ? 'Design a routine that can survive real life.'
                    : 'Pick up exactly where your streak left off.',
                style: TextStyle(
                  fontSize: compact ? 32 : 46,
                  height: .98,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Offline-first habits, smart coaching, recovery tools, heatmaps, leagues, and premium progress tracking in one calm dashboard.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Pill(
                      icon: Icons.local_fire_department_rounded,
                      text: 'Streak recovery'),
                  _Pill(icon: Icons.insights_rounded, text: 'Smart coach'),
                  _Pill(
                      icon: Icons.offline_bolt_rounded, text: 'Offline ready'),
                  _Pill(icon: Icons.emoji_events_rounded, text: 'Leagues'),
                ],
              ),
              const SizedBox(height: 28),
              _PreviewStrip(compact: compact),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Form(
      key: formKey,
      child: AppCard(
        padding: const EdgeInsets.all(26),
        color: AppColors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModeSwitch(
              signUp: signUp,
              onChanged: (value) => setState(() {
                signUp = value;
                error = null;
                notice = null;
                obscurePassword = true;
              }),
            ),
            const SizedBox(height: 22),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Column(
                key: ValueKey(signUp),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signUp ? 'Create your account' : 'Welcome back',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textStrong,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    signUp
                        ? 'Start with a focused setup, then build momentum.'
                        : 'Sign in to continue your habits, insights, and league progress.',
                    style: const TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: signUp
                  ? Column(
                      children: [
                        TextFormField(
                          controller: name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (!signUp) return null;
                            final input = value?.trim() ?? '';
                            if (input.length < 2) return 'Enter your name';
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                final input = value?.trim() ?? '';
                if (input.isEmpty) return 'Enter your email address';
                if (!input.contains('@') || !input.contains('.')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pass,
              obscureText: obscurePassword,
              onFieldSubmitted: (_) => _submit(),
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                final input = value ?? '';
                if (input.isEmpty) return 'Enter your password';
                if (input.length < 6) return 'Use at least 6 characters';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                  icon: Icon(obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
            ),
            if (!signUp) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: busy ? null : _resetPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: error != null
                  ? _MessageBanner(
                      key: const ValueKey('error'),
                      message: error!,
                      icon: Icons.error_outline_rounded,
                      color: AppColors.danger,
                    )
                  : notice != null
                      ? _MessageBanner(
                          key: const ValueKey('notice'),
                          message: notice!,
                          icon: Icons.mark_email_read_outlined,
                          color: AppColors.green,
                        )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: busy ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: busy
                    ? const SizedBox(
                        key: ValueKey('busy'),
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        signUp ? 'Create Account' : 'Sign In',
                        key: ValueKey(signUp),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    signUp ? 'secure signup' : 'secure login',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: const [
                _TrustChip(icon: Icons.lock_rounded, text: 'Firebase Auth'),
                _TrustChip(icon: Icons.cloud_done_rounded, text: 'Cloud sync'),
                _TrustChip(icon: Icons.shield_rounded, text: 'Private data'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final bool signUp;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({required this.signUp, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Sign in',
              selected: !signUp,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Create',
              selected: signUp,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.muted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewStrip extends StatelessWidget {
  final bool compact;

  const _PreviewStrip({required this.compact});

  @override
  Widget build(BuildContext context) {
    if (compact) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: Row(
        children: const [
          Expanded(
            child: _PreviewMetric(
              label: 'Today',
              value: '84%',
              icon: Icons.check_circle_rounded,
            ),
          ),
          _PreviewDivider(),
          Expanded(
            child: _PreviewMetric(
              label: 'Best',
              value: '21d',
              icon: Icons.local_fire_department_rounded,
            ),
          ),
          _PreviewDivider(),
          Expanded(
            child: _PreviewMetric(
              label: 'Coach',
              value: 'Low risk',
              icon: Icons.psychology_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PreviewMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _PreviewDivider extends StatelessWidget {
  const _PreviewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: .20),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _MessageBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}

class _TrustChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: .16),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/habit_templates.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final selectedGoals = <String>{'Health', 'Focus'};
  final selectedTemplates = <String>{
    'Drink water',
    'Morning walk',
    'Plan tomorrow',
  };
  bool busy = false;

  void toggleGoal(String goal) {
    setState(() {
      if (selectedGoals.contains(goal)) {
        selectedGoals.remove(goal);
      } else {
        selectedGoals.add(goal);
      }
    });
  }

  void toggleTemplate(String title) {
    setState(() {
      if (selectedTemplates.contains(title)) {
        selectedTemplates.remove(title);
      } else {
        selectedTemplates.add(title);
      }
    });
  }

  Future<void> _finish() async {
    setState(() => busy = true);
    final habits = context.read<HabitProvider>();
    try {
      final existingTitles =
          habits.habits.map((habit) => habit.title.toLowerCase()).toSet();
      for (final template in starterHabitTemplates) {
        final selected = selectedTemplates.contains(template.title);
        final exists = existingTitles.contains(template.title.toLowerCase());
        if (selected && !exists) {
          await habits.addHabit(
            template.title,
            template.category,
            template.icon,
            template.frequency,
            template.reminder,
          );
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('streakly_onboarding_complete', true);
      if (mounted) widget.onFinished();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not finish setup: $error')),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streakly_onboarding_complete', true);
    if (mounted) widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bg, Color(0xFFE0E7FF), AppColors.bg],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _OnboardingHero()),
                            const SizedBox(width: 24),
                            Expanded(child: _SetupPanel(state: this)),
                          ],
                        )
                      : Column(
                          children: [
                            const _OnboardingHero(compact: true),
                            const SizedBox(height: 18),
                            _SetupPanel(state: this),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  final bool compact;

  const _OnboardingHero({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 24 : 34),
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
              Image.asset('assets/icon/streakly_logo.png', width: 58),
              const SizedBox(width: 14),
              const Text(
                'Streakly',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 28 : 54),
          const Text(
            'Build a routine that feels designed for your life.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Choose your focus, start with proven habits, and land on a dashboard that tells you exactly what to do today.',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _HeroPill(icon: Icons.bolt_rounded, label: 'Fast setup'),
              _HeroPill(icon: Icons.insights_rounded, label: 'Smart insights'),
              _HeroPill(icon: Icons.verified_rounded, label: 'Streak-ready'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupPanel extends StatelessWidget {
  final _OnboardingScreenState state;

  const _SetupPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personalize your start',
            style: TextStyle(
              color: AppColors.textStrong,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick your focus areas and starter habits. You can edit everything later.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          const Text(
            'Focus areas',
            style: TextStyle(
              color: AppColors.textStrong,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final goal in goalTracks)
                ChoiceChip(
                  selected: state.selectedGoals.contains(goal.$1),
                  avatar: Icon(goal.$2, size: 18, color: goal.$3),
                  label: Text(goal.$1),
                  onSelected: (_) {
                    state.toggleGoal(goal.$1);
                  },
                ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Starter habits',
            style: TextStyle(
              color: AppColors.textStrong,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...starterHabitTemplates.map(
            (template) => _TemplateRow(template: template, state: state),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              TextButton(
                  onPressed: state.busy ? null : state._skip,
                  child: const Text('Skip for now')),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: state.busy ? null : state._finish,
                icon: state.busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label:
                    Text(state.busy ? 'Setting up...' : 'Build my dashboard'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  final HabitTemplate template;
  final _OnboardingScreenState state;

  const _TemplateRow({required this.template, required this.state});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedTemplates.contains(template.title);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => state.toggleTemplate(template.title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: .08)
                : AppColors.card2,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: template.color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    Text(template.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: const TextStyle(
                        color: AppColors.textStrong,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      template.benefit,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

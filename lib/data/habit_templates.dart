import 'package:flutter/material.dart';

class HabitTemplate {
  final String title;
  final String category;
  final String icon;
  final String frequency;
  final String reminder;
  final String benefit;
  final Color color;

  const HabitTemplate({
    required this.title,
    required this.category,
    required this.icon,
    required this.frequency,
    required this.reminder,
    required this.benefit,
    required this.color,
  });
}

const starterHabitTemplates = [
  HabitTemplate(
    title: 'Drink water',
    category: 'Health',
    icon: '💧',
    frequency: 'Daily',
    reminder: '08:00',
    benefit: 'Start the day hydrated and clear.',
    color: Color(0xFF0EA5E9),
  ),
  HabitTemplate(
    title: 'Morning walk',
    category: 'Fitness',
    icon: '🚶',
    frequency: 'Daily',
    reminder: '07:00',
    benefit: 'Build energy before work begins.',
    color: Color(0xFF22C55E),
  ),
  HabitTemplate(
    title: 'Read 10 pages',
    category: 'Study',
    icon: '📚',
    frequency: 'Daily',
    reminder: '20:30',
    benefit: 'Compound learning in small steps.',
    color: Color(0xFF8B5CF6),
  ),
  HabitTemplate(
    title: 'Plan tomorrow',
    category: 'Work',
    icon: '📝',
    frequency: 'Daily',
    reminder: '21:00',
    benefit: 'End the day with a clear next move.',
    color: Color(0xFFF59E0B),
  ),
  HabitTemplate(
    title: 'Mindful breathing',
    category: 'Mindset',
    icon: '🧘',
    frequency: 'Daily',
    reminder: '12:00',
    benefit: 'Reset stress before it piles up.',
    color: Color(0xFF14B8A6),
  ),
  HabitTemplate(
    title: 'Track spending',
    category: 'Finance',
    icon: '💰',
    frequency: 'Daily',
    reminder: '19:30',
    benefit: 'Keep money decisions visible.',
    color: Color(0xFF10B981),
  ),
];

const goalTracks = [
  ('Health', Icons.favorite_rounded, Color(0xFF22C55E)),
  ('Focus', Icons.psychology_rounded, Color(0xFF4F46E5)),
  ('Fitness', Icons.directions_run_rounded, Color(0xFFEF4444)),
  ('Learning', Icons.menu_book_rounded, Color(0xFF8B5CF6)),
  ('Money', Icons.savings_rounded, Color(0xFFF59E0B)),
  ('Balance', Icons.self_improvement_rounded, Color(0xFF14B8A6)),
];

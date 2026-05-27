import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/premium_ui.dart';

class NewHabitScreen extends StatefulWidget {
  final Habit? habit;
  const NewHabitScreen({super.key, this.habit});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  final title = TextEditingController();
  final notes = TextEditingController();
  final tags = TextEditingController();
  final location = TextEditingController();
  String category = 'Health';
  String icon = '🔥';
  String frequency = 'Daily';
  String difficulty = 'Easy';
  String priority = 'Medium';
  String goalType = 'Check-off';
  int quantityTarget = 1;
  int timerMinutes = 0;
  int everyXDays = 2;
  int monthlyDay = 1;
  final customWeekdays = <int>{1, 2, 3, 4, 5};
  TimeOfDay reminder = const TimeOfDay(hour: 8, minute: 0);
  bool paused = false;
  bool busy = false;

  final categories = const [
    'Health',
    'Fitness',
    'Study',
    'Work',
    'Mindset',
    'Finance',
    'Personal',
    'Social',
  ];
  final icons = const [
    '🔥',
    '🏃',
    '📚',
    '💧',
    '🧘',
    '💰',
    '🎯',
    '🛌',
    '💪',
    '📝'
  ];
  final frequencies = const [
    'Daily',
    'Weekdays',
    'Weekends',
    '3x Weekly',
    'Custom days',
    'Every X days',
    'Monthly',
  ];
  final difficulties = const ['Easy', 'Medium', 'Hard'];
  final priorities = const ['Low', 'Medium', 'High'];
  final goalTypes = const [
    'Check-off',
    'Quantity',
    'Timer',
    'Checklist',
    'Quit bad habit',
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    if (h != null) {
      title.text = h.title;
      notes.text = h.notes;
      tags.text = h.tags.join(', ');
      location.text = h.locationLabel;
      category = h.category;
      icon = h.icon;
      frequency = h.frequency;
      difficulty = h.difficulty;
      priority = h.priority;
      goalType = h.goalType;
      quantityTarget = h.quantityTarget;
      timerMinutes = h.timerMinutes;
      everyXDays = h.everyXDays;
      monthlyDay = h.monthlyDay;
      paused = h.paused;
      customWeekdays
        ..clear()
        ..addAll(h.customWeekdays.isEmpty ? [1, 2, 3, 4, 5] : h.customWeekdays);
      reminder = _parseTime(h.reminderTime) ?? reminder;
    }
  }

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    tags.dispose();
    location.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1].replaceAll(RegExp('[^0-9]'), ''));
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _timeString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter habit title')),
      );
      return;
    }
    setState(() => busy = true);
    final hp = context.read<HabitProvider>();
    final parsedTags = tags.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    try {
      if (widget.habit == null) {
        await hp.addHabit(
          title.text,
          category,
          icon,
          frequency,
          _timeString(reminder),
          customWeekdays: customWeekdays.toList()..sort(),
          everyXDays: everyXDays,
          monthlyDay: monthlyDay,
          difficulty: difficulty,
          priority: priority,
          notes: notes.text,
          goalType: goalType,
          quantityTarget: quantityTarget,
          timerMinutes: timerMinutes,
          tags: parsedTags,
          locationLabel: location.text,
        );
      } else {
        await hp.updateHabit(widget.habit!.copyWith(
          title: title.text.trim(),
          category: category,
          icon: icon,
          frequency: frequency,
          reminderTime: _timeString(reminder),
          customWeekdays: customWeekdays.toList()..sort(),
          everyXDays: everyXDays,
          monthlyDay: monthlyDay,
          paused: paused,
          difficulty: difficulty,
          priority: priority,
          notes: notes.text.trim(),
          goalType: goalType,
          quantityTarget: quantityTarget,
          timerMinutes: timerMinutes,
          tags: parsedTags,
          locationLabel: location.text.trim(),
        ));
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(widget.habit == null ? 'Habit saved' : 'Habit updated')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.habit == null ? 'New Habit' : 'Edit Habit')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          ResponsivePage(
            maxWidth: 880,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Design a habit that can survive real life.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Schedule, goal type, priority, notes, tags, timer and recovery are all part of the routine.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PremiumSectionHeader(
                          title: 'Identity',
                          subtitle: 'Make the habit recognizable at a glance.'),
                      const SizedBox(height: 14),
                      TextField(
                        controller: title,
                        decoration: const InputDecoration(
                          labelText: 'Habit name',
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: icons
                            .map(
                              (e) => ChoiceChip(
                                label: Text(e,
                                    style: const TextStyle(fontSize: 20)),
                                selected: icon == e,
                                onSelected: (_) => setState(() => icon = e),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField(
                        initialValue: category,
                        items: categories
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => category = v!),
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PremiumSectionHeader(
                          title: 'Schedule',
                          subtitle: 'Flexible rules for real routines.'),
                      const SizedBox(height: 14),
                      DropdownButtonFormField(
                        initialValue: frequency,
                        items: frequencies
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => frequency = v!),
                        decoration:
                            const InputDecoration(labelText: 'Frequency'),
                      ),
                      if (frequency == 'Custom days') ...[
                        const SizedBox(height: 12),
                        _WeekdayPicker(
                          selected: customWeekdays,
                          onChanged: () => setState(() {}),
                        ),
                      ],
                      if (frequency == 'Every X days') ...[
                        const SizedBox(height: 12),
                        _StepperRow(
                          label: 'Repeat every',
                          value: everyXDays,
                          suffix: 'days',
                          onMinus: () => setState(
                              () => everyXDays = (everyXDays - 1).clamp(1, 30)),
                          onPlus: () => setState(
                              () => everyXDays = (everyXDays + 1).clamp(1, 30)),
                        ),
                      ],
                      if (frequency == 'Monthly') ...[
                        const SizedBox(height: 12),
                        _StepperRow(
                          label: 'Monthly day',
                          value: monthlyDay,
                          suffix: '',
                          onMinus: () => setState(
                              () => monthlyDay = (monthlyDay - 1).clamp(1, 28)),
                          onPlus: () => setState(
                              () => monthlyDay = (monthlyDay + 1).clamp(1, 28)),
                        ),
                      ],
                      const SizedBox(height: 12),
                      AppCard(
                        color: AppColors.card2,
                        onTap: () async {
                          final t = await showTimePicker(
                              context: context, initialTime: reminder);
                          if (t != null) setState(() => reminder = t);
                        },
                        child: Row(children: [
                          const Icon(Icons.alarm, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Reminder: ${_timeString(reminder)}',
                              style:
                                  const TextStyle(color: AppColors.textStrong),
                            ),
                          ),
                          const Icon(Icons.edit,
                              size: 18, color: AppColors.muted),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PremiumSectionHeader(
                          title: 'Power Settings',
                          subtitle:
                              'Priority, difficulty, goal mode, notes, and tags.'),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            initialValue: difficulty,
                            items: difficulties
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => difficulty = v!),
                            decoration:
                                const InputDecoration(labelText: 'Difficulty'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField(
                            initialValue: priority,
                            items: priorities
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => priority = v!),
                            decoration:
                                const InputDecoration(labelText: 'Priority'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      DropdownButtonFormField(
                        initialValue: goalType,
                        items: goalTypes
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => goalType = v!),
                        decoration:
                            const InputDecoration(labelText: 'Goal type'),
                      ),
                      if (goalType == 'Quantity') ...[
                        const SizedBox(height: 12),
                        _StepperRow(
                          label: 'Quantity target',
                          value: quantityTarget,
                          suffix: 'units',
                          onMinus: () => setState(() => quantityTarget =
                              (quantityTarget - 1).clamp(1, 999)),
                          onPlus: () => setState(() => quantityTarget =
                              (quantityTarget + 1).clamp(1, 999)),
                        ),
                      ],
                      if (goalType == 'Timer') ...[
                        const SizedBox(height: 12),
                        _StepperRow(
                          label: 'Timer target',
                          value: timerMinutes,
                          suffix: 'min',
                          onMinus: () => setState(() =>
                              timerMinutes = (timerMinutes - 5).clamp(0, 240)),
                          onPlus: () => setState(() =>
                              timerMinutes = (timerMinutes + 5).clamp(0, 240)),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: notes,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Notes / journal prompt',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tags,
                        decoration: const InputDecoration(
                          labelText: 'Tags, comma separated',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: location,
                        decoration: const InputDecoration(
                          labelText: 'Location cue (optional)',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      if (widget.habit != null) ...[
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: paused,
                          onChanged: (value) => setState(() => paused = value),
                          title: const Text('Pause / vacation mode'),
                          subtitle: const Text(
                              'Keep this habit but remove it from today'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: busy ? null : _save,
                  child: busy
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.habit == null ? 'Save Habit' : 'Update Habit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  final Set<int> selected;
  final VoidCallback onChanged;

  const _WeekdayPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(
                label: Text(labels[i]),
                selected: selected.contains(i + 1),
                onSelected: (_) {
                  if (selected.contains(i + 1)) {
                    selected.remove(i + 1);
                  } else {
                    selected.add(i + 1);
                  }
                  onChanged();
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.suffix,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textStrong,
                      fontWeight: FontWeight.w800))),
          IconButton(
              onPressed: onMinus, icon: const Icon(Icons.remove_rounded)),
          Text('$value $suffix',
              style: const TextStyle(
                  color: AppColors.textStrong, fontWeight: FontWeight.w900)),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add_rounded)),
        ],
      ),
    );
  }
}

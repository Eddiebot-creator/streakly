import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class NewHabitScreen extends StatefulWidget {
  final Habit? habit;
  const NewHabitScreen({super.key, this.habit});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  final title = TextEditingController();
  String category = 'Health';
  String icon = '🔥';
  String frequency = 'Daily';
  TimeOfDay reminder = const TimeOfDay(hour: 8, minute: 0);
  bool busy = false;

  final categories = const ['Health', 'Fitness', 'Study', 'Work', 'Mindset', 'Finance', 'Personal'];
  final icons = const ['🔥', '🏃', '📚', '💧', '🧘', '💰', '🎯', '🛌', '💪', '📝'];
  final frequencies = const ['Daily', 'Weekdays', 'Weekends', '3x Weekly'];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    if (h != null) {
      title.text = h.title;
      category = h.category;
      icon = h.icon;
      frequency = h.frequency;
      reminder = _parseTime(h.reminderTime) ?? reminder;
    }
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1].replaceAll(RegExp('[^0-9]'), ''));
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _timeString(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter habit title')));
      return;
    }
    setState(() => busy = true);
    final hp = context.read<HabitProvider>();
    try {
      if (widget.habit == null) {
        await hp.addHabit(title.text, category, icon, frequency, _timeString(reminder));
      } else {
        await hp.updateHabit(widget.habit!.copyWith(
          title: title.text.trim(),
          category: category,
          icon: icon,
          frequency: frequency,
          reminderTime: _timeString(reminder),
        ));
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.habit == null ? 'Habit saved' : 'Habit updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.habit == null ? 'New Habit' : 'Edit Habit')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: title, decoration: const InputDecoration(labelText: 'Habit name', prefixIcon: Icon(Icons.edit_outlined))),
                    const SizedBox(height: 18),
                    const Text('Choose icon', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 10, runSpacing: 10, children: icons.map((e) => ChoiceChip(label: Text(e, style: const TextStyle(fontSize: 20)), selected: icon == e, onSelected: (_) => setState(() => icon = e))).toList()),
                    const SizedBox(height: 18),
                    DropdownButtonFormField(value: category, items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v!), decoration: const InputDecoration(labelText: 'Category')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField(value: frequency, items: frequencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => frequency = v!), decoration: const InputDecoration(labelText: 'Frequency')),
                    const SizedBox(height: 12),
                    AppCard(
                      color: AppColors.card2,
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: reminder);
                        if (t != null) setState(() => reminder = t);
                      },
                      child: Row(children: [const Icon(Icons.alarm, color: AppColors.yellow), const SizedBox(width: 12), Expanded(child: Text('Reminder: ${_timeString(reminder)}')), const Icon(Icons.edit, size: 18)]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: busy ? null : _save, child: busy ? const CircularProgressIndicator() : Text(widget.habit == null ? 'Save Habit' : 'Update Habit')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

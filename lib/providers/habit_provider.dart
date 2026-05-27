import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';
import '../services/firestore_service.dart';

class HabitProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService.instance;

  List<Habit> habits = [];
  bool loading = false;
  bool offlineMode = false;
  String? error;

  String get _cacheKey {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'streakly_habits_cache_$uid';
  }

  Future<void> load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      habits = [];
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();
    await _loadCache();

    try {
      habits = await _service.getHabits(uid);
      offlineMode = false;
      await _saveCache();
    } catch (e) {
      offlineMode = true;
      error = 'Offline mode: showing saved habits until sync returns.';
      debugPrint(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(
    String title,
    String category,
    String icon,
    String frequency,
    String reminder, {
    List<int> customWeekdays = const [],
    int everyXDays = 1,
    int monthlyDay = 1,
    String difficulty = 'Easy',
    String priority = 'Medium',
    String notes = '',
    String goalType = 'Check-off',
    int quantityTarget = 1,
    int timerMinutes = 0,
    List<String> tags = const [],
    String locationLabel = '',
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('You are not logged in.');
    if (title.trim().isEmpty) throw Exception('Habit title cannot be empty.');

    final habit = Habit(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      userId: uid,
      title: title.trim(),
      category: category,
      icon: icon,
      frequency: frequency,
      reminderTime: reminder,
      customWeekdays: customWeekdays,
      everyXDays: everyXDays,
      monthlyDay: monthlyDay,
      difficulty: difficulty,
      priority: priority,
      notes: notes.trim(),
      goalType: goalType,
      quantityTarget: quantityTarget,
      timerMinutes: timerMinutes,
      tags: tags,
      locationLabel: locationLabel.trim(),
      createdAt: DateTime.now(),
    );

    habits = [habit, ...habits];
    await _saveCache();
    notifyListeners();

    try {
      await _service.addHabit(habit.copyWith(id: ''));
      await load();
    } catch (e) {
      offlineMode = true;
      error = 'Saved locally. It will sync when the connection returns.';
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await _saveCache();
      notifyListeners();
    }
    try {
      if (!habit.id.startsWith('local_')) {
        await _service.updateHabit(habit);
      }
      await load();
    } catch (e) {
      offlineMode = true;
      error = 'Updated locally. It will sync when the connection returns.';
      notifyListeners();
    }
  }

  Future<void> deleteHabit(Habit habit) async {
    habits.removeWhere((h) => h.id == habit.id);
    await _saveCache();
    notifyListeners();
    try {
      if (!habit.id.startsWith('local_')) {
        await _service.deleteHabit(habit);
      }
    } catch (e) {
      offlineMode = true;
      error = 'Deleted locally. Cloud sync will catch up later.';
      notifyListeners();
    }
  }

  Future<void> toggle(Habit habit) async {
    final updated = _toggleLocal(habit);
    _replaceLocal(updated);
    await _saveCache();
    notifyListeners();
    try {
      if (!habit.id.startsWith('local_')) {
        await _service.toggleHabit(habit);
      }
      await load();
    } catch (e) {
      offlineMode = true;
      error = 'Completion saved locally. It will sync later.';
      notifyListeners();
    }
  }

  Future<void> pauseHabit(Habit habit, bool paused) async {
    await updateHabit(habit.copyWith(paused: paused));
  }

  Future<void> archiveHabit(Habit habit) async {
    await updateHabit(habit.copyWith(archived: true));
  }

  Future<void> duplicateHabit(Habit habit) async {
    await addHabit(
      '${habit.title} copy',
      habit.category,
      habit.icon,
      habit.frequency,
      habit.reminderTime,
      customWeekdays: habit.customWeekdays,
      everyXDays: habit.everyXDays,
      monthlyDay: habit.monthlyDay,
      difficulty: habit.difficulty,
      priority: habit.priority,
      notes: habit.notes,
      goalType: habit.goalType,
      quantityTarget: habit.quantityTarget,
      timerMinutes: habit.timerMinutes,
      tags: habit.tags,
      locationLabel: habit.locationLabel,
    );
  }

  Future<void> useStreakFreeze(Habit habit) async {
    if (habit.streakFreezes <= 0) return;
    final today = Habit.dateKey(DateTime.now());
    if (habit.freezeDates.contains(today)) return;
    await updateHabit(habit.copyWith(
      streakFreezes: habit.streakFreezes - 1,
      freezeDates: [...habit.freezeDates, today],
    ));
  }

  Future<void> addReflection(Habit habit, String note) async {
    if (note.trim().isEmpty) return;
    await updateHabit(
      habit.copyWith(reflectionNotes: [...habit.reflectionNotes, note.trim()]),
    );
  }

  Future<void> exportCsvToClipboard() async {
    final csv = StringBuffer(
        'Title,Category,Icon,Schedule,Reminder,Difficulty,Priority,Goal Type,Quantity Target,Timer Minutes,Current Streak,Best Streak,Total Completed,Tags,Notes\n');
    for (final h in habits) {
      csv.writeln(h.toCsvRow());
    }
    await Clipboard.setData(ClipboardData(text: csv.toString()));
  }

  List<Habit> get activeHabits =>
      habits.where((h) => !h.archived && !h.paused).toList();
  List<Habit> get dueTodayHabits =>
      habits.where((h) => h.isDueToday && !h.archived).toList();
  List<Habit> get archivedHabits => habits.where((h) => h.archived).toList();
  int get completedToday => dueTodayHabits.where((h) => h.doneToday()).length;
  int get totalStreak => activeHabits.fold(0, (sum, h) => sum + h.streak);
  int get bestStreak =>
      activeHabits.fold(0, (sum, h) => h.bestStreak > sum ? h.bestStreak : sum);
  int get totalCompleted =>
      habits.fold(0, (sum, h) => sum + h.completedDates.length);
  double get progress =>
      dueTodayHabits.isEmpty ? 0 : completedToday / dueTodayHabits.length;

  List<int> weeklyCompleted() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final key = Habit.dateKey(date);
      return activeHabits.where((h) => h.completedDates.contains(key)).length;
    });
  }

  Habit _toggleLocal(Habit habit) {
    final today = Habit.dateKey(DateTime.now());
    final completed = [...habit.completedDates];
    var streak = habit.streak;
    if (completed.contains(today)) {
      completed.remove(today);
      streak = streak > 0 ? streak - 1 : 0;
    } else {
      completed.add(today);
      streak += 1;
    }
    return habit.copyWith(
      completedDates: completed,
      streak: streak,
      bestStreak: streak > habit.bestStreak ? streak : habit.bestStreak,
    );
  }

  void _replaceLocal(Habit habit) {
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) return;
    habits[index] = habit;
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    habits = decoded
        .map((item) => Habit.fromMap(
              item['id']?.toString() ?? '',
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
    notifyListeners();
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = habits.map((habit) => {'id': habit.id, ...habit.toCacheMap()});
    await prefs.setString(_cacheKey, jsonEncode(data.toList()));
  }
}

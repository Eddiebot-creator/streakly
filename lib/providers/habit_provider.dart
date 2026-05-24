import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/habit.dart';
import '../services/firestore_service.dart';

class HabitProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService.instance;

  List<Habit> habits = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        habits = [];
        notifyListeners();
        return;
      }
      loading = true;
      error = null;
      notifyListeners();
      habits = await _service.getHabits(uid);
    } catch (e) {
      error = e.toString();
      debugPrint(error);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(String title, String category, String icon, String frequency, String reminder) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('You are not logged in.');
      if (title.trim().isEmpty) throw Exception('Habit title cannot be empty.');
      await _service.addHabit(Habit(
        id: '',
        userId: uid,
        title: title.trim(),
        category: category,
        icon: icon,
        frequency: frequency,
        reminderTime: reminder,
        createdAt: DateTime.now(),
      ));
      await load();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _service.updateHabit(habit);
      await load();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteHabit(Habit habit) async {
    try {
      await _service.deleteHabit(habit);
      habits.removeWhere((h) => h.id == habit.id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggle(Habit habit) async {
    try {
      await _service.toggleHabit(habit);
      await load();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> exportCsvToClipboard() async {
    final csv = StringBuffer('Title,Category,Icon,Frequency,Reminder,Current Streak,Best Streak,Total Completed\n');
    for (final h in habits) {
      csv.writeln(h.toCsvRow());
    }
    await Clipboard.setData(ClipboardData(text: csv.toString()));
  }

  int get completedToday => habits.where((h) => h.doneToday()).length;
  int get totalStreak => habits.fold(0, (sum, h) => sum + h.streak);
  int get bestStreak => habits.fold(0, (sum, h) => h.bestStreak > sum ? h.bestStreak : sum);
  int get totalCompleted => habits.fold(0, (sum, h) => sum + h.completedDates.length);
  double get progress => habits.isEmpty ? 0 : completedToday / habits.length;

  List<int> weeklyCompleted() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final key = Habit.dateKey(date);
      return habits.where((h) => h.completedDates.contains(key)).length;
    });
  }
}

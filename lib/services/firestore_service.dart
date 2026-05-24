import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/habit.dart';

class FirestoreService {
  static final instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore db = FirebaseFirestore.instance;

  String get todayKey => Habit.dateKey(DateTime.now());

  Future<void> createUser(User user, String name) async {
    await db.collection('users').doc(user.uid).set({
      'name': name.trim().isEmpty ? 'Streakly User' : name.trim(),
      'email': user.email,
      'photoUrl': user.photoURL,
      'totalStreak': 0,
      'totalCompleted': 0,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Habit>> getHabits(String uid) async {
    final snap = await db.collection('habits').where('userId', isEqualTo: uid).get();
    final habits = snap.docs.map(Habit.fromDoc).toList();
    habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return habits;
  }

  Future<void> addHabit(Habit habit) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('You must be logged in to save a habit.');
    await db.collection('habits').add({
      ...habit.toMap(),
      'userId': uid,
      'streak': 0,
      'bestStreak': 0,
      'completedDates': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateHabit(Habit habit) async {
    if (habit.id.isEmpty) throw Exception('Cannot update habit without ID.');
    await db.collection('habits').doc(habit.id).update({
      'title': habit.title,
      'category': habit.category,
      'icon': habit.icon,
      'frequency': habit.frequency,
      'reminderTime': habit.reminderTime,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteHabit(Habit habit) async {
    if (habit.id.isEmpty) return;
    await db.collection('habits').doc(habit.id).delete();
  }

  Future<void> toggleHabit(Habit habit) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('You must be logged in.');

    final completed = [...habit.completedDates];
    var streak = habit.streak;
    final wasCompleted = completed.contains(todayKey);

    if (wasCompleted) {
      completed.remove(todayKey);
      streak = streak > 0 ? streak - 1 : 0;
    } else {
      completed.add(todayKey);
      streak += 1;
    }

    final bestStreak = streak > habit.bestStreak ? streak : habit.bestStreak;

    await db.collection('habits').doc(habit.id).update({
      'completedDates': completed,
      'streak': streak,
      'bestStreak': bestStreak,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await db.collection('users').doc(uid).set({
      'totalStreak': FieldValue.increment(wasCompleted ? -1 : 1),
      'totalCompleted': FieldValue.increment(wasCompleted ? -1 : 1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> leaderboard() async {
    final snap = await db.collection('users').orderBy('totalCompleted', descending: true).limit(20).get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}

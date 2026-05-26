import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String icon;
  final String frequency;
  final String reminderTime;
  final int streak;
  final int bestStreak;
  final List<String> completedDates;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.icon,
    required this.frequency,
    required this.reminderTime,
    this.streak = 0,
    this.bestStreak = 0,
    this.completedDates = const [],
    required this.createdAt,
  });

  bool doneToday() => completedDates.contains(dateKey(DateTime.now()));

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? icon,
    String? frequency,
    String? reminderTime,
    int? streak,
    int? bestStreak,
    List<String>? completedDates,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Habit.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Habit(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      category: d['category'] ?? 'Health',
      icon: d['icon'] ?? '🔥',
      frequency: d['frequency'] ?? 'Daily',
      reminderTime: d['reminderTime'] ?? '08:00 AM',
      streak: (d['streak'] ?? 0) as int,
      bestStreak: (d['bestStreak'] ?? 0) as int,
      completedDates: List<String>.from(d['completedDates'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'category': category,
        'icon': icon,
        'frequency': frequency,
        'reminderTime': reminderTime,
        'streak': streak,
        'bestStreak': bestStreak,
        'completedDates': completedDates,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  String toCsvRow() {
    String esc(String v) => '"${v.replaceAll('"', '""')}"';
    return [
      title,
      category,
      icon,
      frequency,
      reminderTime,
      streak.toString(),
      bestStreak.toString(),
      completedDates.length.toString()
    ].map(esc).join(',');
  }
}

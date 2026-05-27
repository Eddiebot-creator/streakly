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
  final List<int> customWeekdays;
  final int everyXDays;
  final int monthlyDay;
  final bool paused;
  final bool archived;
  final String difficulty;
  final String priority;
  final String notes;
  final String goalType;
  final int quantityTarget;
  final int timerMinutes;
  final List<String> tags;
  final int streakFreezes;
  final List<String> freezeDates;
  final List<String> reflectionNotes;
  final String proofPhotoUrl;
  final String voiceNoteUrl;
  final String locationLabel;

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
    this.customWeekdays = const [],
    this.everyXDays = 1,
    this.monthlyDay = 1,
    this.paused = false,
    this.archived = false,
    this.difficulty = 'Easy',
    this.priority = 'Medium',
    this.notes = '',
    this.goalType = 'Check-off',
    this.quantityTarget = 1,
    this.timerMinutes = 0,
    this.tags = const [],
    this.streakFreezes = 1,
    this.freezeDates = const [],
    this.reflectionNotes = const [],
    this.proofPhotoUrl = '',
    this.voiceNoteUrl = '',
    this.locationLabel = '',
  });

  bool doneToday() => completedDates.contains(dateKey(DateTime.now()));

  bool get isActive => !paused && !archived;

  bool get isDueToday {
    final now = DateTime.now();
    if (!isActive) return false;
    if (frequency == 'Weekdays') return now.weekday <= 5;
    if (frequency == 'Weekends') return now.weekday >= 6;
    if (frequency == 'Custom days') return customWeekdays.contains(now.weekday);
    if (frequency == 'Every X days') {
      final daysSinceStart = now.difference(createdAt).inDays;
      return daysSinceStart % everyXDays.clamp(1, 365) == 0;
    }
    if (frequency == 'Monthly') return now.day == monthlyDay;
    return true;
  }

  String get scheduleLabel {
    if (paused) return 'Paused';
    if (frequency == 'Custom days' && customWeekdays.isNotEmpty) {
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return customWeekdays.map((day) => labels[day - 1]).join(', ');
    }
    if (frequency == 'Every X days') return 'Every $everyXDays days';
    if (frequency == 'Monthly') return 'Monthly on day $monthlyDay';
    return frequency;
  }

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
    List<int>? customWeekdays,
    int? everyXDays,
    int? monthlyDay,
    bool? paused,
    bool? archived,
    String? difficulty,
    String? priority,
    String? notes,
    String? goalType,
    int? quantityTarget,
    int? timerMinutes,
    List<String>? tags,
    int? streakFreezes,
    List<String>? freezeDates,
    List<String>? reflectionNotes,
    String? proofPhotoUrl,
    String? voiceNoteUrl,
    String? locationLabel,
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
      customWeekdays: customWeekdays ?? this.customWeekdays,
      everyXDays: everyXDays ?? this.everyXDays,
      monthlyDay: monthlyDay ?? this.monthlyDay,
      paused: paused ?? this.paused,
      archived: archived ?? this.archived,
      difficulty: difficulty ?? this.difficulty,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      goalType: goalType ?? this.goalType,
      quantityTarget: quantityTarget ?? this.quantityTarget,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      tags: tags ?? this.tags,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      freezeDates: freezeDates ?? this.freezeDates,
      reflectionNotes: reflectionNotes ?? this.reflectionNotes,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      locationLabel: locationLabel ?? this.locationLabel,
    );
  }

  factory Habit.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Habit.fromMap(doc.id, doc.data() ?? {});
  }

  factory Habit.fromMap(String id, Map<String, dynamic> d) {
    final created = d['createdAt'];
    int asInt(Object? value, int fallback) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse((value ?? '').toString()) ?? fallback;
    }

    List<int> asIntList(Object? value) {
      if (value is! Iterable) return const [];
      return value
          .map((item) => asInt(item, 0))
          .where((item) => item > 0)
          .toList();
    }

    return Habit(
      id: id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      category: d['category'] ?? 'Health',
      icon: d['icon'] ?? '🔥',
      frequency: d['frequency'] ?? 'Daily',
      reminderTime: d['reminderTime'] ?? '08:00',
      streak: asInt(d['streak'], 0),
      bestStreak: asInt(d['bestStreak'], 0),
      completedDates: List<String>.from(d['completedDates'] ?? []),
      createdAt: created is Timestamp
          ? created.toDate()
          : DateTime.tryParse((created ?? '').toString()) ?? DateTime.now(),
      customWeekdays: asIntList(d['customWeekdays']),
      everyXDays: asInt(d['everyXDays'], 1),
      monthlyDay: asInt(d['monthlyDay'], 1),
      paused: d['paused'] == true,
      archived: d['archived'] == true,
      difficulty: d['difficulty'] ?? 'Easy',
      priority: d['priority'] ?? 'Medium',
      notes: d['notes'] ?? '',
      goalType: d['goalType'] ?? 'Check-off',
      quantityTarget: asInt(d['quantityTarget'], 1),
      timerMinutes: asInt(d['timerMinutes'], 0),
      tags: List<String>.from(d['tags'] ?? []),
      streakFreezes: asInt(d['streakFreezes'], 1),
      freezeDates: List<String>.from(d['freezeDates'] ?? []),
      reflectionNotes: List<String>.from(d['reflectionNotes'] ?? []),
      proofPhotoUrl: d['proofPhotoUrl'] ?? '',
      voiceNoteUrl: d['voiceNoteUrl'] ?? '',
      locationLabel: d['locationLabel'] ?? '',
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
        'customWeekdays': customWeekdays,
        'everyXDays': everyXDays,
        'monthlyDay': monthlyDay,
        'paused': paused,
        'archived': archived,
        'difficulty': difficulty,
        'priority': priority,
        'notes': notes,
        'goalType': goalType,
        'quantityTarget': quantityTarget,
        'timerMinutes': timerMinutes,
        'tags': tags,
        'streakFreezes': streakFreezes,
        'freezeDates': freezeDates,
        'reflectionNotes': reflectionNotes,
        'proofPhotoUrl': proofPhotoUrl,
        'voiceNoteUrl': voiceNoteUrl,
        'locationLabel': locationLabel,
      };

  Map<String, dynamic> toCacheMap() => {
        ...toMap(),
        'createdAt': createdAt.toIso8601String(),
      };

  String toCsvRow() {
    String esc(String v) => '"${v.replaceAll('"', '""')}"';
    return [
      title,
      category,
      icon,
      scheduleLabel,
      reminderTime,
      difficulty,
      priority,
      goalType,
      quantityTarget.toString(),
      timerMinutes.toString(),
      streak.toString(),
      bestStreak.toString(),
      completedDates.length.toString(),
      tags.join('|'),
      notes,
    ].map(esc).join(',');
  }
}

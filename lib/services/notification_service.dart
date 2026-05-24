import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings);
  }

  Future<void> show(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'streakly',
        'Streakly Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await plugin.show(1, title, body, details);
  }
}

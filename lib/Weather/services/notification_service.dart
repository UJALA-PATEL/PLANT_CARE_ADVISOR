import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 🔹 Initialize Notifications
  static void initNotifications() {
    tz.initializeTimeZones(); // Required for scheduling

    var androidSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSettings = const DarwinInitializationSettings();
    var settings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    _notificationsPlugin.initialize(settings);
  }

  // 🔹 Show Instant Notification for Weather Alert
  static Future<void> showInstantNotification(
      String plantName, String weather) async {
    var androidDetails = const AndroidNotificationDetails(
      "weather_alert",
      "Weather Alerts",
      importance: Importance.high,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // Unique ID
      "🌦️ Weather Alert for $plantName",
      "Current weather: $weather.\nPlan watering accordingly!",
      notificationDetails,
    );
  }

  // 🔹 Scheduled Watering Reminder
  static Future<void> scheduleNotification(String plantName, int days) async {
    await _notificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch % 100000, // Unique ID
      "Water Reminder",
      "Time to water $plantName! 💦",
      tz.TZDateTime.now(tz.local).add(Duration(days: days)), // Convert to TZDateTime
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'watering_channel',
          'Watering Reminders',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time, // Ensures it triggers at the right time
    );
  }

  // 🔥 NEW: Schedule Growth Reminder
  static Future<void> scheduleGrowthReminder(String plantName) async {
    await _notificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch % 100000, // Unique ID
      "🌱 Growth Check!",
      "It's time to check $plantName’s growth progress!",
      tz.TZDateTime.now(tz.local).add(const Duration(days: 30)), // 30 days later
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'growth_channel',
          'Growth Reminders',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 🔥 NEW: Cancel Notification (When Plant is Deleted)
  static Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
  }

}

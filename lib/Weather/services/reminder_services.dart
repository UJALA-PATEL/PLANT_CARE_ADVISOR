import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  ReminderService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);

    PermissionStatus status = await Permission.notification.status;
    if (status.isDenied) await Permission.notification.request();
    if (status.isPermanentlyDenied) await openAppSettings();
  }

  Future<void> addReminder(String title, DateTime dateTime, String repeatType) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentReference docRef = await _firestore.collection("reminders").add({
        "title": title,
        "dateTime": Timestamp.fromDate(dateTime),
        "repeatType": repeatType,
        "userID": user.uid,
      });

      _scheduleNotification(title, dateTime, docRef.id, repeatType);
    } catch (e) {
      print("Error adding reminder: $e");
    }
  }

  Future<void> _scheduleNotification(String title, DateTime dateTime, String docId, String repeatType) async {
    tz.TZDateTime scheduledTime = tz.TZDateTime.from(dateTime, tz.local);

    DateTimeComponents? repeatInterval;
    if (repeatType == "Daily") {
      repeatInterval = DateTimeComponents.time;
    } else if (repeatType == "Weekly") {
      repeatInterval = DateTimeComponents.dayOfWeekAndTime;
    } else if (repeatType == "Monthly") {
      repeatInterval = DateTimeComponents.dayOfMonthAndTime;
    }

    await _notificationsPlugin.zonedSchedule(
      docId.hashCode,
      "Plant Reminder",
      title,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeatInterval,
    );
  }

  Future<void> deleteReminder(String docId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection("reminders").doc(docId).delete();
      await _notificationsPlugin.cancel(docId.hashCode);
    } catch (e) {
      print("Error deleting reminder: $e");
    }
  }

  Stream<QuerySnapshot> getUserReminders() {
    User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("reminders")
        .where("userID", isEqualTo: user.uid)
        .snapshots();
  }
}

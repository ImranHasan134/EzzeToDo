import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// 🔴 FIX: Hide your custom 'Priority' enum so it doesn't collide with the notification package's 'Priority'
import '../models/task.dart' hide Priority;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Note: Make sure you have your app icon set up at android/app/src/main/res/mipmap/ic_launcher.png
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleTaskNotifications(Task task) async {
    // Cancel existing notifications for this task first
    await cancelTaskNotifications(task.id);

    // Don't schedule notifications if it has no deadline or is already done
    if (task.deadline == null || task.status == TaskStatus.completed) return;

    final deadline = task.deadline!;
    final now = DateTime.now();

    // Calculate the notification times
    final sixHoursBefore = deadline.subtract(const Duration(hours: 6));
    final threeHoursBefore = deadline.subtract(const Duration(hours: 3));
    final oneHourBefore = deadline.subtract(const Duration(hours: 1));

    // Schedule 6 Hours Before
    if (sixHoursBefore.isAfter(now)) {
      await _schedule(task.id.hashCode + 1, 'Task Due Soon', '${task.title} is due in 6 hours!', sixHoursBefore);
    }
    // Schedule 3 Hours Before
    if (threeHoursBefore.isAfter(now)) {
      await _schedule(task.id.hashCode + 2, 'Task Due Soon', '${task.title} is due in 3 hours!', threeHoursBefore);
    }
    // Schedule 1 Hour Before
    if (oneHourBefore.isAfter(now)) {
      await _schedule(task.id.hashCode + 3, 'Urgent Task', '${task.title} is due in 1 hour!', oneHourBefore);
    }
  }

  Future<void> _schedule(int id, String title, String body, DateTime time) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_alerts',
          'Task Alerts',
          channelDescription: 'Notifications for upcoming task deadlines',
          importance: Importance.max,
          priority: Priority.high, // Now safely refers to the notification package's Priority
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    await _notificationsPlugin.cancel(taskId.hashCode + 1);
    await _notificationsPlugin.cancel(taskId.hashCode + 2);
    await _notificationsPlugin.cancel(taskId.hashCode + 3);
  }
}
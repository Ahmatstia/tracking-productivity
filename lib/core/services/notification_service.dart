import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezones
    tz.initializeTimeZones();

    // flutter_timezone v5 returns TimezoneInfo; .identifier is the IANA TZ string
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    _requestPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // v21: initialize() uses named parameter 'settings:'
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleTimeBlockNotification(TimeBlockModel block) async {
    final parts = block.startTime.split(':');
    if (parts.length != 2) return;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      block.date.year,
      block.date.month,
      block.date.day,
      hour,
      minute,
    );
    scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));

    if (scheduledDate.isBefore(now)) return;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // v21: zonedSchedule() — NO uiLocalNotificationDateInterpretation param
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: block.id.hashCode,
      title: '🔔 Persiapan: ${block.title}',
      body: 'Aktivitasmu akan dimulai dalam 5 menit.',
      scheduledDate: tzScheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'life_os_planner_channel',
          'Planner Reminders',
          channelDescription: 'Notifications for your upcoming time blocks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(String blockId) async {
    // v21: cancel() uses named 'id:'
    await flutterLocalNotificationsPlugin.cancel(id: blockId.hashCode);
  }

  Future<void> rescheduleAllTodayNotifications(
      List<TimeBlockModel> blocks) async {
    final today = DateTime.now();
    final todayBlocks = blocks
        .where((b) =>
            b.date.year == today.year &&
            b.date.month == today.month &&
            b.date.day == today.day &&
            !b.isCompleted)
        .toList();

    for (final block in todayBlocks) {
      await scheduleTimeBlockNotification(block);
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

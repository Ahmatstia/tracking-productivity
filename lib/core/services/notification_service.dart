import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialise Timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    _requestPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle when notification is tapped
      },
    );
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Menjadwalkan notifikasi untuk TimeBlock
  Future<void> scheduleTimeBlockNotification(TimeBlockModel block) async {
    // Parser jam:menit
    final parts = block.startTime.split(':');
    if (parts.length != 2) return;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Waktu hari ini sesuai jam mulai
    final now = DateTime.now();
    var scheduledDate = DateTime(block.date.year, block.date.month, block.date.day, hour, minute);

    // Pengingat 5 menit sebelum
    scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));

    // Jika waktu sudah lewat, jangan dijadwalkan
    if (scheduledDate.isBefore(now)) return;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      block.id.hashCode, // Unique ID dari string hash
      '🔔 Persiapan: ${block.title}',
      'Aktivitasmu akan dimulai dalam 5 menit.',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'life_os_planner_channel',
          'Planner Reminders',
          channelDescription: 'Notifications for your upcoming time blocks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Bisa diulang tiap hari jika perlu, tapi kita buat per instance
    );
  }

  Future<void> cancelNotification(String blockId) async {
    await flutterLocalNotificationsPlugin.cancel(blockId.hashCode);
  }

  Future<void> rescheduleAllTodayNotifications(List<TimeBlockModel> blocks) async {
    final today = DateTime.now();
    final todayBlocks = blocks.where((b) =>
        b.date.year == today.year &&
        b.date.month == today.month &&
        b.date.day == today.day &&
        !b.isCompleted).toList();

    for (final block in todayBlocks) {
      await scheduleTimeBlockNotification(block);
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

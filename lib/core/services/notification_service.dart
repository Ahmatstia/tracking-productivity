import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';
import 'package:life_os_productivity/features/planner/domain/habit_pattern_model.dart';
import 'package:life_os_productivity/features/profile/domain/user_profile_model.dart';

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

  // --- Core Scheduling Logic ---

  Future<void> scheduleTimeBlockNotification(TimeBlockModel block, {UserProfileModel? settings}) async {
    // Check if master switch or specific planner switch is off
    if (settings != null) {
      if (!settings.notificationsEnabled || !settings.plannerReminders) {
        await cancelNotification(block.id);
        return;
      }
    }

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
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'life_os_planner_channel',
          'Pengingat Planner',
          channelDescription: 'Notifikasi untuk aktivitas jadwal harian Anda',
          importance: Importance.max,
          priority: Priority.high,
          playSound: settings?.soundsEnabled ?? true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleHabitReminder(HabitPatternModel habit, {UserProfileModel? settings}) async {
    // Check if master switch or specific habit switch is off
    if (settings != null) {
      if (!settings.notificationsEnabled || !settings.habitReminders || !habit.isActive) {
        await cancelNotification(habit.id);
        return;
      }
    }

    final parts = habit.startTime.split(':');
    if (parts.length != 2) return;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Schedule for today/tomorrow at exactly the habit time
    var scheduledDate = DateTime.now();
    scheduledDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: habit.id.hashCode,
      title: '✨ Waktunya: ${habit.title}',
      body: 'Jangan lupa selesaikan kebiasaan harianmu sekarang.',
      scheduledDate: tzScheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'life_os_habits_channel',
          'Saran Kebiasaan',
          channelDescription: 'Pengingat untuk pola hidup dan kebiasaan harian',
          importance: Importance.max,
          priority: Priority.high,
          playSound: settings?.soundsEnabled ?? true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelNotification(String blockId) async {
    // v21: cancel() uses named 'id:'
    await flutterLocalNotificationsPlugin.cancel(id: blockId.hashCode);
  }

  Future<void> rescheduleAllTodayNotifications({
    required List<TimeBlockModel> blocks,
    required List<HabitPatternModel> habits,
    required UserProfileModel settings,
  }) async {
    // 1. Cancel everything first to avoid duplicates
    await cancelAll();

    // If master switch off, we stop here
    if (!settings.notificationsEnabled) return;

    // 2. Reschedule Planner (if enabled)
    if (settings.plannerReminders) {
      final today = DateTime.now();
      final todayBlocks = blocks.where((b) =>
              b.date.year == today.year &&
              b.date.month == today.month &&
              b.date.day == today.day &&
              !b.isCompleted)
          .toList();

      for (final block in todayBlocks) {
        await scheduleTimeBlockNotification(block, settings: settings);
      }
    }

    // 3. Reschedule Habits (if enabled)
    if (settings.habitReminders) {
      for (final habit in habits) {
        if (habit.isActive) {
          await scheduleHabitReminder(habit, settings: settings);
        }
      }
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

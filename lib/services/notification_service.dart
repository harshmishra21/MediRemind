import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Function(String medicineId, String time)? onNotificationResponse;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final dynamic tzObj = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = tzObj is String ? tzObj : tzObj.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Failed to get local timezone: $e, falling back to UTC');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && onNotificationResponse != null) {
          final parts = response.payload!.split('|');
          if (parts.length >= 2) {
            onNotificationResponse!(parts[0], parts[1]);
          }
        }
      },
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return true;
  }

  Future<void> scheduleDosageReminder({
    required String medicineId,
    required String medicineName,
    required String strength,
    required String timeStr, // HH:mm
    required List<int> daysOfWeek, // 1 = Mon, 7 = Sun
    required String instructions,
  }) async {
    if (!_initialized) await init();

    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts[1]) ?? 0;

    const androidDetails = AndroidNotificationDetails(
      'mediremind_dosage_channel',
      'Medicine Dosage Reminders',
      channelDescription: 'Scheduled reminders to take prescribed medicines',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();

    for (final day in daysOfWeek) {
      final notificationId = _generateNotificationId(medicineId, timeStr, day);
      
      var scheduledDate = _nextInstanceOfDayAndTime(day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          title: 'Time to take $medicineName',
          body: '$strength • ${instructions.isNotEmpty ? instructions : "Dose scheduled at $timeStr"}',
          scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: '$medicineId|$timeStr',
        );
      } catch (e) {
        debugPrint('Error scheduling notification $notificationId: $e');
      }
    }
  }

  Future<void> cancelMedicineReminders(String medicineId) async {
    for (int day = 1; day <= 7; day++) {
      for (int h = 0; h < 24; h += 2) {
        final timeStr = '${h.toString().padLeft(2, '0')}:00';
        final id = _generateNotificationId(medicineId, timeStr, day);
        await _notificationsPlugin.cancel(id: id);
      }
    }
  }

  int _generateNotificationId(String medicineId, String timeStr, int dayOfWeek) {
    final raw = '$medicineId-$timeStr-$dayOfWeek';
    return raw.hashCode.abs() % 2147483647;
  }

  DateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != dayOfWeek || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'mediremind_instant_channel',
      'General Reminders',
      channelDescription: 'Instant alerts for refills and dosage actions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}

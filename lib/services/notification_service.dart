import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import '../models/schedule_model.dart';
import 'local_db_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'snooze') {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      // fallback
    }

    final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5));

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'class_reminders_snooze',
      'Pengingat Kelas (Ditunda)',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    await plugin.zonedSchedule(
      (notificationResponse.id ?? 0) + 9999,
      'Tunda: Persiapan Kuliah!',
      notificationResponse.payload ?? 'Waktunya bersiap-siap!',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      print('Could not set timezone: $e');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle foreground tap if needed
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
  }

  static Future<void> scheduleClassReminder(ScheduleModel schedule) async {
    if (schedule.day == null || schedule.time.isEmpty) return;

    final timeParts = schedule.time.split('-');
    if (timeParts.isEmpty) return;
    
    final startTimeString = timeParts[0].trim();
    final timeComponents = startTimeString.split(':');
    if (timeComponents.length != 2) return;

    final int hour = int.tryParse(timeComponents[0]) ?? 0;
    final int minute = int.tryParse(timeComponents[1]) ?? 0;
    final int dayOfWeek = _getDayOfWeek(schedule.day!);
    if (dayOfWeek == -1) return;

    // Baca pengaturan nada dari LocalDbService
    final String customSoundPath = LocalDbService.getData('alarmSoundPath') ?? '';
    
    AndroidNotificationSound? sound;
    if (customSoundPath.isNotEmpty && customSoundPath != 'default') {
      sound = UriAndroidNotificationSound('file://$customSoundPath');
    }

    final String channelId = 'class_reminders_${customSoundPath.hashCode}';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      'Pengingat Jadwal Kuliah',
      channelDescription: 'Notifikasi sebelum kuliah dimulai',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      sound: sound,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('dismiss', 'Matikan',
            cancelNotification: true, showsUserInterface: false),
        const AndroidNotificationAction('snooze', 'Tunda 5 Menit',
            cancelNotification: true, showsUserInterface: false),
      ],
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
    final String payload = 'Kuliah ${schedule.subject} di ${schedule.room} akan segera dimulai.';

    final offsets = [60, 45, 30, 15]; // 4 kali bunyi

    for (int offset in offsets) {
      tz.TZDateTime scheduledDate = _nextInstanceOfTime(dayOfWeek, hour, minute);
      scheduledDate = scheduledDate.subtract(Duration(minutes: offset));

      final int notificationId = schedule.id.hashCode + offset;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Persiapan Kuliah!',
        'Dalam $offset menit: $payload',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  static Future<void> cancelReminder(String id) async {
    final offsets = [60, 45, 30, 15];
    for (int offset in offsets) {
      await flutterLocalNotificationsPlugin.cancel(id.hashCode + offset);
    }
  }

  static int _getDayOfWeek(String day) {
    switch (day.toLowerCase()) {
      case 'senin': return DateTime.monday;
      case 'selasa': return DateTime.tuesday;
      case 'rabu': return DateTime.wednesday;
      case 'kamis': return DateTime.thursday;
      case 'jumat': return DateTime.friday;
      case 'sabtu': return DateTime.saturday;
      case 'minggu': return DateTime.sunday;
      default: return -1;
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int dayOfWeek, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

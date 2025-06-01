import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import '../models/user_profile.dart';
import 'astrology_api_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  // Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screens
    print('Notification tapped: ${response.payload}');
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'astrology_channel',
      'Astrology Notifications',
      channelDescription: 'Daily and weekly horoscope notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Schedule daily horoscope notification
  static Future<void> scheduleDailyHoroscope({
    required UserProfile profile,
    required int hour,
    required int minute,
  }) async {
    // Get user's zodiac sign
    final sunSign = await _getUserSunSign(profile);
    if (sunSign == null) return;

    // Cancel existing daily notification for this profile
    await _notifications.cancel(profile.id.hashCode);

    // Schedule new daily notification
    await _notifications.zonedSchedule(
      profile.id.hashCode, // Unique ID based on profile
      'Günlük Burç Yorumun Hazır! ✨',
      '${profile.name}, ${_getZodiacSignEmoji(sunSign)} $sunSign burcu için bugünün yorumunu gör!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_horoscope',
          'Günlük Burç Yorumu',
          channelDescription: 'Günlük burç yorumu bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'daily_horoscope_${profile.id}',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Schedule weekly horoscope notification
  static Future<void> scheduleWeeklyHoroscope({
    required UserProfile profile,
    required int weekday, // 1 = Monday, 7 = Sunday
    required int hour,
    required int minute,
  }) async {
    final sunSign = await _getUserSunSign(profile);
    if (sunSign == null) return;

    await _notifications.cancel(profile.id.hashCode + 1000); // Offset for weekly

    await _notifications.zonedSchedule(
      profile.id.hashCode + 1000,
      'Haftalık Burç Yorumun Hazır! 🌟',
      '${profile.name}, ${_getZodiacSignEmoji(sunSign)} $sunSign burcu için bu haftanın yorumunu keşfet!',
      _nextInstanceOfWeekly(weekday, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_horoscope',
          'Haftalık Burç Yorumu',
          channelDescription: 'Haftalık burç yorumu bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'weekly_horoscope_${profile.id}',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Schedule special celestial event notifications
  static Future<void> scheduleCelestialEvent({
    required String title,
    required String description,
    required DateTime eventTime,
    int? profileId,
  }) async {
    final id = profileId != null 
        ? profileId.hashCode + 2000 
        : eventTime.millisecondsSinceEpoch.hashCode;

    await _notifications.zonedSchedule(
      id,
      title,
      description,
      tz.TZDateTime.from(eventTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'celestial_events',
          'Göksel Olaylar',
          channelDescription: 'Önemli göksel olay bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'celestial_event',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel all notifications for a profile
  static Future<void> cancelProfileNotifications(String profileId) async {
    await _notifications.cancel(profileId.hashCode); // Daily
    await _notifications.cancel(profileId.hashCode + 1000); // Weekly
  }
  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Generic schedule notification method for testing
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'horoscope_channel',
          'Horoscope Notifications',
          channelDescription: 'Daily and weekly horoscope notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Generic cancel notification method for testing
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Get all pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Helper method to get user's sun sign
  static Future<String?> _getUserSunSign(UserProfile profile) async {
    try {
      // This would typically call your astrology API
      // For now, we'll use a simple zodiac calculation
      return _calculateZodiacSign(profile.birthDate);
    } catch (e) {
      print('Error getting sun sign: $e');
      return null;
    }
  }

  // Simple zodiac sign calculation based on birth date
  static String _calculateZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Koç';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Boğa';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'İkizler';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Yengeç';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Aslan';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Başak';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Terazi';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Akrep';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Yay';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Oğlak';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Kova';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Balık';
    
    return 'Koç'; // Fallback
  }

  // Get zodiac sign emoji
  static String _getZodiacSignEmoji(String sign) {
    switch (sign.toLowerCase()) {
      case 'koç': return '♈';
      case 'boğa': return '♉';
      case 'i̇kizler': return '♊';
      case 'yengeç': return '♋';
      case 'aslan': return '♌';
      case 'başak': return '♍';
      case 'terazi': return '♎';
      case 'akrep': return '♏';
      case 'yay': return '♐';
      case 'oğlak': return '♑';
      case 'kova': return '♒';
      case 'balık': return '♓';
      default: return '⭐';
    }
  }

  // Calculate next instance of daily time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, 
      now.year, 
      now.month, 
      now.day, 
      hour, 
      minute
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Calculate next instance of weekly time
  static tz.TZDateTime _nextInstanceOfWeekly(int weekday, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
  return scheduledDate;
  }
}

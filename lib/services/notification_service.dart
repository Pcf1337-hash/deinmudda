import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/service_interfaces.dart';

class NotificationService implements INotificationService {

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _reminderTimeKey = 'reminderTime';
  static const String _reminderDaysKey = 'reminderDays';

  // Initialize notification service
  @override
  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // This would typically navigate to a specific screen
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    // For iOS, permissions are requested during initialization
    // For Android 13+, we need to check if permissions are granted
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // For Android 13+ (API level 33), we need to check notification permission
      // For older versions, this will return true
      final bool? areNotificationsEnabled = await androidPlugin.areNotificationsEnabled();
      return areNotificationsEnabled ?? false;
    }
    
    return true; // Default to true for other platforms
  }

  // Schedule daily reminder
  Future<void> scheduleDailyReminder(TimeOfDay time, List<int> days) async {
    // Cancel existing reminders
    await cancelAllReminders();
    
    // Schedule new reminders for each selected day
    for (final day in days) {
      await _scheduleReminderForDay(day, time);
    }
    
    // Save reminder settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimeKey, '${time.hour}:${time.minute}');
    await prefs.setString(_reminderDaysKey, days.join(','));
  }

  // Schedule reminder for specific day of week
  Future<void> _scheduleReminderForDay(int day, TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    
    // Calculate next occurrence of the day
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // Adjust to next occurrence of the day
    while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Tägliche Erinnerungen',
      channelDescription: 'Kanal für tägliche Erinnerungen',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      day, // Use day as ID
      'Konsum Tracker Erinnerung',
      'Zeit für Ihren täglichen Eintrag!',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Show timer expired notification
  @override
  Future<void> showTimerExpiredNotification(String entryId, String substanceName) async {
    final notificationId = entryId.hashCode;
    
    await showNotification(
      id: notificationId,
      title: 'Timer abgelaufen',
      body: 'Die Wirkdauer von $substanceName ist vorüber.',
    );
  }

  // Schedule timer notification
  Future<void> scheduleTimerNotification({
    required String substanceName,
    required String entryId,
    required DateTime scheduledTime,
  }) async {
    final notificationId = entryId.hashCode;
    
    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_notifications',
      'Timer Benachrichtigungen',
      channelDescription: 'Benachrichtigungen für abgelaufene Substanz-Timer',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Timer abgelaufen',
      'Die Wirkdauer von $substanceName ist vorüber.',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel timer notification
  Future<void> cancelTimerNotification(String entryId) async {
    final notificationId = entryId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'general',
      'Allgemeine Benachrichtigungen',
      channelDescription: 'Kanal für allgemeine Benachrichtigungen',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  // Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    
    if (!enabled) {
      await cancelAllReminders();
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  // Get saved reminder time
  Future<TimeOfDay?> getSavedReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_reminderTimeKey);
    
    if (timeString == null) return null;
    
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    
    if (hour == null || minute == null) return null;
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Get saved reminder days
  Future<List<int>> getSavedReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    final daysString = prefs.getString(_reminderDaysKey);
    
    if (daysString == null || daysString.isEmpty) return [];
    
    return daysString
        .split(',')
        .map((day) => int.tryParse(day) ?? 0)
        .where((day) => day > 0 && day <= 7)
        .toList();
  }

  // Check if reminders are set
  Future<bool> areRemindersSet() async {
    final time = await getSavedReminderTime();
    final days = await getSavedReminderDays();
    
    return time != null && days.isNotEmpty;
  }

  // Get day name
  String getDayName(int day) {
    switch (day) {
      case 1: return 'Montag';
      case 2: return 'Dienstag';
      case 3: return 'Mittwoch';
      case 4: return 'Donnerstag';
      case 5: return 'Freitag';
      case 6: return 'Samstag';
      case 7: return 'Sonntag';
      default: return 'Unbekannt';
    }
  }

  // Format time
  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Interface-compliant methods for timer notifications

  /// Show timer notification (interface method)
  @override
  Future<void> showTimerNotification(String entryId, String substanceName, Duration remainingTime) async {
    final notificationId = entryId.hashCode;
    final remainingMinutes = remainingTime.inMinutes;
    
    await showNotification(
      id: notificationId,
      title: 'Timer aktiv: $substanceName',
      body: 'Noch $remainingMinutes Minuten verbleibend',
    );
  }

  /// Cancel notification for specific entry (interface method)
  @override
  Future<void> cancelNotification(String entryId) async {
    final notificationId = entryId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  /// Cancel all notifications (interface method)
  @override
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
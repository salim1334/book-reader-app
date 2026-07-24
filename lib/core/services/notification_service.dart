import 'dart:io';

import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Channel configuration for local notifications.
class _NotificationChannels {
  static const String newBooks = 'new_books_channel';
  static const String updates = 'updates_channel';
  static const String test = 'test_channel';
}

/// Central service for showing local "New Books" / "Updates" notifications.
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<NotificationService> init() async {
    if (_initialized) return this;

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    return this;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Requests notification permission (required on Android 13+ and iOS).
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;

      final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
      if (enabled) return true;

      final result =
          await androidPlugin.requestNotificationsPermission() ?? false;
      return result;
    }

    return true;
  }

  /// Shows a test notification so the user can verify the channel works.
  Future<void> showTestNotification() async {
    final allowed = await requestPermission();
    if (!allowed) {
      debugPrint('Notification permission not granted.');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _NotificationChannels.test,
      'Test Notifications',
      channelDescription: 'Used to verify local notifications are working.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      0,
      'Test Notification',
      'Your notifications are working!',
      details,
      payload: 'test',
    );
  }

  /// Shows a notification when a new book is added to the catalog.
  Future<void> showNewBookNotification(String bookTitle) async {
    if (!_shouldNotifyNewBooks()) return;
    await _showNotification(
      id: bookTitle.hashCode,
      channelId: _NotificationChannels.newBooks,
      channelName: 'New Books',
      channelDescription: 'Notifications for newly published books.',
      title: 'New book available',
      body: '"$bookTitle" has been added to the library.',
      payload: 'book:$bookTitle',
    );
  }

  /// Shows a notification when existing content is updated.
  Future<void> showUpdateNotification(String bookTitle) async {
    if (!_shouldNotifyUpdates()) return;
    await _showNotification(
      id: ('update_$bookTitle').hashCode,
      channelId: _NotificationChannels.updates,
      channelName: 'Updates',
      channelDescription: 'Notifications for book and chapter updates.',
      title: 'Content updated',
      body: '"$bookTitle" has been updated.',
      payload: 'update:$bookTitle',
    );
  }

  bool _shouldNotifyNewBooks() {
    if (!_initialized) return false;
    final settings = Get.find<SettingsRepository>();
    return settings.notifyNewBooks.value;
  }

  bool _shouldNotifyUpdates() {
    if (!_initialized) return false;
    final settings = Get.find<SettingsRepository>();
    return settings.notifyUpdates.value;
  }

  Future<void> _showNotification({
    required int id,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    String? payload,
  }) async {
    final allowed = await requestPermission();
    if (!allowed) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }
}

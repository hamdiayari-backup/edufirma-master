import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../di/service_locator.dart';
import '../storage/local_storage.dart';
import 'user_service.dart';

/// Firebase Cloud Messaging service for real-time notifications
/// Uses flutter_local_notifications to show system notifications in foreground
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications',
    description: 'Notifications importantes de l\'application',
    importance: Importance.high,
    playSound: true,
    showBadge: true,
    enableVibration: true,
  );

  late final FlutterLocalNotificationsPlugin _localNotifications;

  // Callback for navigation when notification tapped
  Function(Map<String, dynamic>)? onNotificationTap;

  // Callback for showing in-app notification (SnackBar)
  Function(String title, String body, Map<String, dynamic>? data)?
      onNotificationReceived;

  /// Initialize Firebase messaging and local notifications
  Future<void> initialize() async {
    try {
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Request permissions (Android 13+ and iOS)
      await Permission.notification.request();

      // Firebase foreground presentation (iOS)
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Firebase permission
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Notification permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? token = await _messaging.getToken();
        debugPrint('FCM Token: $token');

        if (token != null) {
          await _sendTokenToServer(token);
        }

        _messaging.onTokenRefresh.listen(_sendTokenToServer);

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleInitialMessage(initialMessage);
        }
      }
    } catch (e) {
      log('Error initializing Firebase notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationTap(Map<String, dynamic>.from(data));
      } catch (_) {}
    }
  }

  /// Send FCM token to server
  Future<void> _sendTokenToServer(String token) async {
    try {
      final storage = locator<LocalStorage>();
      final accessToken = await storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('FCM: Skipped (user not logged in)');
        return;
      }

      final userService = locator<UserService>();
      final ok = await userService.sendFirebaseToken(token);
      debugPrint('FCM token ${ok ? "sent OK" : "FAILED"} to server');
    } catch (e) {
      log('Error sending FCM token to server: $e');
    }
  }

  /// Handle foreground messages - show system notification + SnackBar
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    final notification = message.notification;

    if (notification != null) {
      // Show system notification (barre de statut) when app in foreground
      _showLocalNotification(
        notification.title ?? 'Notification',
        notification.body ?? '',
        message.data,
        message.hashCode,
      );

      // Also show in-app SnackBar
      if (onNotificationReceived != null) {
        onNotificationReceived!(
          notification.title ?? 'Notification',
          notification.body ?? '',
          message.data,
        );
      }
    }
  }

  /// Display notification in system tray (foreground on Android)
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
    int id,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notifications',
      channelDescription: 'Notifications importantes de l\'application',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/launcher_icon',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: data.isEmpty ? null : jsonEncode(data),
    );
  }

  /// Handle when app is opened from background notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    _handleNotificationTap(message.data);
  }

  /// Handle initial message when app launched from terminated state
  void _handleInitialMessage(RemoteMessage message) {
    debugPrint('Initial message: ${message.messageId}');
    Future.delayed(const Duration(milliseconds: 500), () {
      _handleNotificationTap(message.data);
    });
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(Map<String, dynamic> data) {
    if (onNotificationTap != null) {
      onNotificationTap!(data);
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }

  /// Call after login to send FCM token to server for push notifications
  Future<void> sendTokenToServerIfLoggedIn() async {
    try {
      final token = await getToken();
      if (token != null) await _sendTokenToServer(token);
    } catch (e) {
      log('Error sending FCM token after login: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  /// Show a test notification (to verify system notifications work)
  Future<bool> showTestNotification() async {
    try {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          log('Notification permission denied');
          return false;
        }
      }
      await _showLocalNotification(
        'Test EduFirma',
        'Si vous voyez ceci, les notifications système fonctionnent.',
        {'type': 'notification'},
        99999,
      );
      return true;
    } catch (e) {
      log('Error showing test notification: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

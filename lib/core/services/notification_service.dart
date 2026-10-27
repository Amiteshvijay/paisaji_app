import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zeokash/features/home/data/notification_repository.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling background FCM message: ${message.messageId}');
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationRepository? _notificationRepo;
  void Function(String? route)? onNavigate;
  VoidCallback? onNotificationReceived;

  static const AndroidNotificationChannel _channelTransactions = AndroidNotificationChannel(
    'paisaji_transactions',
    'Transactions & Payments',
    description: 'Notifications for recharges, bill payments, and refunds.',
    importance: Importance.max,
    playSound: true,
  );

  static const AndroidNotificationChannel _channelRewards = AndroidNotificationChannel(
    'paisaji_rewards',
    'Rewards & G Coins',
    description: 'Updates about G Coins earned, coupons, and referral rewards.',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel _channelReminders = AndroidNotificationChannel(
    'paisaji_reminders',
    'Bill & Recharge Reminders',
    description: 'Timely reminders before and after plan expiry or due dates.',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel _channelGeneral = AndroidNotificationChannel(
    'paisaji_general',
    'General & Announcements',
    description: 'Offers, support updates, and security alerts.',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  Future<void> initialize({
    NotificationRepository? repository,
    void Function(String? route)? navigateCallback,
    VoidCallback? refreshCallback,
  }) async {
    _notificationRepo = repository;
    onNavigate = navigateCallback;
    onNotificationReceived = refreshCallback;

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      if (kDebugMode) print('FCM Background handler registration error: ');
    }

    try {
      await _requestPermissions();
    } catch (e) {
      if (kDebugMode) print('Notification permissions error: ');
    }

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(android: androidInit, iOS: darwinInit);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            _handleNavigation(payload);
          }
        },
      );

      if (Platform.isAndroid) {
        final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          await androidImplementation.createNotificationChannel(_channelTransactions);
          await androidImplementation.createNotificationChannel(_channelRewards);
          await androidImplementation.createNotificationChannel(_channelReminders);
          await androidImplementation.createNotificationChannel(_channelGeneral);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Local notifications init error: ');
    }

    try {
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      if (kDebugMode) print('FCM message listeners error: ');
    }

    try {
      await registerDeviceToken();

      _fcm.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
          print('FCM Token Refreshed: ');
        }
        if (_notificationRepo != null) {
          await _notificationRepo!.registerDeviceToken(
            fcmToken: newToken,
            deviceType: Platform.isAndroid ? 'ANDROID' : (Platform.isIOS ? 'IOS' : 'WEB'),
            deviceModel: Platform.operatingSystem,
            appVersion: '1.0.0',
          );
        }
      });
    } catch (e) {
      if (kDebugMode) print('FCM token registration error: ');
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (kDebugMode) {
      print('User granted FCM permission: ${settings.authorizationStatus}');
    }

    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  Future<void> registerDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (kDebugMode) {
        print('FCM Registration Token: $token');
      }
      if (token != null && _notificationRepo != null) {
        await _notificationRepo!.registerDeviceToken(
          fcmToken: token,
          deviceType: Platform.isAndroid ? 'ANDROID' : (Platform.isIOS ? 'IOS' : 'WEB'),
          deviceModel: Platform.operatingSystem,
          appVersion: '1.0.0',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering device token with backend: $e');
      }
    }
  }

  Future<void> unregisterDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null && _notificationRepo != null) {
        await _notificationRepo!.unregisterDeviceToken(token);
      }
      await _fcm.deleteToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering device token: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received Foreground FCM Message: ${message.notification?.title}');
    }

    onNotificationReceived?.call();

    final notification = message.notification;
    final data = message.data;
    final title = notification?.title ?? data['title'] ?? 'Paisaजी Update';
    final body = notification?.body ?? data['message'] ?? '';
    final type = data['type']?.toString().toUpperCase() ?? 'GENERAL';
    final deepLink = data['deep_link']?.toString() ?? '';

    AndroidNotificationChannel selectedChannel = _channelGeneral;
    if (type.contains('RECHARGE') || type.contains('PAYMENT')) {
      selectedChannel = _channelTransactions;
    } else if (type.contains('COIN') || type.contains('REWARD')) {
      selectedChannel = _channelRewards;
    } else if (type.contains('REMINDER') || type.contains('EXPIRY')) {
      selectedChannel = _channelReminders;
    }

    final androidDetails = AndroidNotificationDetails(
      selectedChannel.id,
      selectedChannel.name,
      channelDescription: selectedChannel.description,
      importance: selectedChannel.importance,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: deepLink.isNotEmpty ? deepLink : '/alerts',
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final deepLink = message.data['deep_link']?.toString();
    _handleNavigation(deepLink ?? '/alerts');
  }

  void _handleNavigation(String deepLink) {
    if (onNavigate != null) {
      onNavigate!(deepLink);
    }
  }
}

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../providers/api_provider.dart';
import '../repositories/auth_repository.dart';

/// Top-level background message handler required by FirebaseMessaging.
/// Must be annotated with @pragma('vm:entry-point') to execute while the app is terminated or in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FCM Background] Message received: ${message.messageId} - ${message.notification?.title}');
  } catch (e) {
    debugPrint('[FCM Background] Initialization error: $e');
  }
}

/// Centralized service managing Firebase Cloud Messaging (FCM) push notifications,
/// foreground heads-up banners, and device token synchronization with Laravel.
class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// High importance notification channel for order status updates
  static const AndroidNotificationChannel _orderChannel =
      AndroidNotificationChannel(
    'pizzneapol_orders_channel',
    'Order Notifications',
    description:
        'Real-time notifications for pizza order placement, preparation, and delivery updates',
    importance: Importance.high,
    playSound: true,
  );

  /// Current device FCM token
  final Rx<String?> fcmToken = Rx<String?>(null);

  /// Initializes notification permissions, channels, and event listeners
  Future<NotificationService> init() async {
    try {
      // 1. Request notification permission (Android 13+ & iOS)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      // 2. Setup foreground heads-up banner presentation for iOS
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Initialize flutter_local_notifications for Android & iOS
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          _handleLocalNotificationClick(response.payload);
        },
      );

      // 4. Create high-importance Android notification channel
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_orderChannel);
      }

      // 5. Fetch initial FCM device token
      await _fetchAndStoreToken();

      // 6. Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] Token refreshed: $newToken');
        fcmToken.value = newToken;
        syncTokenWithBackend(newToken);
      });

      // 7. Listen for foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        _handleForegroundMessage(message);
      });

      // 8. Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleMessageClick(message);
      });

      // 9. Check if app was opened directly from a terminated state notification
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageClick(initialMessage);
      }
    } catch (e) {
      debugPrint('[FCM] Error initializing notification service: $e');
    }

    return this;
  }

  /// Fetches current FCM token
  Future<void> _fetchAndStoreToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken.value = token;
        debugPrint('[FCM] Device Token: $token');
        syncTokenWithBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] Failed to fetch device token: $e');
    }
  }

  /// Synchronizes device FCM token with the Laravel REST API backend
  Future<void> syncTokenWithBackend([String? token]) async {
    final activeToken = token ?? fcmToken.value;
    if (activeToken == null || activeToken.isEmpty) return;

    // Only sync if customer is authenticated
    final authRepo =
        Get.isRegistered<AuthRepository>() ? Get.find<AuthRepository>() : null;
    if (authRepo == null || !authRepo.isAuthenticated) {
      debugPrint('[FCM] Skipping token sync: customer not authenticated');
      return;
    }

    final api =
        Get.isRegistered<ApiProvider>() ? Get.find<ApiProvider>() : null;
    if (api != null) {
      try {
        final response = await api.updateFcmToken(activeToken);
        if (response.isOk) {
          debugPrint('[FCM] Device token successfully synced with Laravel backend');
        } else {
          debugPrint(
              '[FCM] Backend rejected token sync: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('[FCM] Failed to sync token with backend: $e');
      }
    }
  }

  /// Displays foreground notification heads-up banner using flutter_local_notifications
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM Foreground] Received: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title ?? 'PIZZNEAPOL',
        body: notification.body ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _orderChannel.id,
            _orderChannel.name,
            channelDescription: _orderChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['order_id']?.toString(),
      );
    }
  }

  /// Handles routing when user taps on a notification
  void _handleMessageClick(RemoteMessage message) {
    debugPrint('[FCM Click] Opened notification: ${message.data}');
    _navigateOnNotificationTap(message.data['order_id']?.toString());
  }

  /// Handles local notification click callback
  void _handleLocalNotificationClick(String? orderId) {
    _navigateOnNotificationTap(orderId);
  }

  /// Navigates to Orders tab or order details screen
  void _navigateOnNotificationTap(String? orderId) {
    if (Get.key.currentState != null) {
      Get.toNamed(Routes.ORDERS, arguments: orderId);
    }
  }
}

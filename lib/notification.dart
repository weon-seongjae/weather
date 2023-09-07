import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true
    );
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel Id', 'channel Name',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: false
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1));

    await flutterLocalNotificationsPlugin.show(
        0,
        'test tile',
        'test body',
        notificationDetails,
        payload: 'HELLOWORLD',
    );
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String payload = notificationResponse.payload ?? '';
    if (notificationResponse.payload != null ||
        notificationResponse.payload!.isNotEmpty) {
      print('FOREGROUND PAYLOAD: $payload');
      streamController.add(payload);
    }
  }

  static void onBackgroundNotificationResponse() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      String payload =
          notificationAppLaunchDetails!.notificationResponse?.payload ?? '';
      print('BACKGROUND PAYLOAD: $payload');
      streamController.add(payload);
    }
  }
}
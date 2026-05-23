import 'dart:convert';

import '../../app_export.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AudioPlayer player = AudioPlayer();

  Future<void> _whistle(String sound) async {
    await player.setSource(AssetSource(sound)).then((value) {
      player.play(AssetSource(sound));
    });
    player.onPlayerStateChanged.listen((PlayerState s) async {
      if (s == PlayerState.completed) {
        await player.pause();
      }
    });
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped with payload: ${response.payload}");
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = json.decode(response.payload!);
            final String? packageId = data["community"] ?? data["packageId"];
            if (packageId != null) {
              // Add delay to ensure navigation is possible if app was in background
              Future.delayed(const Duration(milliseconds: 500), () {
                debugPrint("Navigating to Community Chat for package: $packageId");
                Get.toNamed(RouteNames.communityChat, arguments: {"packageId": packageId, "coverImage": data["coverImage"]});
              });
            }
          } catch (e) {
            debugPrint("Error handling notification tap: $e");
          }
        }
      },
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // Request permission for Android 13+ and iOS
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    debugPrint('✅ Notification service initialized');
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    if (GetPlatform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'task_reminder_high', // id
        'OnTrip Alerts', // name
        description: 'High priority alerts and trip reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      );

      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      debugPrint('✅ Notification channel created: ${channel.id}');
    }
  }

  void showRemoteNotificationAndroid(RemoteMessage message) async {
    bool isNotificationEnabled = GetStorage().read(StringConstants.notificationEnabled) ?? true;
    if (!isNotificationEnabled) {
      debugPrint('❌ Notifications disabled by user');
      return;
    }

    if (Get.currentRoute.split('?').first == RouteNames.communityChat) {
      debugPrint('❌ Skipping notification - already in community chat');
      return;
    }

    RemoteNotification? notification = message.notification;
    if (notification != null) {
      debugPrint('🔔 Showing notification: ${notification.title}');

      NotificationDetails notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
          "task_reminder_high",
          "OnTrip Alerts",
          ticker: 'ticker',
          showWhen: true,
          playSound: true,
          enableLights: true,
          enableVibration: true,
          priority: Priority.high,
          importance: Importance.max,
          visibility: NotificationVisibility.public,
          channelDescription: "High priority alerts and trip reminders",
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );

      try {
        _whistle("slow_spring_board.mp3");
        await flutterLocalNotificationsPlugin.show(
          // notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: notificationDetails,
          payload: json.encode(message.data),
          id: notification.hashCode,
        );
        debugPrint('✅ Notification shown successfully');
      } catch (e) {
        debugPrint('❌ Error showing notification: $e');
      }
    } else {
      debugPrint('❌ No notification object in message');
    }
  }

  Future createNotificationOrder(String title, description, payload) async {
    bool isNotificationEnabled = GetStorage().read(StringConstants.notificationEnabled) ?? true;
    if (!isNotificationEnabled) return;

    if (Get.currentRoute.split('?').first == RouteNames.communityChat) return;

    // Use a unique channel ID for high-importance notifications
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '151',
      'Community Chat',
      channelDescription: 'Real-time messages from trip community',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableLights: true,
      showWhen: true,
      visibility: NotificationVisibility.public,
      enableVibration: true,
      fullScreenIntent: false,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosPlatformChannelSpecifics);

    var nPayload = json.encode(payload);
    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch % 1000000,
      title: title,
      body: description,
      notificationDetails: platformChannelSpecifics,
      payload: nPayload,
    );
  }

  Future<String?> getToken() async {
    try {
      String? fcmToken;

      if (GetPlatform.isIOS) {
        int retryCount = 0;
        while (retryCount < 3) {
          try {
            String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null) {
              debugPrint("APNs Token received: $apnsToken");
              break;
            }
          } catch (e) {
            debugPrint("Waiting for APNs token (Attempt ${retryCount + 1})...");
          }
          await Future.delayed(const Duration(seconds: 2));
          retryCount++;
        }
      }

      fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM Token: $fcmToken");
      return fcmToken;
    } catch (err) {
      debugPrint("Final error getting FCM token: $err");
      return null;
    }
  }
}

NotificationService notificationService = NotificationService();

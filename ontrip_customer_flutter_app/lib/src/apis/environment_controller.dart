import 'dart:convert';
import '../../app_export.dart';

class MasterController extends GetxController {
  Future<void>? _envLoadFuture;

  @override
  void onInit() {
    super.onInit();
    ensureEnvironmentLoaded();
    _setupFirebaseMessagingListeners();
  }

  final RxMap<String, String> localEnvJson = <String, String>{}.obs, liveEnvJson = <String, String>{}.obs;

  Future<void> ensureEnvironmentLoaded() {
    return _envLoadFuture ??= _readEnvironment();
  }

  Future<void> _readEnvironment() async {
    try {
      final readLocalEnv = await rootBundle.loadString('assets/env/local_env.json');
      final readLiveEnv = await rootBundle.loadString('assets/env/live_env.json');
      localEnvJson.value = Map<String, String>.from(jsonDecode(readLocalEnv));
      liveEnvJson.value = Map<String, String>.from(jsonDecode(readLiveEnv));
      debugPrint('localEnvJson : $localEnvJson');
      debugPrint('liveEnvJson : $liveEnvJson');
    } catch (e) {
      errorToast("Failed to read environment");
    }
  }

  /// Setup Firebase Messaging listeners for foreground and background messages
  void _setupFirebaseMessagingListeners() {
    // Handle foreground messages (when app is open and in use)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📱 Foreground message received!');
      debugPrint('Message ID: ${message.messageId}');
      debugPrint('Message data: ${message.data}');
      debugPrint('Notification: ${message.notification?.title} - ${message.notification?.body}');
      
      // Show notification popup when app is in foreground
      notificationService.showRemoteNotificationAndroid(message);
      
      // Refresh notification count if NotificationCtrl is registered
      if (Get.isRegistered<NotificationCtrl>()) {
        Get.find<NotificationCtrl>().fetchUnreadCount();
      }
    });

    // Handle when user taps notification while app is in background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Notification tapped (app was in background)');
      debugPrint('Message data: ${message.data}');
      
      // Handle navigation based on notification data
      _handleNotificationTap(message.data);
      
      // Refresh notification count
      if (Get.isRegistered<NotificationCtrl>()) {
        Get.find<NotificationCtrl>().fetchUnreadCount();
      }
    });

    debugPrint('✅ Firebase Messaging listeners setup complete');
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(Map<String, dynamic> data) {
    try {
      final String? type = data['type'];
      final String? packageId = data['community'] ?? data['packageId'];
      final String? bookingId = data['bookingId'];
      final String? notificationId = data['notificationId'];

      // Mark notification as read if ID is provided
      if (notificationId != null && Get.isRegistered<NotificationCtrl>()) {
        Get.find<NotificationCtrl>().markAsRead(notificationId);
      }

      // Navigate based on type
      switch (type?.toLowerCase()) {
        case 'community':
        case 'chat':
          if (packageId != null) {
            Get.toNamed(
              RouteNames.communityChat,
              arguments: {
                "packageId": packageId,
                "coverImage": data["coverImage"],
              },
            );
          }
          break;
        case 'booking':
          if (bookingId != null) {
            Get.toNamed(
              RouteNames.bookingDetails,
              arguments: {"bookingId": bookingId},
            );
          }
          break;
        default:
          // Default: open notifications screen
          Get.toNamed(RouteNames.notifications);
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }
}

import 'package:ontrip_customer_flutter_app/src/models/notification_model.dart';

import '../../../app_export.dart';

class NotificationCtrl extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  bool get isVendor => getStorage(AppSession.userRole) == 'vendor';

  @override
  void onInit() {
    super.onInit();
    // Fetch notifications and unread count when controller initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchNotifications();
      fetchUnreadCount();
    });
  }

  /// Fetch all notifications based on user role
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final endpoint = isVendor ? BACKEND.vendorNotifications : BACKEND.customerNotifications;

      final response = await ApiManager.call(endPoint: endpoint, type: ApiType.get);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        final data = response.data;
        if (data != null && data['notifications'] != null) {
          final notificationList = (data['notifications'] as List).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
          notifications.assignAll(notificationList);
        }
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch unread notification count
  Future<void> fetchUnreadCount() async {
    try {
      final endpoint = isVendor ? BACKEND.vendorNotificationsUnreadCount : BACKEND.customerNotificationsUnreadCount;

      final response = await ApiManager.call(endPoint: endpoint, type: ApiType.get);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        final data = response.data;
        if (data != null && data['unreadCount'] != null) {
          unreadCount.value = data['unreadCount'] as int;
        }
      }
    } catch (e) {
      debugPrint("Error fetching unread count: $e");
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final endpoint = isVendor ? BACKEND.vendorNotificationMarkRead(notificationId) : BACKEND.customerNotificationMarkRead(notificationId);

      final response = await ApiManager.call(endPoint: endpoint, type: ApiType.patch);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        // Update local notification state
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification = NotificationModel(
            id: notifications[index].id,
            title: notifications[index].title,
            message: notifications[index].message,
            type: notifications[index].type,
            isRead: true,
            createdAt: notifications[index].createdAt,
            data: notifications[index].data,
          );
          notifications[index] = updatedNotification;
          notifications.refresh();
        }
        // Decrease unread count
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final endpoint = isVendor ? BACKEND.vendorNotificationsReadAll : BACKEND.customerNotificationsReadAll;

      final response = await ApiManager.call(endPoint: endpoint, type: ApiType.patch);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        // Update all local notifications to read
        for (int i = 0; i < notifications.length; i++) {
          final updatedNotification = NotificationModel(
            id: notifications[i].id,
            title: notifications[i].title,
            message: notifications[i].message,
            type: notifications[i].type,
            isRead: true,
            createdAt: notifications[i].createdAt,
            data: notifications[i].data,
          );
          notifications[i] = updatedNotification;
        }
        notifications.refresh();
        unreadCount.value = 0;
        successToast("All notifications marked as read");
      }
    } catch (e) {
      debugPrint("Error marking all as read: $e");
      errorToast("Failed to mark all as read");
    }
  }

  /// Handle notification tap
  void onNotificationTap(NotificationModel notification) {
    // Mark as read if not already read
    if (notification.isRead == false && notification.id != null) {
      markAsRead(notification.id!);
    }

    // Handle navigation based on notification type
    // You can customize this based on your notification types
    if (notification.data != null) {
      final type = notification.type?.toLowerCase();
      switch (type) {
        case 'booking':
          // Navigate to booking details
          break;
        case 'community':
          // Navigate to community
          Get.toNamed(RouteNames.communityChat);
          break;
        case 'package':
          // Navigate to package details
          break;
        default:
          // Do nothing or show details
          break;
      }
    }
  }
}

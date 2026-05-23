import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import 'package:ontrip_customer_flutter_app/src/models/notification_model.dart';

import '../../../app_export.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(NotificationCtrl());

    return Scaffold(
      backgroundColor: AppThemeColors.bgCream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppThemeColors.primaryOrange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppThemeColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Notifications', style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.white)),
        actions: [
          Obx(() {
            if (ctrl.notifications.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: ctrl.markAllAsRead,
              child: Text('Mark all read', style: AppTextStyle.medium.copyWith(fontSize: 14, color: AppThemeColors.white)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.notifications.isEmpty) {
          return const Center(child: CustomLoadingIndicator());
        }

        if (ctrl.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ctrl.fetchNotifications();
            await ctrl.fetchUnreadCount();
          },
          color: AppThemeColors.primaryOrange,
          backgroundColor: AppThemeColors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: ctrl.notifications.length,
            itemBuilder: (context, index) {
              final notification = ctrl.notifications[index];
              return _buildNotificationCard(notification, ctrl);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationCtrl ctrl) {
    final isUnread = notification.isRead == false;
    final timeAgo = _getTimeAgo(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppThemeStyles.cardDecoration(
        color: isUnread ? AppThemeColors.primaryOrange.withValues(alpha: 0.05) : AppThemeColors.white,
        radius: AppThemeStyles.radiusMedium,
        shadows: AppThemeStyles.shadowLight,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ctrl.onNotificationTap(notification),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _getNotificationColor(notification.type).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getNotificationIcon(notification.type), color: _getNotificationColor(notification.type), size: 20),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(notification.title ?? 'Notification', style: AppTextStyle.bold.copyWith(fontSize: 15, color: const Color(0xFF1E293B))),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: AppThemeColors.primaryOrange, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      // const SizedBox(height: 6),
                      // Text(
                      //   notification.message ?? '',
                      //   style: AppTextStyle.medium.copyWith(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
                      //   maxLines: 3,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: AppThemeColors.greyText.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(timeAgo, style: AppTextStyle.medium.copyWith(fontSize: 11, color: AppThemeColors.greyText.withValues(alpha: 0.6))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.notifications_none_rounded, size: 64, color: AppThemeColors.primaryOrange),
            ),
            const SizedBox(height: 24),
            Text('No Notifications', style: AppTextStyle.bold.copyWith(fontSize: 22, color: AppThemeColors.blackText)),
            const SizedBox(height: 12),
            Text(
              'You\'re all caught up! Check back later for updates.',
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.greyText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return Icons.confirmation_number_outlined;
      case 'community':
        return Icons.chat_bubble_outline_rounded;
      case 'package':
        return Icons.card_travel_outlined;
      case 'payment':
        return Icons.payment_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return const Color(0xFF10B981);
      case 'community':
        return const Color(0xFF3B82F6);
      case 'package':
        return const Color(0xFF8B5CF6);
      case 'payment':
        return const Color(0xFFF59E0B);
      case 'alert':
        return const Color(0xFFEF4444);
      default:
        return AppThemeColors.primaryOrange;
    }
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}

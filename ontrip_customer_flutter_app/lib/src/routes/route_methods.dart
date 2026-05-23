

import '../../app_export.dart';

class RouteMethods {
  static final List<GetPage> pages = [
    GetPage(name: RouteNames.splash, page: () => const SplashScreen(), binding: SplashBinder()),
    GetPage(name: RouteNames.signIn, page: () => const SignInScreen()),
    GetPage(name: RouteNames.verifyOTP, page: () => const VerifyOTPScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => VerifyOTPCtrl()))),
    GetPage(name: RouteNames.dashboard, page: () => const DashboardScreen() ),
    GetPage(name: RouteNames.history, page: () => const HistoryScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => HistoryCtrl()))),
    GetPage(name: RouteNames.community, page: () => const CommunityScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => CommunityCtrl()))),
    GetPage(name: RouteNames.communityChat, page: () => const CommunityChatScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => CommunityChatCtrl()))),
    GetPage(name: RouteNames.groupMembers, page: () => const GroupMembersScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => GroupMembersCtrl()))),
    GetPage(name: RouteNames.settings, page: () => const SettingsScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => SettingsCtrl()))),
    GetPage(name: RouteNames.editProfile, page: () => const EditProfileScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => EditProfileCtrl()))),
    GetPage(name: RouteNames.communityMedia, page: () => const CommunityMediaScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => CommunityMediaCtrl()))),
    GetPage(name: RouteNames.bookingDetails, page: () => const BookingDetailsScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => BookingDetailsCtrl()))),
    GetPage(name: RouteNames.vendorPackageDetails, page: () => const VendorPackageDetailsScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => VendorPackageDetailsCtrl()))),
    GetPage(name: RouteNames.notifications, page: () => const NotificationsScreen(), binding: BindingsBuilder(() => Get.lazyPut(() => NotificationCtrl()))),
  ];
}

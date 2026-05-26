import 'dart:developer';

import '../../../app_export.dart';

class SplashCtrl extends GetxController {
  @override
  void onInit() {
    log("SplashCtrl: onInit called");
    onNavigate();
    super.onInit();
  }

  Future<void> onNavigate() async {
    log("SplashCtrl: onNavigate called");
    // Properly await the splash delay
    await Future.delayed(const Duration(seconds: 3));
    log("SplashCtrl: Timer finished, checking token");
    try {
      final token = getStorage(AppSession.token);
      log("SplashCtrl: Token retrieved: $token");
      if (token != null) {
        // Fetch user profile BEFORE navigating so userAuthData is always
        // populated when dashboard/home screens first render.
        // This fixes empty user data on app kill+restart and hot reload.
        log("SplashCtrl: Token found — fetching profile before navigation...");
        await Get.find<AuthenticationController>().fetchProfile();
        log("SplashCtrl: Profile fetched — navigating to dashboard");
        pushNRemoveUntil(path: RouteNames.dashboard);
      } else {
        log("SplashCtrl: No token — navigating to sign in");
        pushNRemoveUntil(path: RouteNames.signIn);
      }
    } catch (e) {
      log("SplashCtrl: Error in onNavigate: $e");
      pushNRemoveUntil(path: RouteNames.signIn);
    }
  }
}

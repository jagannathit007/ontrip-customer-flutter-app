import 'dart:async';
import 'dart:developer';

import '../../../../app_export.dart';
import '../../../screens/vendor/home/vendor_home_ctrl.dart';

class VerifyOTPCtrl extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final List<TextEditingController> localOTPControllers = List.generate(4, (_) => TextEditingController());
  final isLoading = false.obs;
  final resendTimer = 30.obs;
  final canResend = false.obs;
  Timer? _timer;
  String phone = "";
  bool isVendor = false;

  void updateOTPValue() {
    otpController.text = localOTPControllers.map((c) => c.text).join();
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      phone = Get.arguments['phone'] ?? "";
      isVendor = Get.arguments['role'] == 'vendor';
    }
    startResendTimer();
  }

  void startResendTimer() {
    canResend.value = false;
    resendTimer.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResend.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOTP() async {
    try {
      final Map<String, dynamic> sendJson = {"phone": phone};
      final endpoint = isVendor ? BACKEND.vendorSendOtp : BACKEND.sendOtp;
      final response = await ApiManager.call(
        endPoint: endpoint,
        body: sendJson,
      );
      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        successToast("OTP Resent successfully");
        startResendTimer();
      } else {
        errorToast(response.message);
      }
    } catch (e) {
      errorToast(e.toString());
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.length < 4) {
      warningToast("Please enter a valid OTP");
      return;
    }

    try {
      isLoading.value = true;
      String fcm = await notificationService.getToken() ?? "";
      log(fcm);
      final Map<String, dynamic> body = {
        "phone": phone,
        "otp": otpController.text.trim(),
        'fcmToken': fcm,
      };

      final endpoint = isVendor ? BACKEND.vendorSignIn : BACKEND.signIn;
      log('Role: ${isVendor ? "vendor" : "customer"} → $endpoint');
      final response = await ApiManager.call(
        endPoint: endpoint,
        body: body,
      );
      log('verifyOTP status: ${response.status}, success: ${response.success}');
      log('verifyOTP data: ${response.data}');
      log('verifyOTP fullResponse: ${response.fullResponse}');
      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        final data = response.data ?? response.fullResponse;
        if (data == null) {
          errorToast("Invalid response from server");
          return;
        }
        await processAfterSignIn(data);
      } else {
        errorToast(response.message);
      }
    } catch (e) {
      errorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processAfterSignIn(dynamic responseData) async {
    log('processAfterSignIn responseData: $responseData');

    // Extract token — handle multiple possible structures:
    // 1. { tokens: { token: "..." } }   ← customer
    // 2. { token: "..." }               ← vendor / flat
    // 3. { data: { token: "..." } }     ← nested under data
    String? token;

    if (responseData is Map) {
      if (responseData['tokens'] is Map &&
          responseData['tokens']['token'] != null) {
        token = responseData['tokens']['token'].toString();
      } else if (responseData['token'] != null) {
        token = responseData['token'].toString();
      } else if (responseData['data'] is Map) {
        final inner = responseData['data'] as Map;
        if (inner['tokens'] is Map && inner['tokens']['token'] != null) {
          token = inner['tokens']['token'].toString();
        } else if (inner['token'] != null) {
          token = inner['token'].toString();
        }
      }
    }

    log('Extracted token: $token');

    if (token != null && token.isNotEmpty) {
      await writeStorage(AppSession.token, token);
      await writeStorage(AppSession.userRole, isVendor ? 'vendor' : 'customer');
      await Get.find<MasterController>().ensureEnvironmentLoaded();

      if (isVendor) {
        // Vendor: fetch vendor profile + vendor packages
        await Get.find<AuthenticationController>().fetchProfile();
        await Get.find<VendorHomeCtrl>().fetchPackages();
      } else {
        // Customer: existing flow
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().initialize();
        }
      }

      pushNRemoveUntil(path: RouteNames.dashboard);
    } else {
      errorToast("Token not found in response");
      log('Full responseData dump: $responseData');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    for (var c in localOTPControllers) {
      c.dispose();
    }
    super.onClose();
  }
}

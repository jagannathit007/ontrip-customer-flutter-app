import '../../app_export.dart';

enum RunEnvironment { local, live }

class AppNetworkConstants {
  static MasterController get _masterCtrl => Get.find<MasterController>();

  static Map<String, String> _env({required bool isLive}) {
    if (isLive) return _masterCtrl.liveEnvJson;
    return _masterCtrl.localEnvJson;
  }

  static Map<String, String> get _envJson => _env(isLive: false);

  static String get apiBaseURL => _envJson['mobile_base_url'] ?? '';
  static String get baseURL => _envJson['image_url'] ?? '';
}

import 'dart:convert';
import '../../app_export.dart';

class MasterController extends GetxController {
  Future<void>? _envLoadFuture;

  @override
  void onInit() {
    super.onInit();
    ensureEnvironmentLoaded();
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
}

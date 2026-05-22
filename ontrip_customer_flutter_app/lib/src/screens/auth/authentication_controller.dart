import 'package:ontrip_customer_flutter_app/app_export.dart';

class AuthenticationController extends GetxService {
  Future<AuthenticationController> init() async => this;

  final RxMap<String, dynamic> userAuthData = <String, dynamic>{}.obs;

  final loginList = <dynamic>[].obs;

  bool get isVendor => getStorage(AppSession.userRole) == 'vendor';

  Future<void> fetchProfile() async {
    try {
      final endpoint = isVendor ? BACKEND.vendorProfile : BACKEND.profileUpdate;
      final response = await ApiManager.call(endPoint: endpoint, type: ApiType.get);

      if (response.status == 1 || response.status == 200) {
        final data = response.data;
        if (data is Map) {
          final dataMap = Map<String, dynamic>.from(data);
          // Customer API returns data.customer; vendor API returns data.vendor
          final profileData = dataMap['vendor'] ?? dataMap['customer'];
          if (profileData is Map) {
            userAuthData.assignAll(Map<String, dynamic>.from(profileData));
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }
}

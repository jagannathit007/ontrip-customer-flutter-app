import '../../../app_export.dart';
import '../vendor/packages/vendor_packages.dart';

class DashboardCtrl extends GetxController {
  AuthenticationController service = Get.find();

  final RxBool cardScanner = true.obs;
  final RxInt currentIndex = 0.obs;

  bool get isVendor => getStorage(AppSession.userRole) == 'vendor';

  bool checkLock() => false;

  @override
  void onInit() async {
    super.onInit();
    socketService.connectToServer();
  }

  void onTapForBottomNavBar(int index) {
    currentIndex.value = index;
    update();
  }

  Widget currentScreen() {
    if (isVendor) {
      switch (currentIndex.value) {
        
        case 0:
          return const VendorPackagesScreen(); // vendor packages list
        case 1:
          return const CommunityScreen(); // shared
        case 2:
          return const SettingsScreen(); // shared (uses vendorProfile)
        default:
          return const VendorPackagesScreen();
      }
      // switch (currentIndex.value) {
      //   case 0:
      //     return const VendorHomeScreen(); // vendor packages API
      //   case 1:
      //     return const VendorPackagesScreen(); // vendor packages list
      //   case 2:
      //     return const CommunityScreen(); // shared
      //   case 3:
      //     return const SettingsScreen(); // shared (uses vendorProfile)
      //   default:
      //     return const VendorHomeScreen();
      // }
    } else {
      switch (currentIndex.value) {
        case 0:
          return const HomeScreen();
        case 1:
          return const HistoryScreen();
        case 2:
          return const CommunityScreen();
        case 3:
          return const SettingsScreen();
        default:
          return const HomeScreen();
      }
    }
  }
}

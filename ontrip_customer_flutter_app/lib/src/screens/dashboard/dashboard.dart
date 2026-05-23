import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import '../../../app_export.dart';

class DashboardScreen extends GetView<DashboardCtrl> {
  const DashboardScreen({super.key});

  Future<bool> _onWillPop() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppThemeStyles.radiusXXLarge)),
            backgroundColor: AppThemeColors.white,
            elevation: 32,
            shadowColor: AppThemeColors.shadowDark,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemeColors.error.withValues(alpha: 0.2), AppThemeColors.error.withValues(alpha: 0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.exit_to_app_rounded, color: AppThemeColors.error, size: 26),
                ),
                const SizedBox(width: 18),
                const Text(
                  'Exit App',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1B213F), letterSpacing: -0.5),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to exit the application?',
              style: TextStyle(fontSize: 16, color: AppThemeColors.greyText, height: 1.6, letterSpacing: 0.2),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF8E95A2), fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.3),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(result: true);
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.error,
                  foregroundColor: AppThemeColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Exit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardCtrl>(
      init: DashboardCtrl(),
      builder: (ctrl) {
        return WillPopScope(
          onWillPop: () async {
            if (ctrl.currentIndex.value == 0) {
              return await _onWillPop();
            } else {
              ctrl.onTapForBottomNavBar(ctrl.currentIndex.value - 1);
              return false;
            }
          },
          child: Scaffold(
            extendBody: true,
            backgroundColor: AppThemeColors.bgCream,
            bottomNavigationBar: Obx(() {
              if (ctrl.cardScanner.value == false) {
                return const SizedBox.shrink();
              }
              return CustomBottomNavBar(currentIndex: ctrl.currentIndex.value, onTabChange: ctrl.onTapForBottomNavBar);
            }),
            body: SafeArea(bottom: true, top: false, child: ctrl.currentScreen()),
          ),
        );
      },
    );
  }
}

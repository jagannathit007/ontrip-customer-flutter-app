import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import 'package:ontrip_customer_flutter_app/src/screens/auth/sign_in/sign_in_ctrl.dart';

import '../../../app_export.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController, _iconController;
  late Animation<double> _scaleAnimation,
      _fadeAnimation,
      _iconRotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.bounceOut),
    );
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _iconController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInCtrl>(
      builder: (controller) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppThemeStyles.radiusXXLarge),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 340),
                      decoration: BoxDecoration(
                        color: AppThemeColors.white,
                        borderRadius: BorderRadius.circular(AppThemeStyles.radiusXXLarge),
                        boxShadow: AppThemeStyles.shadowLarge,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 32),
                          AnimatedBuilder(
                            animation: _iconController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _iconRotationAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppThemeColors.primaryOrange.withValues(alpha: 0.1),
                                        AppThemeColors.primaryOrange.withValues(alpha: 0.15),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppThemeColors.primaryOrange.withValues(alpha: 0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppThemeColors.primaryOrange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        size: 28,
                                        color: AppThemeColors.primaryOrange,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Log Out?',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.bold.copyWith(
                                fontSize: 22,
                                color: AppThemeColors.blackText,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Are you sure you want to log out of your account?',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.medium.copyWith(
                                fontSize: 15,
                                color: AppThemeColors.greyText,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppThemeColors.bgCream,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppThemeColors.borderLight,
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: controller.isLoadingForLogout
                                            ? null
                                            : () {
                                                HapticFeedback.lightImpact();
                                                backScreen();
                                              },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Center(
                                          child: Text(
                                            "Cancel",
                                            style: AppTextStyle.semiBold.copyWith(
                                              fontSize: 16,
                                              color: controller.isLoadingForLogout
                                                  ? AppThemeColors.greyText.withValues(alpha: 0.5)
                                                  : AppThemeColors.greyText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: controller.isLoadingForLogout
                                            ? [
                                                AppThemeColors.greyText.withValues(alpha: 0.5),
                                                AppThemeColors.greyText.withValues(alpha: 0.6),
                                              ]
                                            : [
                                                AppThemeColors.primaryOrange,
                                                AppThemeColors.primaryOrange.withValues(alpha: 0.8),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: controller.isLoadingForLogout
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: AppThemeColors.primaryOrange.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: controller.isLoadingForLogout
                                            ? null
                                            : () async {
                                                HapticFeedback.mediumImpact();
                                                final isLogOut =
                                                    await controller.onLogout();
                                                debugPrint(
                                                  "TOKEN : ${getStorage(AppSession.token)}",
                                                );

                                                if (isLogOut) {
                                                  successToast(
                                                    "LogOut successfully",
                                                  );
                                                  await Get.deleteAll(
                                                    force: true,
                                                  );
                                                  preBinderControllers();
                                                  pushNReplace(
                                                    path: RouteNames.signIn,
                                                  );
                                                } else {
                                                  errorToast(
                                                    "Failed to logout",
                                                  );
                                                }
                                              },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Center(
                                          child: controller.isLoadingForLogout
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(AppThemeColors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      "Logging Out...",
                                                      style: AppTextStyle.semiBold.copyWith(
                                                        fontSize: 16,
                                                        color: AppThemeColors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.logout_rounded,
                                                      size: 20,
                                                      color: AppThemeColors.white,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "Log Out",
                                                      style: AppTextStyle.semiBold.copyWith(
                                                        fontSize: 16,
                                                        color: AppThemeColors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import 'package:ontrip_customer_flutter_app/src/helper/decoration.dart';

import '../../../app_export.dart';

class SplashScreen extends GetWidget<SplashCtrl> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8), AppThemeColors.bgCream],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(Graphics.instance.profileBackground), fit: BoxFit.cover, opacity: 0.05),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppThemeColors.white,
                            boxShadow: AppThemeStyles.shadowLarge,
                          ),
                          child: Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.5)],
                              ),
                              image: DecorationImage(image: AssetImage(Graphics.instance.logo), fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Text(
                          "On Trip",
                          style: AppTextStyle.bold.copyWith(fontSize: 28, color: AppThemeColors.white, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 15 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Text(
                          "Your Digital Way to Find Trip",
                          style: AppTextStyle.medium.copyWith(fontSize: 16, color: AppThemeColors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w400),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 2),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 60),
                        child: LinearProgressIndicator(
                          backgroundColor: AppThemeColors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(AppThemeColors.white),
                          minHeight: 3,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          Container(height: 1, width: 60, color: AppThemeColors.white.withValues(alpha: 0.4)),
                          const SizedBox(height: 15),
                          CustomRichText(
                            text1: "Powered by ",
                            text2: "ITFuturz",
                            style1: AppTextStyle.medium.copyWith(fontSize: 14, color: AppThemeColors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w400),
                            style2: AppTextStyle.bold.copyWith(fontSize: 14, color: AppThemeColors.white, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            Positioned(
              top: -50,
              right: -50,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 0.5,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemeColors.white.withValues(alpha: 0.05)),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: -value * 0.3,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppThemeColors.white.withValues(alpha: 0.03)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// OnTrip App Theme Colors
/// Reference: SignIn and VerifyOTP screens
class AppThemeColors {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFE8693A);
  static const Color darkNavy = Color(0xFF1B213F);

  // Background Colors
  static const Color bgCream = Color.fromARGB(255, 255, 255, 255);
  static const Color white = Colors.white;

  // Text Colors
  static const Color greyText = Color(0xFF8E95A2);
  static const Color subWhite = Color(0xB3FFFFFF); // 70% opacity white
  static const Color blackText = Color(0xFF1B213F);

  // Accent Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Shadow Colors
  static Color shadowLight = darkNavy.withValues(alpha: 0.05);
  static Color shadowMedium = darkNavy.withValues(alpha: 0.1);
  static Color shadowDark = Colors.black.withValues(alpha: 0.2);

  // Border Colors
  static Color borderLight = greyText.withValues(alpha: 0.2);
  static Color borderMedium = greyText.withValues(alpha: 0.3);
  static Color borderOrange = primaryOrange.withValues(alpha: 0.5);

  // Overlay Colors
  static Color overlayLight = bgCream.withValues(alpha: 0.5);
  static Color overlayDark = darkNavy.withValues(alpha: 0.8);
}

/// OnTrip App Theme Styles
class AppThemeStyles {
  // Border Radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusXXLarge = 32.0;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingXXXLarge = 32.0;

  // Shadows
  static List<BoxShadow> shadowLight = [BoxShadow(color: AppThemeColors.shadowLight, blurRadius: 10, offset: const Offset(0, 2))];

  static List<BoxShadow> shadowMedium = [BoxShadow(color: AppThemeColors.shadowMedium, blurRadius: 20, offset: const Offset(0, 4))];

  static List<BoxShadow> shadowLarge = [BoxShadow(color: AppThemeColors.shadowLight, blurRadius: 30, offset: const Offset(0, 10))];

  // Card Decoration
  static BoxDecoration cardDecoration({Color? color, double? radius, List<BoxShadow>? shadows}) {
    return BoxDecoration(color: color ?? AppThemeColors.white, borderRadius: BorderRadius.circular(radius ?? radiusXXLarge), boxShadow: shadows ?? shadowLarge);
  }

  // Dark Card Decoration (Navy)
  static BoxDecoration darkCardDecoration({double? radius}) {
    return BoxDecoration(color: AppThemeColors.darkNavy, borderRadius: BorderRadius.circular(radius ?? radiusXXLarge));
  }

  // Input Field Decoration
  static BoxDecoration inputDecoration({Color? borderColor, double? radius}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius ?? radiusMedium),
      border: Border.all(color: borderColor ?? AppThemeColors.borderOrange, width: 1.5),
    );
  }

  // Button Decoration
  static BoxDecoration buttonDecoration({Color? color, double? radius}) {
    return BoxDecoration(color: color ?? AppThemeColors.primaryOrange, borderRadius: BorderRadius.circular(radius ?? radiusLarge));
  }
}

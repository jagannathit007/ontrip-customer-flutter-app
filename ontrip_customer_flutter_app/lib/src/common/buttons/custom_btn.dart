import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';

import '../../../app_export.dart';

class CustomBtn extends StatelessWidget {
  final double? width, height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final GestureTapCallback? onTap;
  final Widget? prefix, suffix;
  final double prefixDistance, suffixDistance, radius, borderWidth;
  final String? text;
  final Color? bgColor, borderColor, loadingIndicatorColor;
  final bool isLoading;
  const CustomBtn({
    super.key,
    this.width,
    this.height,
    this.onTap,
    this.padding,
    this.style,
    this.prefix,
    this.suffix,
    this.prefixDistance = 10,
    this.suffixDistance = 10,
    this.radius = 6,
    this.borderWidth = 1.8,
    this.text,
    this.bgColor,
    this.borderColor,
    this.isLoading = false,
    this.loadingIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 40,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          padding: padding ?? const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: borderColor ?? AppThemeColors.primaryOrange, width: borderWidth),
          ),
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor,
        ),
        child: isLoading
            ? CustomLoadingIndicator(color: loadingIndicatorColor ?? Constant.instance.white)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefix != null) ...[prefix!, Constant.instance.square.copyWith(height: 0, width: prefixDistance)],
                  Flexible(
                    child: Text(text ?? "Save", style: style ?? AppTextStyle.bold.copyWith(fontSize: 14.5, color: Constant.instance.white)),
                  ),
                  if (suffix != null) ...[Constant.instance.square.copyWith(height: 0, width: suffixDistance), suffix!],
                ],
              ),
      ),
    );
  }
}

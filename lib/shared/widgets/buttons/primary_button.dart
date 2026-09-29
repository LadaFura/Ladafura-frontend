import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bouton d'action principal du Design System LADAFURA
/// Rayon de courbure : 8 px, Hauteur : 48 px, Typographie : Poppins 15 px / 500 Medium
/// Compatible nativement Thème Clair et Thème Sombre.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark ? AppColors.darkPrimary : AppColors.primary;
    final defaultFg = isDark ? AppColors.darkBackground : Colors.white;

    final bgColor = backgroundColor ?? defaultBg;
    final fgColor = textColor ?? defaultFg;

    final disabledBg = isDark ? AppColors.darkSurfaceVariant : AppColors.border;
    final disabledFg = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return SizedBox(
      width: width ?? double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: disabledBg,
          disabledForegroundColor: disabledFg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppDimensions.space8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      color: fgColor,
                      fontWeight: isDark ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bouton secondaire / outline du Design System LADAFURA
/// Rayon : 8 px, Hauteur : 48 px, Poppins 15 px / 500 Medium
/// Compatible nativement Thème Clair et Thème Sombre.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Widget? icon;
  final double? width;
  final bool isNeutral;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.icon,
    this.width,
  }) : isNeutral = false;

  /// Variante neutre / annuler (bordure douce, fond surface)
  const SecondaryButton.neutral({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.icon,
  })  : borderColor = null,
        textColor = null,
        backgroundColor = null,
        isNeutral = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color defaultBorder;
    final Color defaultText;
    final Color defaultBg;

    if (isNeutral) {
      defaultBorder = isDark ? AppColors.darkBorder : AppColors.border;
      defaultText = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
      defaultBg = isDark ? AppColors.darkSurface : Colors.white;
    } else {
      defaultBorder = isDark ? AppColors.darkPrimary : AppColors.primary;
      defaultText = isDark ? AppColors.darkPrimary : AppColors.primary;
      defaultBg = isDark
          ? AppColors.darkPrimaryContainer.withValues(alpha: 0.4)
          : AppColors.primaryLight.withValues(alpha: 0.5);
    }

    final borderCol = borderColor ?? defaultBorder;
    final textCol = textColor ?? defaultText;
    final bgCol = backgroundColor ?? defaultBg;

    return SizedBox(
      width: width ?? double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgCol,
          foregroundColor: textCol,
          side: BorderSide(color: borderCol, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppDimensions.space8),
            ],
            Text(
              label,
              style: AppTextStyles.button.copyWith(color: textCol),
            ),
          ],
        ),
      ),
    );
  }
}

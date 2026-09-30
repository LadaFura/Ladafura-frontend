import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bouton d'action principal de LADAFURA.
///
/// Caractéristiques :
/// - Hauteur standardisée de 48 px conforme à [AppDimensions.buttonHeight].
/// - Gestion intégrée de l'état de chargement ([isLoading]) avec indicateur centré.
/// - Support d'une icône optionnelle à gauche ([icon]).
/// - Adaptation automatique aux thèmes clair et sombre.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final dynamic icon;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  Widget? _buildIcon(Color color) {
    if (icon == null) return null;
    if (icon is IconData) {
      return Icon(icon as IconData, size: 20, color: color);
    }
    if (icon is Widget) {
      return icon as Widget;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        backgroundColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary);
    final fg = textColor ?? (isDark ? AppColors.darkBackground : Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor:
              isDark ? AppColors.darkSurface : AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    _buildIcon(fg)!,
                    const SizedBox(width: AppDimensions.space8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.button.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

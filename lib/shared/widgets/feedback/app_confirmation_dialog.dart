import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Dialogue générique et moderne de confirmation pour les actions importantes de LADAFURA.
class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmButtonColor;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Annuler',
    this.icon,
    this.iconColor,
    this.confirmButtonColor,
    this.isDestructive = false,
    required this.onConfirm,
  });

  /// Méthode statique utilitaire pour afficher la boîte de dialogue.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    bool isDestructive = false,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        iconColor: iconColor,
        confirmButtonColor: confirmButtonColor,
        isDestructive: isDestructive,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ?? (isDestructive ? AppColors.danger : AppColors.primary);
    final effectiveConfirmColor =
        confirmButtonColor ?? (isDestructive ? AppColors.danger : AppColors.primary);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ],
            Text(
              title,
              style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              message,
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: effectiveConfirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


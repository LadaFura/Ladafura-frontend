import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Boîte de dialogue de confirmation avant déconnexion utilisant le Design System.
class ProfilLogoutDialog extends StatelessWidget {
  const ProfilLogoutDialog({super.key});

  /// Méthode d'ouverture pratique de la boîte de dialogue.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => const ProfilLogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      title: Row(
        children: [
          const Icon(
            Icons.logout_rounded,
            color: AppColors.danger,
            size: AppDimensions.iconSizeLarge,
          ),
          const SizedBox(width: AppDimensions.space8),
          Text(
            'Déconnexion',
            style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
          ),
        ],
      ),
      content: Text(
        'Voulez-vous vraiment vous déconnecter de votre compte LADAFURA ?',
        style: isDark
            ? AppTextStyles.bodySecondaryDark
            : AppTextStyles.bodySecondary,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Annuler',
            style: (isDark
                    ? AppTextStyles.button
                    : AppTextStyles.button)
                .copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Se déconnecter',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }
}

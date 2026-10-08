import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Section regroupant l'accès aux Paramètres et la Déconnexion.
class ProfilReglagesSection extends StatelessWidget {
  final VoidCallback onTapParametres;
  final VoidCallback onTapLogout;

  const ProfilReglagesSection({
    super.key,
    required this.onTapParametres,
    required this.onTapLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space16,
              AppDimensions.space16,
              AppDimensions.space8,
            ),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Préférences & Sécurité',
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                      .copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Paramètres
          ListTile(
            onTap: onTapParametres,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: Colors.purple, size: 20),
            ),
            title: Text(
              'Paramètres',
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Apparence, thème et informations',
              style:
                  (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ),
          const Divider(height: 1),

          // Se déconnecter
          ListTile(
            onTap: onTapLogout,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.danger, size: 20),
            ),
            title: const Text(
              'Se déconnecter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.danger,
              ),
            ),
            subtitle: Text(
              'Fermer la session actuelle',
              style:
                  (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

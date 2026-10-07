import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Section regroupant les entrées d'activité de l'utilisateur :
/// Mes commandes, Mes favoris et Notifications avec compteurs réels.
class ProfilActiviteSection extends StatelessWidget {
  final int totalCommandes;
  final int totalFavoris;
  final int unreadNotifications;
  final VoidCallback onTapCommandes;
  final VoidCallback onTapFavoris;
  final VoidCallback onTapNotifications;

  const ProfilActiviteSection({
    super.key,
    required this.totalCommandes,
    required this.totalFavoris,
    required this.unreadNotifications,
    required this.onTapCommandes,
    required this.onTapFavoris,
    required this.onTapNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

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
                Icon(Icons.insights_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Mon activité',
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                      .copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 1. Mes commandes
          ListTile(
            onTap: onTapCommandes,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.blue, size: 20),
            ),
            title: Text(
              'Mes commandes',
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Historique et suivi de livraison',
              style:
                  (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (totalCommandes > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalCommandes',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. Mes favoris
          ListTile(
            onTap: onTapFavoris,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite_outline_rounded,
                  color: Colors.redAccent, size: 20),
            ),
            title: Text(
              'Mes favoris',
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Plantes et remèdes enregistrés',
              style:
                  (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (totalFavoris > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalFavoris',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
          const Divider(height: 1),

          // 3. Notifications
          ListTile(
            onTap: onTapNotifications,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: Colors.amber, size: 20),
            ),
            title: Text(
              'Notifications',
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Alertes de commandes et actualités',
              style:
                  (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (unreadNotifications > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Carte informative pour le retrait au comptoir (pickup) avec l'adresse de l'officine.
class CommandePickupInfoCard extends StatelessWidget {
  final String? adresseOfficine;

  const CommandePickupInfoCard({
    super.key,
    this.adresseOfficine,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Retrait au comptoir (Pickup)',
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  adresseOfficine ??
                      'Votre commande sera mise à disposition directement au comptoir de l\'officine sans frais supplémentaires.',
                  style: (isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption)
                      .copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


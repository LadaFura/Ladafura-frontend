import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

class CommandeCard extends StatelessWidget {
  final CommandeModel commande;

  const CommandeCard({super.key, required this.commande});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${commande.numeroCommande}',
                style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                ),
                child: Text(
                  commande.statut,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.darkAccent : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            '${commande.items.length} article(s)',
            style: isDark ? AppTextStyles.captionDark : AppTextStyles.caption,
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant total :',
                style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
              ),
              Text(
                '${commande.montantTotal.toStringAsFixed(0)} FCFA',
                style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkAccent : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

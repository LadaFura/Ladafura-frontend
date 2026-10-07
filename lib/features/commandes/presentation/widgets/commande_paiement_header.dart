import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

/// En-tête récapitulatif de la commande affiché sur l'écran de paiement.
class CommandePaiementHeader extends StatelessWidget {
  final CommandeDetailModel commande;

  const CommandePaiementHeader({
    super.key,
    required this.commande,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${commande.numero}',
                style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  commande.modeRetrait,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                commande.nomPharmacopee,
                style: (isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption)
                    .copyWith(fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant total à régler :',
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                    .copyWith(fontSize: 15),
              ),
              Text(
                commande.montantTotalFormate,
                style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


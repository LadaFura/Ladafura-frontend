import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

/// Carte affichant le sous-total, les frais de livraison et le montant total TTC de la commande.
class CommandeDetailTotalCard extends StatelessWidget {
  final CommandeDetailModel commande;

  const CommandeDetailTotalCard({
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
                'Sous-total produits :',
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                    .copyWith(fontSize: 13),
              ),
              Text(
                commande.totalProduitFormate,
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frais de mise à disposition :',
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                    .copyWith(fontSize: 13),
              ),
              Text(
                commande.montantLivraisonFormate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: commande.montantLivraison <= 0
                      ? Colors.green
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant total TTC :',
                style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                commande.montantTotalFormate,
                style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


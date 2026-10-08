import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

/// Carte récapitulative détaillée des articles, du sous-total et des frais de livraison de la commande.
class CommandeRecapitulatifCard extends StatelessWidget {
  final CommandeRecapitulatifModel? recap;
  final bool isLoading;

  const CommandeRecapitulatifCard({
    super.key,
    required this.recap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    if (isLoading && recap == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recap == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 16 : 4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Liste des articles
          ...recap!.lignes.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${l.quantite}x ${l.nomProduit}',
                        style: (isDark
                                ? AppTextStyles.bodyDark
                                : AppTextStyles.body)
                            .copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      l.sousTotalFormate,
                      style: (isDark
                              ? AppTextStyles.bodyDark
                              : AppTextStyles.body)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
          Divider(
            height: 16,
            thickness: 1,
            color: isDark
                ? AppColors.darkBorder
                : AppColors.border.withAlpha(120),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sous-total produits :',
                  style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body),
              Text(recap!.totalProduitsFormate,
                  style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Frais de mise à disposition :',
                  style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body),
              Text(
                recap!.fraisLivraisonFormate,
                style: TextStyle(
                  color: recap!.fraisLivraison <= 0
                      ? Colors.green
                      : (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(
            height: 20,
            thickness: 1,
            color: isDark
                ? AppColors.darkBorder
                : AppColors.border.withAlpha(120),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total à régler :',
                style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                recap!.montantTotalFormate,
                style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2)
                    .copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


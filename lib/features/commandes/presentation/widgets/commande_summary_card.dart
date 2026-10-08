import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';
import 'commande_statut_badge.dart';

/// Carte représentant une commande dans l'historique "Mes Commandes".
class CommandeSummaryCard extends StatelessWidget {
  final CommandeSummaryModel commande;
  final VoidCallback onTap;

  const CommandeSummaryCard({
    super.key,
    required this.commande,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.space12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Numéro et badge statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${commande.numero}',
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                CommandeStatutBadge(statut: commande.statut),
              ],
            ),
            const SizedBox(height: 8),

            // Officine et date
            Row(
              children: [
                Icon(Icons.storefront_rounded,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    commande.nomPharmacopee,
                    style: (isDark
                            ? AppTextStyles.bodyDark
                            : AppTextStyles.body)
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(commande.dateCommande),
                  style: (isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption)
                      .copyWith(fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space8),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.border.withAlpha(120),
            ),
            const SizedBox(height: AppDimensions.space8),

            // Mode de retrait, nombre d'articles et montant
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      commande.modeRetrait.toUpperCase() == 'LIVRAISON'
                          ? Icons.delivery_dining_rounded
                          : Icons.store_mall_directory_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${commande.modeRetrait} (${commande.nombreArticles} art.)',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      commande.montantTotalFormate,
                      style: (isDark
                              ? AppTextStyles.h4Dark
                              : AppTextStyles.h4)
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}


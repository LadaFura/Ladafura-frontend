import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

/// Carte affichant le mode d'acheminement (Livraison à domicile ou Retrait en magasin) et l'adresse associée.
class CommandeDetailModeRetraitCard extends StatelessWidget {
  final CommandeDetailModel commande;

  const CommandeDetailModeRetraitCard({
    super.key,
    required this.commande,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                commande.isLivraison
                    ? Icons.delivery_dining_rounded
                    : Icons.storefront_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Mise à disposition : ${commande.modeRetrait}',
                style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          if (commande.isLivraison && commande.adresseLivraison != null) ...[
            const SizedBox(height: 8),
            Text(
              'Adresse de livraison :',
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            Text(
              commande.adresseLivraison!,
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(fontSize: 13),
            ),
          ] else if (commande.isPickup && commande.adressePharmacopee != null) ...[
            const SizedBox(height: 8),
            Text(
              'Lieu de retrait au comptoir :',
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            Text(
              commande.adressePharmacopee!,
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

/// En-tête récapitulatif de la commande affiché sur l'écran de paiement.
class CommandePaiementHeader extends StatelessWidget {
  final CommandeDetailModel? commande;
  final String? nomPharmacopee;
  final String? modeRetrait;
  final String? montantTotalFormate;

  const CommandePaiementHeader({
    super.key,
    this.commande,
    this.nomPharmacopee,
    this.modeRetrait,
    this.montantTotalFormate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    final String affichageTitre = commande != null
        ? 'Commande #${commande!.numero}'
        : 'Règlement de votre panier';
    final String affichageMode =
        commande?.modeRetrait ?? modeRetrait ?? 'Retrait';
    final String affichagePharmacie =
        commande?.nomPharmacopee ?? nomPharmacopee ?? 'Pharmacopée';
    final String affichageTotal =
        commande?.montantTotalFormate ?? montantTotalFormate ?? '0 FCFA';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                affichageTitre,
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
                  affichageMode,
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
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                affichagePharmacie,
                style: (isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption)
                    .copyWith(fontSize: 13),
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
                'Montant total à régler :',
                style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                    .copyWith(fontSize: 15),
              ),
              Text(
                affichageTotal,
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


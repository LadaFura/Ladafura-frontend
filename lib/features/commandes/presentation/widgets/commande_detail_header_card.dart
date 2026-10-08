import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';
import 'commande_statut_badge.dart';

/// Carte d'en-tête affichant le numéro de commande, le statut, la date et le statut de paiement.
class CommandeDetailHeaderCard extends StatelessWidget {
  final CommandeDetailModel commande;

  const CommandeDetailHeaderCard({
    super.key,
    required this.commande,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Commande #${commande.numero}',
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 17),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              CommandeStatutBadge(statut: commande.statut),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Passée le ${_formatDate(commande.dateCommande)}',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontSize: 12),
          ),
          Divider(height: 16, thickness: 1, color: isDark ? AppColors.darkBorder : AppColors.border.withAlpha(120)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paiement :',
                style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                    .copyWith(fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (commande.statutPaiement == 'PAYE' ||
                          commande.statutPaiement == 'REUSSI')
                      ? Colors.green.withAlpha(25)
                      : Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  commande.statutPaiement == 'REUSSI' ||
                          commande.statutPaiement == 'PAYE'
                      ? 'Réglé'
                      : 'En attente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (commande.statutPaiement == 'PAYE' ||
                            commande.statutPaiement == 'REUSSI')
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


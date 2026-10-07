import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';
import '../../models/paiement_model.dart';
import 'commande_confirmation_info_row.dart';

/// Carte de reçu récapitulant les détails de la commande confirmée et du paiement.
class CommandeConfirmationReceiptCard extends StatelessWidget {
  final CommandeDetailModel commande;
  final PaiementResponseModel paiement;

  const CommandeConfirmationReceiptCard({
    super.key,
    required this.commande,
    required this.paiement,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CommandeConfirmationInfoRow(
            label: 'Numéro de commande',
            value: commande.numero,
            isBold: true,
          ),
          const Divider(height: 16),
          CommandeConfirmationInfoRow(
            label: 'Date & heure',
            value: _formatDate(commande.dateCommande),
          ),
          const Divider(height: 16),
          CommandeConfirmationInfoRow(
            label: 'Pharmacopée',
            value: commande.nomPharmacopee,
          ),
          const Divider(height: 16),
          CommandeConfirmationInfoRow(
            label: 'Mode de retrait',
            value: commande.modeRetrait,
          ),
          const Divider(height: 16),
          CommandeConfirmationInfoRow(
            label: 'Règlement',
            value: paiement.libelleMethode.isNotEmpty
                ? paiement.libelleMethode
                : paiement.methode,
          ),
          const Divider(height: 16),
          CommandeConfirmationInfoRow(
            label: 'Statut paiement',
            value: paiement.statut == 'REUSSI'
                ? 'Validé'
                : (paiement.statut == 'EN_ATTENTE'
                    ? 'En attente'
                    : paiement.statut),
            valueColor: paiement.statut == 'REUSSI'
                ? Colors.green
                : Colors.orange,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant total :',
                style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                commande.montantTotalFormate,
                style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2).copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


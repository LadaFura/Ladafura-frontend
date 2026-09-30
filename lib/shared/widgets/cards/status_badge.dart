import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../enums/statut_collecte.dart';
import '../../enums/statut_commande.dart';

/// Badge d'état coloré dynamique conforme aux exigences d'accessibilité ENF11.
///
/// Affiche une pastille circulaire de couleur accompagnée du libellé de statut.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  /// Usine pour les statuts de collectes de terrain (US-13 & US-17).
  factory StatusBadge.collecte(StatutCollecte statut) {
    return StatusBadge(
      label: statut.label,
      color: statut.badgeColor,
    );
  }

  /// Usine pour les statuts de commandes clients (US-11 & US-23).
  factory StatusBadge.commande(StatutCommande statut) {
    return StatusBadge(
      label: statut.label,
      color: statut.badgeColor,
    );
  }

  /// Badge certifié ENF11 : Usage traditionnel rapporté
  const StatusBadge.traditionnel({super.key})
      : label = 'Usage traditionnel rapporté',
        color = AppColors.badgeTraditionnelText,
        backgroundColor = AppColors.badgeTraditionnelBg;

  /// Badge certifié ENF11 : Étude scientifique disponible
  const StatusBadge.scientifique({super.key})
      : label = 'Étude scientifique disponible',
        color = AppColors.badgeScientifiqueText,
        backgroundColor = AppColors.badgeScientifiqueBg;

  /// Badge certifié ENF11 : Information institutionnelle
  const StatusBadge.institutionnel({super.key})
      : label = 'Information institutionnelle',
        color = AppColors.badgeInstitutionnelText,
        backgroundColor = AppColors.badgeInstitutionnelBg;

  /// Badge certifié ENF11 : En cours de vérification
  const StatusBadge.enVerification({super.key})
      : label = 'En cours de vérification',
        color = AppColors.badgeVerificationText,
        backgroundColor = AppColors.badgeVerificationBg;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.space4),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

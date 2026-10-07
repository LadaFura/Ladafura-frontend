import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';


/// Badge moderne affichant le statut d'une commande selon l'enum Spring Boot `StatutCommande`.
class CommandeStatutBadge extends StatelessWidget {
  final String statut;

  const CommandeStatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final config = _getStatutConfig(statut);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: config.color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
        border: Border.all(color: config.color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: AppTextStyles.caption.copyWith(
              color: config.color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static _StatutBadgeConfig _getStatutConfig(String statut) {
    return switch (statut.toUpperCase()) {
      'EN_ATTENTE' => const _StatutBadgeConfig(
          label: 'En attente',
          color: Colors.amber,
          icon: Icons.hourglass_top_rounded,
        ),
      'CONFIRMEE' => const _StatutBadgeConfig(
          label: 'Confirmée',
          color: Colors.blue,
          icon: Icons.check_circle_outline_rounded,
        ),
      'PREPAREE' => const _StatutBadgeConfig(
          label: 'En préparation',
          color: Colors.teal,
          icon: Icons.inventory_2_outlined,
        ),
      'EN_LIVRAISON' => const _StatutBadgeConfig(
          label: 'En cours de livraison',
          color: Colors.deepPurple,
          icon: Icons.delivery_dining_rounded,
        ),
      'DISPONIBLE_PICKUP' => const _StatutBadgeConfig(
          label: 'Prête au retrait',
          color: Colors.indigo,
          icon: Icons.storefront_rounded,
        ),
      'LIVREE' => const _StatutBadgeConfig(
          label: 'Livrée',
          color: Colors.green,
          icon: Icons.verified_rounded,
        ),
      'RETIREE' => const _StatutBadgeConfig(
          label: 'Retirée',
          color: Colors.green,
          icon: Icons.task_alt_rounded,
        ),
      'ANNULEE' => const _StatutBadgeConfig(
          label: 'Annulée',
          color: Colors.redAccent,
          icon: Icons.cancel_outlined,
        ),
      _ => _StatutBadgeConfig(
          label: statut,
          color: Colors.grey,
          icon: Icons.info_outline,
        ),
    };
  }
}

class _StatutBadgeConfig {
  final String label;
  final Color color;
  final IconData icon;

  const _StatutBadgeConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

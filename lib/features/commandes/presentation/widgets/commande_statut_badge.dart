import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Badge moderne affichant le statut d'une commande selon l'enum Spring Boot `StatutCommande`.
class CommandeStatutBadge extends StatelessWidget {
  final String statut;

  const CommandeStatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getStatutConfig(statut, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
        border: Border.all(color: config.color.withValues(alpha: isDark ? 0.45 : 0.35)),
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

  static _StatutBadgeConfig _getStatutConfig(String statut, bool isDark) {
    final s = statut.toUpperCase();
    if (s == 'EN_ATTENTE' || s == 'ATTENTE' || s == 'PENDING') {
      return _StatutBadgeConfig(
        label: 'En attente',
        color: isDark ? AppColors.darkWarning : const Color(0xFFD97706),
        icon: Icons.hourglass_top_rounded,
      );
    } else if (s == 'CONFIRMEE') {
      return _StatutBadgeConfig(
        label: 'Confirmée',
        color: isDark ? AppColors.darkInfo : AppColors.info,
        icon: Icons.check_circle_outline_rounded,
      );
    } else if (s == 'PREPAREE' || s == 'EN_PREPARATION') {
      return _StatutBadgeConfig(
        label: 'En préparation',
        color: isDark ? const Color(0xFF2DD4BF) : Colors.teal.shade700,
        icon: Icons.inventory_2_outlined,
      );
    } else if (s == 'EN_LIVRAISON') {
      return _StatutBadgeConfig(
        label: 'En cours de livraison',
        color: isDark ? const Color(0xFFA78BFA) : Colors.deepPurple,
        icon: Icons.delivery_dining_rounded,
      );
    } else if (s == 'DISPONIBLE_PICKUP') {
      return _StatutBadgeConfig(
        label: 'Prête au retrait',
        color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
        icon: Icons.storefront_rounded,
      );
    } else if (s == 'LIVREE') {
      return _StatutBadgeConfig(
        label: 'Livrée',
        color: isDark ? AppColors.darkSuccess : AppColors.success,
        icon: Icons.verified_rounded,
      );
    } else if (s == 'RETIREE') {
      return _StatutBadgeConfig(
        label: 'Retirée',
        color: isDark ? AppColors.darkSuccess : AppColors.success,
        icon: Icons.task_alt_rounded,
      );
    } else if (s == 'ANNULEE' || s == 'REJETEE' || s == 'REFUSEE' || s == 'ECHOUEE') {
      return _StatutBadgeConfig(
        label: s == 'REJETEE' ? 'Rejetée' : (s == 'REFUSEE' ? 'Refusée' : 'Annulée'),
        color: isDark ? AppColors.darkDanger : AppColors.danger,
        icon: Icons.cancel_outlined,
      );
    } else {
      return _StatutBadgeConfig(
        label: statut,
        color: isDark ? Colors.grey[400]! : Colors.grey[700]!,
        icon: Icons.info_outline,
      );
    }
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

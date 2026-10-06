import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/pharmacopee_detail_model.dart';

/// Composant sélecteur des modes de retrait conformes aux 3 cas requis par l'UX LADAFURA :
/// - Cas 1 : Propose Livraison ET Retrait sur place -> Deux onglets sélectionnables [🚚 Livraison] [📍 Retrait sur place]
/// - Cas 2 : Uniquement Retrait sur place -> Affiche [📍 Retrait sur place] + encadré explicatif
/// - Cas 3 : Uniquement Livraison -> Affiche [🚚 Livraison]
class PharmacopeeModesRetraitSelector extends StatelessWidget {
  final List<PharmacopeeModeRetraitModel> modes;
  final String selectedMode; // 'ALL', 'LIVRAISON', 'PICKUP'
  final ValueChanged<String> onModeChanged;

  const PharmacopeeModesRetraitSelector({
    super.key,
    required this.modes,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final livraison = modes.where((m) => m.isLivraison && m.actif == true).firstOrNull;
    final pickup = modes.where((m) => m.isPickup && m.actif == true).firstOrNull;

    final hasLivraison = livraison != null;
    final hasPickup = pickup != null;

    // Si aucun mode n'est configuré dans le backend, on n'affiche rien de statique/fictif
    if (!hasLivraison && !hasPickup) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Modes de réception',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Cas 1 : Propose à la fois Livraison ET Retrait sur place
          if (hasLivraison && hasPickup) ...[
            Row(
              children: [
                Expanded(
                  child: _buildRetraitTab(
                    context: context,
                    icon: Icons.delivery_dining_rounded,
                    title: 'Livraison',
                    subtitle: livraison.fraisFormate,
                    isSelected: selectedMode == 'LIVRAISON' || selectedMode == 'ALL',
                    isDark: isDark,
                    onTap: () => onModeChanged('LIVRAISON'),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: _buildRetraitTab(
                    context: context,
                    icon: Icons.storefront_outlined,
                    title: 'Retrait sur place',
                    subtitle: pickup.fraisFormate,
                    isSelected: selectedMode == 'PICKUP',
                    isDark: isDark,
                    onTap: () => onModeChanged('PICKUP'),
                  ),
                ),
              ],
            ),
          ]

          // Cas 2 : Propose UNIQUEMENT Retrait sur place
          else if (!hasLivraison && hasPickup) ...[
            _buildRetraitTab(
              context: context,
              icon: Icons.storefront_outlined,
              title: 'Retrait sur place',
              subtitle: pickup.fraisFormate,
              isSelected: true,
              isDark: isDark,
              onTap: () {},
            ),
          ]

          // Cas 3 : Propose UNIQUEMENT Livraison
          else if (hasLivraison && !hasPickup) ...[
            _buildRetraitTab(
              context: context,
              icon: Icons.delivery_dining_rounded,
              title: 'Livraison à domicile',
              subtitle: livraison.fraisFormate,
              isSelected: true,
              isDark: isDark,
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRetraitTab({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primary.withAlpha(50)
                  : AppColors.primaryLight)
              : (isDark
                  ? Colors.white.withAlpha(8)
                  : const Color(0xFFF8FAF9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.textPrimary)
                          : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}


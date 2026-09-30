import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';

/// Section des 4 catégories principales de LADAFURA : Pharmacopée, Fura, Plante, Maladie.
class HomeQuickCategories extends StatelessWidget {
  final VoidCallback onPharmacopeeTap;
  final VoidCallback onFuraTap;
  final VoidCallback onPlanteTap;
  final VoidCallback onMaladieTap;

  const HomeQuickCategories({
    super.key,
    required this.onPharmacopeeTap,
    required this.onFuraTap,
    required this.onPlanteTap,
    required this.onMaladieTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CategoryItem(
            label: 'Pharmacopée',
            icon: Icons.storefront_rounded,
            backgroundColor: isDark
                ? const Color(0xFF1E3A2F)
                : const Color(0xFFD7EFE6),
            iconColor: isDark
                ? const Color(0xFF2ECC71)
                : const Color(0xFF1B5E20),
            onTap: onPharmacopeeTap,
          ),
          _CategoryItem(
            label: 'Fura',
            icon: Icons.medication_rounded,
            backgroundColor: isDark
                ? const Color(0xFF1A365D)
                : const Color(0xFFD9EEF9),
            iconColor: isDark
                ? const Color(0xFF63B3ED)
                : const Color(0xFF1976D2),
            onTap: onFuraTap,
          ),
          _CategoryItem(
            label: 'Plante',
            icon: Icons.eco_rounded,
            backgroundColor: isDark
                ? const Color(0xFF1E3E2B)
                : const Color(0xFFE2F4E9),
            iconColor: isDark
                ? const Color(0xFF48BB78)
                : const Color(0xFF2E7D32),
            onTap: onPlanteTap,
          ),
          _CategoryItem(
            label: 'Maladie',
            icon: Icons.add_box_rounded,
            backgroundColor: isDark
                ? const Color(0xFF4A1E24)
                : const Color(0xFFFBE4E4),
            iconColor: isDark
                ? const Color(0xFFFC8181)
                : const Color(0xFFDC4747),
            onTap: onMaladieTap,
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

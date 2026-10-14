import 'package:flutter/material.dart';

/// Les 4 catégories principales de LADAFURA fidèles à la maquette :
/// Plantes, Produits, Maladies, Pharmacopées.
class HomeQuickCategories extends StatelessWidget {
  final VoidCallback onPlantesTap;
  final VoidCallback onProduitsTap;
  final VoidCallback onMaladiesTap;
  final VoidCallback onPharmacopeesTap;

  const HomeQuickCategories({
    super.key,
    required this.onPlantesTap,
    required this.onProduitsTap,
    required this.onMaladiesTap,
    required this.onPharmacopeesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryItem(
          label: 'Plantes',
          icon: Icons.eco_rounded,
          onTap: onPlantesTap,
        ),
        _CategoryItem(
          label: 'Produits',
          icon: Icons.sanitizer_rounded,
          onTap: onProduitsTap,
        ),
        _CategoryItem(
          label: 'Maladies',
          icon: Icons.add_circle_rounded,
          onTap: onMaladiesTap,
        ),
        _CategoryItem(
          label: 'Pharmacopées',
          icon: Icons.location_on_rounded,
          onTap: onPharmacopeesTap,
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palette fidèle à la maquette :
    // Fond : cercle vert menthe très doux
    // Icône : vert forêt profond
    final bgColor = isDark ? const Color(0xFF143324) : const Color(0xFFE9F3EB);
    final iconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF0C5231);
    final textColor = isDark ? Colors.white : const Color(0xFF1F2923);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cercle vert pastel avec icône verte
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E4632)
                      : const Color(0xFFDBEADB),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 7),

            // Libellé de catégorie
            SizedBox(
              width: 66,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

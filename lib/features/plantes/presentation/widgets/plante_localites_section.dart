import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/plante_model.dart';

/// Section présentant la répartition géographique de la plante (régions, cercles, communes du Mali).
class PlanteLocalitesSection extends StatelessWidget {
  final List<PopulationPlanteLocaliteModel> localites;

  const PlanteLocalitesSection({
    super.key,
    required this.localites,
  });

  @override
  Widget build(BuildContext context) {
    if (localites.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête (Design sobre et moderne)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition Géographique au Mali',
              style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Zones et localités de cueillette identifiées sur le terrain',
              style: (isDark
                      ? AppTextStyles.captionDark
                      : AppTextStyles.caption)
                  .copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space12),

        Wrap(
          spacing: AppDimensions.space8,
          runSpacing: AppDimensions.space8,
          children: localites.map((loc) {
            final parts = <String>[];
            if (loc.region.isNotEmpty) parts.add(loc.region);
            if (loc.cercle != null && loc.cercle!.isNotEmpty) {
              parts.add('Cercle de ${loc.cercle}');
            }
            if (loc.commune != null && loc.commune!.isNotEmpty) {
              parts.add('(${loc.commune})');
            }

            final label = parts.join(' • ');

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: (isDark
                        ? AppTextStyles.captionDark
                        : AppTextStyles.caption)
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}


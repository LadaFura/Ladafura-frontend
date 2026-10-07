import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/plante_model.dart';

/// Section présentant les maladies, symptômes et indications thérapeutiques traditionnellement associés.
class PlanteMaladiesSection extends StatelessWidget {
  final List<PopulationPlanteMaladieModel> maladies;

  const PlanteMaladiesSection({
    super.key,
    required this.maladies,
  });

  @override
  Widget build(BuildContext context) {
    if (maladies.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccent : AppColors.primary)
                    .withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.healing_rounded,
                color: isDark ? AppColors.darkAccent : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Indications & Pathologies Associées',
                    style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                        .copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Symptômes et affections couramment traités selon les praticiens',
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
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space12),

        // Badges élégants
        Wrap(
          spacing: AppDimensions.space8,
          runSpacing: AppDimensions.space8,
          children: maladies.map((m) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.primary.withAlpha(60),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.green.shade100)
                        .withAlpha(25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.nom,
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  if (m.description != null && m.description!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '• ${m.description!}',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/plante_model.dart';

class EtudesScientifiquesCard extends StatelessWidget {
  final List<PopulationEtudeScientifiqueModel> etudes;

  const EtudesScientifiquesCard({
    super.key,
    required this.etudes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (etudes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.science_outlined,
                color: AppColors.textMuted, size: 20),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: Text(
                'Aucune étude scientifique indexée pour le moment.',
                style: isDark ? AppTextStyles.captionDark : AppTextStyles.caption,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.science_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'Études Scientifiques & Validations (${etudes.length})',
              style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),
        ...etudes.map((e) => _buildEtudeCard(context, e, isDark)),
      ],
    );
  }

  Widget _buildEtudeCard(
    BuildContext context,
    PopulationEtudeScientifiqueModel etude,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.space16),
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
          // Titre de l'étude
          Text(
            etude.titre,
            style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),

          // Auteurs et date
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: AppDimensions.space4),
              Expanded(
                child: Text(
                  '${etude.auteurs ?? "Chercheurs"}${etude.annee != null ? " (${etude.annee})" : ""}',
                  style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          if (etude.revueOuInstitution != null &&
              etude.revueOuInstitution!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space4),
            Row(
              children: [
                const Icon(Icons.menu_book_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: AppDimensions.space4),
                Expanded(
                  child: Text(
                    etude.revueOuInstitution!,
                    style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption),
                  ),
                ),
              ],
            ),
          ],

          // Résumé / Abstract
          if (etude.resume != null && etude.resume!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              etude.resume!,
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
                fontSize: 13,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

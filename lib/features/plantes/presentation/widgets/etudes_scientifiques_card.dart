import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/plante_model.dart';

/// Carte moderne présentant les études scientifiques universitaires et cliniques.
/// Clarté absolue : distinction rigoureuse avec les savoirs traditionnels.
/// Inclut :
/// - Titre de l'étude & auteurs
/// - Année et revue/institution
/// - Résumé (abstract)
/// - Lien vers la publication scientifique
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
                'Aucune publication scientifique répertoriée dans la base pour le moment.',
                style:
                    isDark ? AppTextStyles.captionDark : AppTextStyles.caption,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section (Design moderne et épuré)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Études Scientifiques & Validations',
              style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              '${etudes.length} publication(s) universitaire(s) indexée(s)',
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
          color: isDark
              ? AppColors.darkBorder
              : AppColors.primary.withAlpha(40),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.green.shade100)
                .withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de l'étude (Design sobre et moderne)
          Text(
            etude.titre,
            style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                .copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: AppDimensions.space8),

          // Métadonnées : Auteurs, Année, Revue
          Wrap(
            spacing: AppDimensions.space12,
            runSpacing: AppDimensions.space8,
            children: [
              if (etude.auteurs != null && etude.auteurs!.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          etude.auteurs!,
                          style: (isDark
                                  ? AppTextStyles.captionDark
                                  : AppTextStyles.caption)
                              .copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (etude.annee != null && etude.annee!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      etude.annee!,
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              if (etude.revueOuInstitution != null &&
                  etude.revueOuInstitution!.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          etude.revueOuInstitution!,
                          style: (isDark
                                  ? AppTextStyles.captionDark
                                  : AppTextStyles.caption)
                              .copyWith(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Résumé (Abstract)
          if (etude.resume != null && etude.resume!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant.withAlpha(120),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
              child: Text(
                etude.resume!,
                style: (isDark
                        ? AppTextStyles.bodyDark
                        : AppTextStyles.body)
                    .copyWith(
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

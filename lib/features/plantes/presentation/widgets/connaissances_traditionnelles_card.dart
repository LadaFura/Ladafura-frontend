import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/formatted_html_text.dart';
import '../../models/plante_model.dart';

/// Carte moderne présentant les savoirs traditionnels et usages ancestraux rapportés.
/// Inclut :
/// - Icônes explicites pour les parties de plantes utilisées (feuilles, écorce, racines)
/// - Modes de préparation clairs (décoction, infusion, macération)
/// - Précautions d'emploi et posologie
/// - Badge déontologique "Usage Traditionnel Répertorié"
class ConnaissancesTraditionnellesCard extends StatelessWidget {
  final List<PopulationConnaissanceTraditionnelleModel> connaissances;

  const ConnaissancesTraditionnellesCard({
    super.key,
    required this.connaissances,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (connaissances.isEmpty) {
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
            const Icon(Icons.info_outline_rounded,
                color: AppColors.textMuted, size: 20),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: Text(
                'Aucune connaissance traditionnelle documentée pour le moment.',
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
              'Savoirs Traditionnels & Usages',
              style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              '${connaissances.length} usage(s) documenté(s) par les praticiens',
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

        ...connaissances.map((c) => _buildItemCard(context, c, isDark)),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    PopulationConnaissanceTraditionnelleModel item,
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
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre / Usage principal (Design épuré et lisible)
          Text(
            item.usageRapporte,
            style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                .copyWith(
              color: isDark
                  ? AppColors.darkPrimary
                  : AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: AppDimensions.space12),

          // Grille des paramètres d'usage : Partie utilisée & Préparation
          Wrap(
            spacing: AppDimensions.space12,
            runSpacing: AppDimensions.space8,
            children: [
              if (item.partieUtilisee != null &&
                  item.partieUtilisee!.isNotEmpty)
                _buildTagChip(
                  icon: Icons.eco_outlined,
                  label: item.partieUtilisee!.contains(',')
                      ? 'Parties : ${item.partieUtilisee}'
                      : 'Partie : ${item.partieUtilisee}',
                  isDark: isDark,
                ),
              if (item.modePreparation != null &&
                  item.modePreparation!.isNotEmpty)
                _buildTagChip(
                  icon: Icons.coffee_maker_outlined,
                  label: 'Préparation : ${FormattedHtmlText.stripHtml(item.modePreparation!)}',
                  isDark: isDark,
                ),
              if (item.posologie != null && item.posologie!.isNotEmpty)
                _buildTagChip(
                  icon: Icons.medical_services_outlined,
                  label: 'Posologie : ${FormattedHtmlText.stripHtml(item.posologie!)}',
                  isDark: isDark,
                ),
            ],
          ),

          // Précautions d'usage
          if (item.precautions != null && item.precautions!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                    .withAlpha(20),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                border: Border.all(
                  color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                      .withAlpha(60),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: FormattedHtmlText(
                      'Précautions : ${item.precautions}',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 4. Source traditionnelle (Tradithérapeute, informateur, spécialité, localité)
          _buildSourceSection(item, isDark),
        ],
      ),
    );
  }

  Widget _buildTagChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
            .copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildSourceSection(
    PopulationConnaissanceTraditionnelleModel item,
    bool isDark,
  ) {
    // Déterminer le nom de la source ou fallback
    final sourceNom = item.sourceNom?.trim().isNotEmpty == true
        ? item.sourceNom!
        : (item.informateurSource?.trim().isNotEmpty == true
            ? item.informateurSource!
            : null);

    if (sourceNom == null &&
        (item.sourceSpecialite == null || item.sourceSpecialite!.isEmpty) &&
        (item.sourceLocalite == null || item.sourceLocalite!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_pin_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Source traditionnelle vérifiée',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (sourceNom != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sourceNom,
                    style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                        .copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (item.sourceSpecialite != null &&
                    item.sourceSpecialite!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.sourceSpecialite!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
                if (item.sourceLocalite != null &&
                    item.sourceLocalite!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.sourceLocalite!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

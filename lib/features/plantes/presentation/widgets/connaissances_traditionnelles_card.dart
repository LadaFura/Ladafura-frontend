import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
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
          color: isDark
              ? AppColors.darkBorder
              : AppColors.accent.withAlpha(40),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.amber.shade100)
                .withAlpha(25),
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
                  label: 'Partie : ${item.partieUtilisee}',
                  isDark: isDark,
                ),
              if (item.modePreparation != null &&
                  item.modePreparation!.isNotEmpty)
                _buildTagChip(
                  icon: Icons.coffee_maker_outlined,
                  label: 'Préparation : ${item.modePreparation}',
                  isDark: isDark,
                ),
              if (item.posologie != null && item.posologie!.isNotEmpty)
                _buildTagChip(
                  icon: Icons.medical_services_outlined,
                  label: 'Posologie : ${item.posologie}',
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
                color: AppColors.warning.withAlpha(20),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                border: Border.all(
                  color: AppColors.warning.withAlpha(80),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Précautions : ${item.precautions}',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        color: isDark
                            ? Colors.amber.shade200
                            : const Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Source / Informateur
          if (item.informateurSource != null &&
              item.informateurSource!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Row(
              children: [
                Icon(
                  Icons.person_pin_circle_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Source traditionnelle : ${item.informateurSource}',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textMuted,
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
}

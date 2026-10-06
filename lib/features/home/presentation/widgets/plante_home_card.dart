import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/utils/image_utils.dart';
import 'package:ladafura_frontend_flutter/shared/models/plante_sommaire_model.dart';

/// Carte enrichie et spacieuse pour afficher une plante médicinale parmi les plus consultées.
/// Offre une meilleure lisibilité visuelle, une image botanique attrayante et un respect rigoureux du Design System.
class PlanteHomeCard extends StatelessWidget {
  final PlanteSommaireModel plante;
  final VoidCallback? onTap;

  const PlanteHomeCard({
    super.key,
    required this.plante,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image botanique généreuse avec dégradé subtil
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusCard),
              ),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: _buildImage(isDark),
              ),
            ),

            // Détails de la plante avec typographie Poppins et espacements standardisés
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom vernaculaire principal
                  Text(
                    plante.nomVernaculairePrincipal,
                    style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                        .copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.space2),

                  // Nom scientifique en texte standard
                  Text(
                    plante.nomScientifique,
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.space8),

                  // Première maladie traitée sous forme de badge pill
                  if (plante.maladies.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space8,
                        vertical: AppDimensions.space2 + 1,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPrimaryContainer
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                      ),
                      child: Text(
                        plante.maladies.first,
                        style: AppTextStyles.badge.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: AppDimensions.space8),

                  // Savoirs traditionnels & études scientifiques
                  Wrap(
                    spacing: AppDimensions.space8,
                    runSpacing: AppDimensions.space4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_edu_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.accent,
                          ),
                          const SizedBox(width: AppDimensions.space4),
                          Text(
                            '${plante.nombreConnaissances} sav.',
                            style: (isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption)
                                .copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 13,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                          const SizedBox(width: AppDimensions.space4),
                          Text(
                            '${plante.nombreEtudesScientifiques} étud.',
                            style: (isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption)
                                .copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final resolved = ImageUtils.resolveImageUrl(plante.photoUrl);
    if (resolved != null) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackGradient(isDark),
      );
    }
    return _buildFallbackGradient(isDark);
  }

  Widget _buildFallbackGradient(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1E3A2F), Color(0xFF2A5944)]
              : const [AppColors.primaryLight, Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 44,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/utils/image_utils.dart';
import 'package:ladafura_frontend_flutter/features/recherche/models/global_search_response.dart';

/// Carte résultat d'une plante médicinale (Section #2 de la recherche).
/// Design étendu, esthétique et généreux conforme au Design System LADAFURA.
class SearchPlanteCard extends StatelessWidget {
  final PlanteSearchItem plante;
  final VoidCallback onTap;
  final bool isDark;

  const SearchPlanteCard({
    super.key,
    required this.plante,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Photo botanique généreuse (76 x 76 px) avec angles arrondis
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: _buildPlanteImage(),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),

                // 2. Contenu textuel complet & badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom scientifique en texte standard sans italique
                      Text(
                        plante.nomScientifique,
                        style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                            .copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.space2),

                      // Noms vernaculaires sous forme de texte clair
                      if (plante.nomsVernaculaires
                          .where((n) =>
                              n.trim().toLowerCase() != 'string' &&
                              n.trim().isNotEmpty)
                          .isNotEmpty) ...[
                        Text(
                          plante.nomsVernaculaires
                              .where((n) =>
                                  n.trim().toLowerCase() != 'string' &&
                                  n.trim().isNotEmpty)
                              .join(' • '),
                          style: (isDark
                                  ? AppTextStyles.bodySecondaryDark
                                  : AppTextStyles.bodySecondary)
                              .copyWith(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.space4),
                      ],

                      // Description succincte de la plante
                      if (plante.description != null &&
                          plante.description!.trim().isNotEmpty) ...[
                        Text(
                          plante.description!,
                          style: (isDark
                                  ? AppTextStyles.captionDark
                                  : AppTextStyles.caption)
                              .copyWith(
                            fontSize: 12,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),

                // 3. Flèche de navigation élégante
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.space8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanteImage() {
    final resolvedUrl = ImageUtils.resolveImageUrl(plante.photoUrl);
    if (resolvedUrl != null) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkPrimaryContainer
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
          size: 36,
        ),
      ),
    );
  }
}

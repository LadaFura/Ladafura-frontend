import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/utils/image_utils.dart';
import 'package:ladafura_frontend_flutter/shared/models/plante_sommaire_model.dart';

/// Carte enrichie et moderne pour afficher une plante médicinale parmi les plus consultées.
///
/// Inspirée du style d'interface épuré :
/// - Fond de carte arrondi blanc/sombre avec ombre douce
/// - Visuel botanique propre et centré
/// - Nom de la plante en gras bien lisible
/// - Sous-titre botanique (nom scientifique)
/// - Indicateur d'usage ou délai
/// - Badges des savoirs traditionnels et études avec bouton circulaire d'exploration '+'
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
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor =
        isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);

    return Container(
      width: 175,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        border: Border.all(
          color: borderColor,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Zone Image botanique centrée
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space4),
                      child: _buildImage(isDark),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.space8),

                // 2. Nom vernaculaire principal
                Text(
                  plante.nomVernaculairePrincipal,
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppDimensions.space4),

                // 3. Indicateur d'usage ou première pathologie (style "⏱ 10 MINS" ou "🌿 Usage")
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco_rounded,
                      size: 12,
                      color: isDark
                          ? AppColors.darkPrimary
                          : const Color(0xFF166534),
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Expanded(
                      child: Text(
                        plante.maladies.isNotEmpty
                            ? plante.maladies.first
                            : 'Plante médicinale',
                        style: (isDark
                                ? AppTextStyles.captionDark
                                : AppTextStyles.caption)
                            .copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: isDark
                              ? AppColors.darkPrimary
                              : const Color(0xFF166534),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space8),

                // 4. Ligne inférieure : Nom scientifique & Savoirs
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plante.nomScientifique,
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${plante.nombreConnaissances} sav. • ${plante.nombreEtudesScientifiques} étud.',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        fontSize: 9.5,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final resolved = ImageUtils.resolveImageUrl(plante.photoUrl);
    if (resolved != null) {
      return Image.network(
        resolved,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackGradient(isDark),
      );
    }
    return _buildFallbackGradient(isDark);
  }

  Widget _buildFallbackGradient(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 48,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
      ),
    );
  }
}

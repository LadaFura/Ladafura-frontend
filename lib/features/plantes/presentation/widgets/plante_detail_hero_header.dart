import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../models/plante_model.dart';

/// En-tête Hero immersif pour la page détail de la plante médicinale.
/// Présente :
/// - L'image botanique en grand avec dégradé d'assombrissement doux
/// - Boutons d'action rapides (retour, favori, partage)
/// - Nom scientifique en italique botanique
/// - Badges des noms vernaculaires maliennes (Bambara, Peul, Soninké, etc.)
/// - Résumé botanique
class PlanteDetailHeroHeader extends StatelessWidget {
  final PopulationPlanteDetailModel plante;
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PlanteDetailHeroHeader({
    super.key,
    required this.plante,
    this.onBack,
    this.onShare,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedUrl = ImageUtils.resolveImageUrl(plante.photoUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte image principale avec badges flottants
        Stack(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard * 1.5),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.primaryDark)
                        .withAlpha(30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard * 1.5),
                child: resolvedUrl != null
                    ? Image.network(
                        resolvedUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholderImage(isDark),
                      )
                    : _buildPlaceholderImage(isDark),
              ),
            ),

            // Dégradé pour la lisibilité
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard * 1.5),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(120),
                      Colors.transparent,
                      Colors.black.withAlpha(160),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Barre d'actions supérieure (Retour, Partage, Favoris)
            Positioned(
              top: AppDimensions.space12,
              left: AppDimensions.space12,
              right: AppDimensions.space12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  Row(
                    children: [
                      if (onShare != null) ...[
                        _buildGlassButton(
                          icon: Icons.share_rounded,
                          onTap: onShare!,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                      ],
                      if (onFavorite != null)
                        _buildGlassButton(
                          icon: isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor: isFavorite
                              ? AppColors.danger
                              : Colors.white,
                          onTap: onFavorite!,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge d'authentification botanique sur l'image
            Positioned(
              bottom: AppDimensions.space16,
              left: AppDimensions.space16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.accent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Spécimen Botanique Répertorié',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space16),

        // Nom scientifique en évidence
        Text(
          plante.nomScientifique,
          style: (isDark ? AppTextStyles.h1Dark : AppTextStyles.h1).copyWith(
            color: isDark ? AppColors.darkAccent : AppColors.primary,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.2,
          ),
        ),

        // Noms locaux / vernaculaires (Bambara, Peul, etc.)
        if (plante.nomsVernaculaires.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: plante.nomsVernaculaires.map((v) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkAccent : AppColors.primary)
                      .withAlpha(20),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                  border: Border.all(
                    color: (isDark ? AppColors.darkAccent : AppColors.primary)
                        .withAlpha(70),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 13,
                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      v.langue.trim().isNotEmpty
                          ? '${v.nom} (${v.langue})'
                          : v.nom,
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],

        // Description botanique
        if (plante.description.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space12),
          Text(
            plante.description,
            style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(120),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withAlpha(60),
            width: 1,
          ),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              size: 64,
              color: isDark ? AppColors.darkAccent : AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Flore Médicinale Malienne',
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

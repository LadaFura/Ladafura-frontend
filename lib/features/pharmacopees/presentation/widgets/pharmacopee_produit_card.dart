import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../models/pharmacopee_produit_item_model.dart';

/// Carte produit moderne inspirée du design de commerce rapide / épicerie épuré.
///
/// Caractéristiques :
/// - Fond épuré avec rayon arrondi généreux et bordure subtile
/// - Image centrale du produit sur fond doux avec zoom / cadrage propre
/// - Badge de délai / disponibilité ("10 MINS" ou "En stock") avec icône chronomètre
/// - Titre du produit en gras lisible (sur 1-2 lignes max)
/// - Prix principal mis en valeur en grand avec ancien prix / prix indicatif barré si applicable
/// - Bouton d'action circulaire vert foncé '+' en bas à droite
/// - Pas de bouton cœur / favori (supprimé selon la maquette)
class PharmacopeeProduitCard extends StatelessWidget {
  final PharmacopeeProduitItemModel produit;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const PharmacopeeProduitCard({
    super.key,
    required this.produit,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);
    final buttonColor =
        isDark ? AppColors.darkPrimaryDark : const Color(0xFF14532D);

    return Container(
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
                // 1. Zone Image centrée
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space4),
                      child: _buildProductImage(isDark),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.space8),

                // 2. Nom du produit
                Text(
                  produit.nom,
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

                const SizedBox(height: AppDimensions.space8),

                // 4. Ligne inférieure : Prix principal + Bouton circulaire '+'
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Bloc Prix
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            produit.prixFormate,
                            style: (isDark
                                    ? AppTextStyles.priceLargeDark
                                    : AppTextStyles.priceLarge)
                                .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (produit.forme != null &&
                              produit.forme!.isNotEmpty)
                            Text(
                              produit.forme!,
                              style: (isDark
                                      ? AppTextStyles.captionDark
                                      : AppTextStyles.caption)
                                  .copyWith(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppDimensions.space8),

                    // Bouton circulaire vert '+'
                    Material(
                      color: produit.disponible
                          ? buttonColor
                          : Colors.grey.shade400,
                      shape: const CircleBorder(),
                      elevation: produit.disponible ? 2 : 0,
                      child: InkWell(
                        onTap: produit.disponible ? onAddToCart : null,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildProductImage(bool isDark) {
    final resolved = ImageUtils.resolveImageUrl(produit.photoUrl);
    if (resolved != null) {
      return Image.network(
        resolved,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallback(isDark),
      );
    }
    return _buildFallback(isDark);
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Center(
        child: Icon(
          Icons.medication_liquid_rounded,
          size: 48,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import 'package:ladafura_frontend_flutter/features/plantes/models/produit_model.dart';

/// Carte pour afficher un médicament traditionnel (Fura) sur l'écran d'accueil
/// inspirée de l'interface moderne (carte propre, bouton circulaire '+', temps/délai estimé, prix).
class ProduitHomeCard extends StatelessWidget {
  final ProduitModel produit;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProduitHomeCard({
    super.key,
    required this.produit,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor =
        isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);
    final buttonColor =
        isDark ? AppColors.darkPrimaryDark : const Color(0xFF14532D);

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

                // 2. Nom du remède / produit
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

                const SizedBox(height: AppDimensions.space4),

                // 3. Indicateur de délai / disponibilité ("10 MINS" / "Disponible")
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: isDark
                          ? AppColors.darkPrimary
                          : const Color(0xFF166534),
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Text(
                      produit.disponibleEnPharmacie ? '10 MINS' : 'Indisponible',
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: produit.disponibleEnPharmacie
                            ? (isDark
                                ? AppColors.darkPrimary
                                : const Color(0xFF166534))
                            : AppColors.danger,
                      ),
                    ),
                  ],
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
                      color: produit.disponibleEnPharmacie
                          ? buttonColor
                          : Colors.grey.shade400,
                      shape: const CircleBorder(),
                      elevation: produit.disponibleEnPharmacie ? 2 : 0,
                      child: InkWell(
                        onTap: produit.disponibleEnPharmacie
                            ? (onAddToCart ?? onTap)
                            : null,
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

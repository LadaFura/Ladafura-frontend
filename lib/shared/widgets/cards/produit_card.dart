import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../models/produit_sommaire_model.dart';
import '../media/app_cached_image.dart';

/// Carte de présentation d'un remède traditionnel ou produit pharmaceutique (Population & Pharmacopée).
class ProduitCard extends StatelessWidget {
  final ProduitSommaireModel produit;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProduitCard({
    super.key,
    required this.produit,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Card(
      color: cardBg,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo du produit ou icône remède
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: produit.hasPhoto
                      ? AppCachedImage(
                          imageUrl: produit.photoUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: isDark
                              ? AppColors.darkPrimaryContainer
                              : AppColors.primaryLight,
                          child: Icon(
                            Icons.medication_outlined,
                            size: 32,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // Contenu descriptif
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Catégorie ou forme
                    if (produit.forme != null || produit.categorieNom != null)
                      Text(
                        (produit.forme ?? produit.categorieNom!).toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),

                    // Nom du remède
                    Text(
                      produit.nom,
                      style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                          .copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Prix en FCFA
                    Text(
                      produit.prixFormate,
                      style: AppTextStyles.body.copyWith(
                        color:
                            isDark ? AppColors.darkPrimary : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Disponibilité en officine & Avis clients
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: produit.isDisponible
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          produit.isDisponible ? 'En stock' : 'Rupture',
                          style: AppTextStyles.caption.copyWith(
                            color: produit.isDisponible
                                ? AppColors.success
                                : AppColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (produit.noteMoyenne != null) ...[
                          const SizedBox(width: AppDimensions.space8),
                          const Icon(Icons.star,
                              size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(
                            produit.noteFormatee,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Bouton optionnel d'ajout direct au panier
              if (onAddToCart != null && produit.isDisponible)
                IconButton(
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    size: 22,
                  ),
                  onPressed: onAddToCart,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

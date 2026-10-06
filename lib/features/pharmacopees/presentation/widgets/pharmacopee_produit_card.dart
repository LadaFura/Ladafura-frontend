import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/image_utils.dart';
import '../../models/pharmacopee_produit_item_model.dart';

/// Carte produit moderne adaptée au catalogue de la pharmacopée.
/// Affiche :
/// - Photo du produit avec badge de stock
/// - Nom et forme galénique / courte description
/// - Prix en FCFA bien visible
/// - Bouton interactif d'ajout au panier direct
/// - Tap pour ouvrir la modal de détails complète
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Zone Image avec badge et bouton '+' circulaire flottant
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: _buildImage(isDark),
                ),
                // Badge de disponibilité
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: produit.disponible
                          ? AppColors.success.withAlpha(220)
                          : AppColors.danger.withAlpha(220),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      produit.stockLibelle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Bouton '+' circulaire moderne inspiré de l'interface de référence
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: produit.disponible ? Colors.white : Colors.grey.shade300,
                    shape: const CircleBorder(),
                    elevation: 3,
                    shadowColor: Colors.black38,
                    child: InkWell(
                      onTap: produit.disponible ? onAddToCart : null,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add_rounded,
                          size: 22,
                          color: produit.disponible
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Zone Informations produit
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: AppDimensions.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du produit
                    Text(
                      produit.nom,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Forme galénique ou catégorie
                    if ((produit.forme != null && produit.forme!.isNotEmpty) ||
                        (produit.categorieNom != null &&
                            produit.categorieNom!.isNotEmpty)) ...[
                      Text(
                        produit.forme ?? produit.categorieNom!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                    ] else ...[
                      const SizedBox(height: 6),
                    ],

                    // Prix en FCFA bien mis en valeur
                    Text(
                      produit.prixFormate,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final resolved = ImageUtils.resolveImageUrl(produit.photoUrl);
    if (resolved != null) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(isDark),
      );
    }
    return _buildFallback(isDark);
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1B2F23) : const Color(0xFFF1F8F4),
      child: Center(
        child: Icon(
          Icons.medication_rounded,
          size: 40,
          color: isDark ? const Color(0xFF2ECC71) : AppColors.primary,
        ),
      ),
    );
  }
}

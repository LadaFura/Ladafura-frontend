import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/panier_model.dart';

/// Carte affichant un article dans le panier (Image, Nom, Forme, Prix unitaire, Quantité +/-, Sous-total, Suppression).
class PanierItemCard extends StatelessWidget {
  final LignePanierModel ligne;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final bool isUpdating;

  const PanierItemCard({
    super.key,
    required this.ligne,
    required this.onQuantityChanged,
    required this.onRemove,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo du produit ou icône par défaut
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: ligne.photoUrl != null &&
                          ligne.photoUrl!.startsWith('http')
                      ? Image.network(
                          ligne.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(
                              isDark, primaryColor),
                        )
                      : _buildFallbackThumbnail(isDark, primaryColor),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // Détails textuels du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ligne.nomProduit,
                      style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                          .copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ligne.forme != null &&
                        ligne.forme!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        ligne.forme!,
                        style: (isDark
                                ? AppTextStyles.captionDark
                                : AppTextStyles.caption)
                            .copyWith(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      ligne.prixUnitaireFormate,
                      style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                          .copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton suppression immédiate
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: 'Retirer cet article',
                onPressed: isUpdating ? null : onRemove,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space8),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.space8),

          // Ligne de gestion de quantité & sous-total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sélecteur de quantité avec boutons + et -
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: isUpdating || ligne.quantite <= 1
                          ? (ligne.quantite <= 1 && !isUpdating
                              ? onRemove
                              : null)
                          : () => onQuantityChanged(ligne.quantite - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: isUpdating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              '${ligne.quantite}',
                              style: (isDark
                                      ? AppTextStyles.h4Dark
                                      : AppTextStyles.h4)
                                  .copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: isUpdating
                          ? null
                          : () => onQuantityChanged(ligne.quantite + 1),
                    ),
                  ],
                ),
              ),

              // Sous-total calculé
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sous-total',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(fontSize: 11),
                  ),
                  Text(
                    ligne.sousTotalFormate,
                    style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(bool isDark, Color primaryColor) {
    return Container(
      color: primaryColor.withAlpha(25),
      child: Center(
        child: Icon(
          Icons.medication_liquid_rounded,
          color: primaryColor,
          size: 28,
        ),
      ),
    );
  }
}

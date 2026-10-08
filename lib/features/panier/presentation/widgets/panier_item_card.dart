import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/panier_model.dart';

/// Carte article panier moderne et épurée inspirée du design de référence :
/// - Bloc image produit aux coins arrondis sur fond gris très doux
/// - Informations à droite : Titre en gras (avec ellipsis), format / taille, prix en grand
/// - Bouton croix '✕' discret en haut à droite pour supprimer
/// - Sélecteur de quantité pilule arrondi en bas à droite : [ —  1  + ]
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
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Image du produit dans un conteneur aux angles arrondis (80x80) sur fond doux
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 86,
              height: 86,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              child: ligne.photoUrl != null && ligne.photoUrl!.startsWith('http')
                  ? Image.network(
                      ligne.photoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          _buildFallbackThumbnail(isDark, primaryColor),
                    )
                  : _buildFallbackThumbnail(isDark, primaryColor),
            ),
          ),
          const SizedBox(width: AppDimensions.space16),

          // 2. Bloc d'informations centrales et bouton croix / quantité à droite
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ligne du haut : Titre du produit + Bouton croix '✕'
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ligne.nomProduit,
                        style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                            .copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bouton '✕' discret
                    InkWell(
                      onTap: isUpdating ? null : onRemove,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),

                // Forme / Caractéristique (ex: "Size: 6" / "Sachet 100g")
                if (ligne.forme != null && ligne.forme!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    ligne.forme!,
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),

                // Ligne du bas : Prix unitaire en gras + Pilule sélecteur de quantité [ —  qty  + ]
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Prix
                    Text(
                      ligne.prixUnitaireFormate,
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),

                    // Pilule de quantité moderne [ —  1  + ]
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 20 : 6),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton Moins (—)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isUpdating || ligne.quantite <= 1
                                  ? (ligne.quantite <= 1 && !isUpdating
                                      ? onRemove
                                      : null)
                                  : () => onQuantityChanged(ligne.quantite - 1),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),

                          // Chiffre de quantité
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: isUpdating
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    '${ligne.quantite}',
                                    style: (isDark
                                            ? AppTextStyles.h4Dark
                                            : AppTextStyles.h4)
                                        .copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                          ),

                          // Bouton Plus (+)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isUpdating
                                  ? null
                                  : () => onQuantityChanged(ligne.quantite + 1),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(bool isDark, Color primaryColor) {
    return Center(
      child: Icon(
        Icons.medication_liquid_rounded,
        color: isDark ? AppColors.darkPrimary : AppColors.primary,
        size: 34,
      ),
    );
  }
}

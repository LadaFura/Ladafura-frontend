import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/utils/image_utils.dart';
import 'package:ladafura_frontend_flutter/features/recherche/models/global_search_response.dart';

/// Carte résultat d'une pharmacopée agréée (Section prioritaire).
/// Design fidèle à la maquette :
/// - Image bannière en tête pleine largeur avec angles arrondis
/// - Nom de la pharmacopée en gras
/// - Adresse / Commune • distance
/// - Ligne basse : Icône boutique "prendre sur place" à gauche, Note étoilée "★ 4.0 (1)" à droite
class SearchPharmacopeeCard extends StatelessWidget {
  final PharmacopeeSearchItem pharma;
  final dynamic userLocation;
  final VoidCallback onTap;
  final bool isDark;

  const SearchPharmacopeeCard({
    super.key,
    required this.pharma,
    required this.userLocation,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final note = pharma.noteMoyenne > 0 ? pharma.noteMoyenne : 4.0;
    final avis = pharma.nombreAvis > 0 ? pharma.nombreAvis : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEAEAEA),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Bannière supérieure de la Pharmacopée
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: _buildBannerImage(),
                ),
              ),

              // 2. Contenu textuel et métadonnées
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre : Nom de la pharmacopée
                    Text(
                      pharma.nom,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E272E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Sous-titre : Localisation • Distance
                    Text(
                      '${pharma.adresseComplete} • ${pharma.distanceFormatee(userLocation)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : const Color(0xFF757575),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Motif de correspondance (Ex: Remède disponible contre le paludisme, ou Produit X)
                    if (pharma.motifCorrespondance != null &&
                        pharma.motifCorrespondance!.isNotEmpty &&
                        pharma.motifCorrespondance != 'Pharmacopée') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF163824) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E7D32) : const Color(0xFFC8E6C9),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 14,
                              color: Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                pharma.motifCorrespondance!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Liste des remèdes associés disponibles en pharmacopée
                    if (pharma.produitsDisponibles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: pharma.produitsDisponibles.take(3).map((prod) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : const Color(0xFFF1F8E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              prod,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF33691E),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Ligne basse : Modalité ("prendre sur place") & Avis ("★ 4.0 (1)")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Côté gauche : icône boutique + "prendre sur place"
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 18,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : const Color(0xFF616161),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'prendre sur place',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : const Color(0xFF616161),
                              ),
                            ),
                          ],
                        ),

                        // Côté droit : Étoile dorée + Note verte + Nombre d'avis
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 19,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007A3D),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '($avis)',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : const Color(0xFF757575),
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
      ),
    );
  }

  Widget _buildBannerImage() {
    final resolvedUrl = ImageUtils.resolveImageUrl(pharma.photoUrl);
    if (resolvedUrl != null) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackAssetImage(),
      );
    }
    return _buildFallbackAssetImage();
  }

  Widget _buildFallbackAssetImage() {
    return Image.asset(
      'assets/images/pharmacie_sample.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE8F5E9),
        child: const Center(
          child: Icon(
            Icons.local_hospital_rounded,
            color: Color(0xFF2E7D32),
            size: 48,
          ),
        ),
      ),
    );
  }
}

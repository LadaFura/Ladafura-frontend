import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/services/location_service.dart';
import 'package:ladafura_frontend_flutter/features/population/data/models/pharmacopee_model.dart';

/// Carte pour afficher une pharmacopée à proximité sur la page d'accueil (conforme à la maquette).
class PharmacopeeHomeCard extends StatelessWidget {
  final PharmacopeeModel pharmacopee;
  final GeoCoordinates? userCoordinates;
  final VoidCallback? onTap;

  const PharmacopeeHomeCard({
    super.key,
    required this.pharmacopee,
    this.userCoordinates,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFEEEEEE),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Photo de devanture de l'officine
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusCard),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 145,
                child: Image.asset(
                  pharmacopee.photoUrl ?? 'assets/images/pharmacie_sample.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark
                          ? const Color(0xFF1E3A2F)
                          : const Color(0xFFE8F5E9),
                      child: Center(
                        child: Icon(
                          Icons.local_pharmacy_rounded,
                          size: 48,
                          color: isDark
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. Informations détaillées
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de la pharmacopée
                  Text(
                    pharmacopee.nom,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E272E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Adresse & distance
                  Text(
                    '${pharmacopee.adresseComplete} • ${pharmacopee.distanceFormatee(userCoordinates)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : const Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Rangée services (Livraison, Prendre sur place, Avis)
                  Row(
                    children: [
                      if (pharmacopee.proposeLivraison) ...[
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Livraison',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (pharmacopee.proposePickup) ...[
                        Icon(
                          Icons.storefront_outlined,
                          size: 16,
                          color: isDark ? Colors.grey[300] : const Color(0xFF424242),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'prendre sur place',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : const Color(0xFF424242),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Note et nombre d'avis
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Color(0xFFFFB300),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        pharmacopee.noteMoyenne.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${pharmacopee.nombreAvis})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

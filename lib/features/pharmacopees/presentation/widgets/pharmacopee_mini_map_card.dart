import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/map_navigation_utils.dart';
import '../../models/pharmacopee_detail_model.dart';

/// Mini-carte interactive et élégante intégrée dans la fiche détail :
/// - Affiche l'emplacement précis de la pharmacopée
/// - Affiche le point GPS utilisateur si disponible
/// - Permet de lancer l'itinéraire externe vers Google Maps d'un simple clic
class PharmacopeeMiniMapCard extends StatelessWidget {
  final PharmacopeeDetailModel pharmacopee;
  final GeoCoordinates? userCoordinates;

  const PharmacopeeMiniMapCard({
    super.key,
    required this.pharmacopee,
    this.userCoordinates,
  });

  void _onOpenDirections(BuildContext context) async {
    final lat = pharmacopee.latitude;
    final lng = pharmacopee.longitude;

    if (!MapNavigationUtils.areCoordinatesValid(lat, lng)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordonnées indisponibles pour le guidage.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await MapNavigationUtils.openDirections(
      destLat: lat!,
      destLng: lng!,
      destName: pharmacopee.nom,
      userCoords: userCoordinates,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir l\'application d\'itinéraire.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lat = pharmacopee.latitude;
    final lng = pharmacopee.longitude;
    final hasValidCoords = MapNavigationUtils.areCoordinatesValid(lat, lng);

    final distanceStr = pharmacopee.distanceFormatee(userCoordinates);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête de la carte (Design sobre et moderne)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emplacement & Accès',
                        style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pharmacopee.localisation?.adresseComplete ?? 'Mali',
                        style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption).copyWith(
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (distanceStr != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A8A).withAlpha(80) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      distanceStr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Contenu : Carte OSM ou fallback clair si coordonnées absentes
          SizedBox(
            height: 150,
            child: hasValidCoords
                ? Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(lat!, lng!),
                          initialZoom: 14.5,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'ml.ladafura.mobile',
                          ),
                          // Marqueur utilisateur
                          if (userCoordinates != null &&
                              MapNavigationUtils.areCoordinatesValid(
                                  userCoordinates!.latitude, userCoordinates!.longitude))
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(userCoordinates!.latitude, userCoordinates!.longitude),
                                  width: 24,
                                  height: 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // Marqueur de la pharmacopée
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(lat, lng),
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.eco_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bouton flottant semi-transparent pour ouvrir l'itinéraire externe
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton.icon(
                          onPressed: () => _onOpenDirections(context),
                          icon: const Icon(Icons.near_me_rounded, size: 16),
                          label: const Text(
                            'Voir l\'itinéraire',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_rounded,
                            size: 32,
                            color: isDark ? Colors.white38 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coordonnées GPS non renseignées pour cet établissement.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}


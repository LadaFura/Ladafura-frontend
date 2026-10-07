import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/location_service.dart';

/// Utilitaire pour ouvrir les applications externes de cartographie (Google Maps, Apple Maps, OSM)
/// et lancer l'itinéraire direct vers la pharmacopée.
class MapNavigationUtils {
  MapNavigationUtils._();

  /// Vérifie si les coordonnées sont valides (non nulles, non nulles numériquement, et dans des bornes réalistes).
  static bool areCoordinatesValid(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (latitude.isNaN || longitude.isNaN) return false;
    if (latitude == 0.0 && longitude == 0.0) return false;
    return latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0;
  }

  /// Ouvre l'application de cartographie externe (Google Maps / Apple Maps / Web)
  /// pour afficher l'itinéraire vers la destination.
  ///
  /// [destLat] et [destLng] : Coordonnées de la pharmacopée
  /// [destName] : Nom de la pharmacopée pour l'étiquette du repère
  /// [userCoords] : Coordonnées actuelles de l'utilisateur (optionnel, pour l'origine de l'itinéraire)
  static Future<bool> openDirections({
    required double destLat,
    required double destLng,
    String? destName,
    GeoCoordinates? userCoords,
  }) async {
    if (!areCoordinatesValid(destLat, destLng)) {
      debugPrint('[MapNavigationUtils] Coordonnées invalides : $destLat, $destLng');
      return false;
    }

    final encodedName = Uri.encodeComponent(destName ?? 'Pharmacopée');
    
    // 1. URL universelle Google Maps Directions (fonctionne sur Android, iOS avec Google Maps et fallback navigateur)
    String googleMapsUrl;
    if (userCoords != null && areCoordinatesValid(userCoords.latitude, userCoords.longitude)) {
      googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&origin=${userCoords.latitude},${userCoords.longitude}&destination=$destLat,$destLng&destination_place_id=$encodedName&travelmode=driving';
    } else {
      googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&destination_place_id=$encodedName&travelmode=driving';
    }

    final googleMapsUri = Uri.parse(googleMapsUrl);

    // 2. Schéma natif geo: (standard Android)
    final geoUri = Uri.parse('geo:$destLat,$destLng?q=$destLat,$destLng($encodedName)');

    try {
      // Tenter le schéma geo sur Android
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if (await canLaunchUrl(geoUri)) {
          final launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
          if (launched) return true;
        }
      }

      // Tenter le schéma Apple Maps sur iOS
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final appleMapsUri = Uri.parse('http://maps.apple.com/?daddr=$destLat,$destLng&q=$encodedName');
        if (await canLaunchUrl(appleMapsUri)) {
          final launched = await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
          if (launched) return true;
        }
      }

      // Fallback universel : Google Maps Web / App
      if (await canLaunchUrl(googleMapsUri)) {
        return await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[MapNavigationUtils] Erreur lors du lancement de l\'itinéraire: $e');
    }

    return false;
  }
}

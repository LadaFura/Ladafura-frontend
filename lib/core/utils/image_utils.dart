import '../constants/api_endpoints.dart';

/// Utilitaire de résolution et de normalisation des URLs d'images pour le frontend LADAFURA.
class ImageUtils {
  ImageUtils._();

  /// Résout une URL d'image backend (relative ou absolue) en URL complète HTTP accessible par le mobile.
  ///
  /// Exemples :
  /// - `null` ou `""` => `null`
  /// - `https://example.com/photo.jpg` => `https://example.com/photo.jpg`
  /// - `/uploads/pharmacopees/xyz.jpg` => `http://192.168.10.18:8080/uploads/pharmacopees/xyz.jpg`
  /// - `uploads/plantes/abc.png` => `http://192.168.10.18:8080/uploads/plantes/abc.png`
  static String? resolveImageUrl(String? url) {
    if (url == null) return null;
    final res = ApiEndpoints.resolveMediaUrl(url);
    return res.isEmpty ? null : res;
  }
}

import 'dart:math' as math;

/// Coordonnées géographiques immuables et typées pour LADAFURA.
class GeoCoordinates {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final DateTime? timestamp;

  const GeoCoordinates({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.timestamp,
  });

  /// Coordonnées officielles de référence au Mali.
  static const GeoCoordinates bamako = GeoCoordinates(
    latitude: 12.6392,
    longitude: -8.0029,
  );

  /// Calcule la distance orthodromique (en kilomètres) par la formule de Haversine.
  double distanceToKm(GeoCoordinates other) {
    return LocationService.calculateDistanceInKm(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Chaîne formatée pour affichage ou métadonnées de photo géotaguée (US-15).
  String get formattedString {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(5)}° $latDir, ${longitude.abs().toStringAsFixed(5)}° $lngDir';
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'accuracy': accuracy,
        'timestamp': timestamp?.toIso8601String(),
      };

  factory GeoCoordinates.fromJson(Map<String, dynamic> json) => GeoCoordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitude: (json['altitude'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
      );

  @override
  String toString() => 'GeoCoordinates($formattedString)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoCoordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Service de capture des coordonnées GPS pour la cartographie des officines (US-05)
/// et la géolocalisation des collectes de plantes sur le terrain (US-16).
class LocationService {
  // Limites géographiques de la République du Mali (Bounding Box)
  static const double maliMinLat = 10.14;
  static const double maliMaxLat = 25.00;
  static const double maliMinLng = -12.24;
  static const double maliMaxLng = 4.25;

  GeoCoordinates? _lastKnownPosition;
  bool _mockMode = false;
  GeoCoordinates? _mockPosition;

  LocationService({bool mockMode = false, GeoCoordinates? mockPosition})
      : _mockMode = mockMode,
        _mockPosition = mockPosition;

  /// Active le mode simulation (utile pour tests unitaires ou émulateur).
  void enableMockMode(GeoCoordinates position) {
    _mockMode = true;
    _mockPosition = position;
  }

  /// Désactive le mode simulation.
  void disableMockMode() {
    _mockMode = false;
    _mockPosition = null;
  }

  /// Vérifie si une position se trouve dans les frontières géographiques du Mali.
  static bool isWithinMaliBounds(double latitude, double longitude) {
    return latitude >= maliMinLat &&
        latitude <= maliMaxLat &&
        longitude >= maliMinLng &&
        longitude <= maliMaxLng;
  }

  /// Calcule la distance entre deux points en kilomètres en utilisant la formule de Haversine.
  static double calculateDistanceInKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(endLat - startLat);
    final dLon = _toRadians(endLng - startLng);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(startLat)) *
            math.cos(_toRadians(endLat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Capture la position GPS actuelle de l'appareil.
  Future<GeoCoordinates?> getCurrentPosition() async {
    if (_mockMode && _mockPosition != null) {
      _lastKnownPosition = _mockPosition;
      return _mockPosition;
    }

    // Si aucune position réelle n'est disponible (ex: web/simulateur sans capteur),
    // retourne la dernière position connue ou la position par défaut de Bamako.
    return _lastKnownPosition ??
        GeoCoordinates(
          latitude: 12.6392,
          longitude: -8.0029,
          accuracy: 10.0,
          timestamp: DateTime.now(),
        );
  }

  /// Dernière position capturée en mémoire.
  GeoCoordinates? get lastKnownPosition => _lastKnownPosition;
}

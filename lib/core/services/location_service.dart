import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

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

/// Service de capture des coordonnées GPS pour la cartographie des pharmacopées (US-05)
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

  /// Demande l'autorisation à l'utilisateur et récupère sa position GPS actuelle.
  /// Si les services de localisation sont désactivés ou la permission refusée, renvoie null.
  Future<GeoCoordinates?> requestPositionWithPermission() async {
    if (_mockMode && _mockPosition != null) {
      _lastKnownPosition = _mockPosition;
      return _mockPosition;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Le service de localisation GPS est désactivé.');
        return _lastKnownPosition;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Permission de localisation refusée par l\'utilisateur.');
          return _lastKnownPosition;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Permission de localisation refusée définitivement.');
        return _lastKnownPosition;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final coords = GeoCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );

      _lastKnownPosition = coords;
      return coords;
    } catch (e) {
      debugPrint('[LocationService] Erreur lors de la récupération GPS: $e');
      return _lastKnownPosition;
    }
  }

  /// Capture la position GPS actuelle de l'appareil (tente d'obtenir la position si permise).
  Future<GeoCoordinates?> getCurrentPosition() async {
    if (_mockMode && _mockPosition != null) {
      _lastKnownPosition = _mockPosition;
      return _mockPosition;
    }

    try {
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.always ||
          hasPermission == LocationPermission.whileInUse) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
          final coords = GeoCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
            accuracy: position.accuracy,
            timestamp: position.timestamp,
          );
          _lastKnownPosition = coords;
          return coords;
        }
      }
    } catch (_) {
      // Échec silencieux, retour repli
    }

    return _lastKnownPosition ?? GeoCoordinates.bamako;
  }

  /// Dernière position capturée en mémoire.
  GeoCoordinates? get lastKnownPosition => _lastKnownPosition;
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/network_providers.dart';
import '../models/profil_model.dart';

final profilServiceProvider = Provider<ProfilService>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfilService(dio);
});

/// Service REST communiquant avec les endpoints réels du Profil Population.
class ProfilService {
  final Dio _dio;

  ProfilService(this._dio);

  /// Récupère le profil complet avec les compteurs réels d'activité.
  Future<ProfilModel> fetchMonProfil() async {
    final response = await _dio.get(ApiEndpoints.populationProfile);
    if (response.statusCode == 200 && response.data != null) {
      return ProfilModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception("Impossible de charger le profil (code ${response.statusCode})");
  }

  /// Met à jour les informations autorisées (nom, prénom, téléphone).
  Future<ProfilModel> updateProfil({
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.populationProfile,
      data: {
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        if (telephone != null && telephone.trim().isNotEmpty)
          'telephone': telephone.trim(),
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return ProfilModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception("Échec de la mise à jour du profil (code ${response.statusCode})");
  }

  /// Récupère le nombre réel de notifications non lues.
  Future<int> fetchUnreadNotificationsCount() async {
    try {
      final response = await _dio.get('/population/notifications/unread-count');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return (data['count'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {
      // Repli silencieux en cas d'erreur réseau
    }
    return 0;
  }
}

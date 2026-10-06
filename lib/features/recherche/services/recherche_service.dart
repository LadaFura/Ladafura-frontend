import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import '../models/global_search_response.dart';

/// Service REST pour la recherche universelle (Pharmacopées, Plantes, Maladies, Produits).
class RechercheService {
  final ApiClient _apiClient;

  RechercheService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Exécute la recherche consolidée auprès du backend Spring Boot.
  Future<GlobalSearchResponse?> search(String query) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationRecherche,
      queryParameters: {'query': query.trim()},
    );

    if (response.isSuccess && response.data != null) {
      return GlobalSearchResponse.fromJson(response.data!);
    }
    return null;
  }
}

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/global_search_response.dart';

/// Contrat du repository de recherche universelle LADAFURA.
abstract class IRechercheRepository {
  /// Recherche unifiée auprès du backend (Pharmacopées, Plantes, Maladies, Produits).
  Future<GlobalSearchResponse?> search(String query);

  /// Récupère la liste des maladies populaires depuis la base de données.
  Future<List<String>> getMaladiesPopulaires();
}

/// Implémentation concrète communiquant avec les endpoints REST Spring Boot réels.
class RechercheRepository implements IRechercheRepository {
  final ApiClient _apiClient;

  RechercheRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<GlobalSearchResponse?> search(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return null;

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationRecherche,
      queryParameters: {'query': cleanQuery},
    );

    if (response.isSuccess && response.data != null) {
      return GlobalSearchResponse.fromJson(response.data!);
    }
    return null;
  }

  @override
  Future<List<String>> getMaladiesPopulaires() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.populationRecherche}/maladies',
        queryParameters: {'page': 0, 'size': 10},
      );

      if (response.isSuccess && response.data != null) {
        final content = response.data!['content'] as List<dynamic>?;
        if (content != null) {
          return content
              .map((e) => (e as Map<String, dynamic>)['nom']?.toString() ?? '')
              .where((nom) => nom.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      // Ignorer silencieusement si hors-ligne
    }
    return const [];
  }
}

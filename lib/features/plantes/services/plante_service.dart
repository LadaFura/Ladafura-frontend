import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import '../models/plante_model.dart';

import '../models/produit_detail_model.dart';

/// Service REST pour la consultation des plantes médicinales et des savoirs traditionnels.
class PlanteService {
  final ApiClient _apiClient;

  PlanteService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Récupère la liste des plantes médicinales.
  Future<List<PopulationPlanteDetailModel>> getPlantes({
    int page = 0,
    int size = 10,
    String? query,
  }) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (query != null && query.isNotEmpty) params['query'] = query;

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationPlantes,
      queryParameters: params,
    );

    if (response.isSuccess && response.data != null) {
      final List items = response.data!['content'] is List
          ? response.data!['content']
          : (response.data is List ? response.data as List : []);
      return items
          .map((e) => PopulationPlanteDetailModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Récupère la fiche détaillée complète d'une plante (botanique, savoirs trad., études).
  Future<PopulationPlanteDetailModel?> getPlanteDetail(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationPlanteDetail(id.toString()),
    );

    if (response.isSuccess && response.data != null) {
      return PopulationPlanteDetailModel.fromJson(response.data!);
    }
    return null;
  }

  /// Récupère la fiche détaillée d'un produit traditionnel.
  Future<ProduitDetailModel?> getProduitDetail(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationProduitDetail(id.toString()),
    );

    if (response.isSuccess && response.data != null) {
      return ProduitDetailModel.fromJson(response.data!);
    }
    return null;
  }
}

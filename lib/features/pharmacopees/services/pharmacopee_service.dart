import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import '../models/pharmacopee_avis_item_model.dart';
import '../models/pharmacopee_detail_model.dart';
import '../models/pharmacopee_model.dart';
import '../models/pharmacopee_produit_item_model.dart';

/// Service REST pour la consultation des pharmacopées traditionnelles.
class PharmacopeeService {
  final ApiClient _apiClient;

  PharmacopeeService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Récupère la liste paginée des pharmacopées agréées.
  Future<List<PharmacopeeModel>> getPharmacopees(
      {int page = 0, int size = 10}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationPharmacopees,
      queryParameters: {'page': page, 'size': size},
    );

    if (response.isSuccess && response.data != null) {
      final List items = response.data!['content'] is List
          ? response.data!['content']
          : (response.data is List ? response.data as List : []);
      return items
          .map((e) => PharmacopeeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Récupère la fiche détaillée complète d'une pharmacopée (avec modes de retrait et coordonnées).
  Future<PharmacopeeDetailModel?> getPharmacopeeDetailModel(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationPharmacopeeDetail(id.toString()),
    );

    if (response.isSuccess && response.data != null) {
      return PharmacopeeDetailModel.fromJson(response.data!);
    }
    return null;
  }

  /// Récupère les produits d'une pharmacopée avec filtre optionnel de disponibilité.
  Future<List<PharmacopeeProduitItemModel>> getProduitsByPharmacopee(
    int pharmacopeeId, {
    bool? disponibleOnly,
    int page = 0,
    int size = 30,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (disponibleOnly != null) {
      queryParams['disponibleOnly'] = disponibleOnly;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationPharmacopeeProduits(pharmacopeeId.toString()),
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      final List items = response.data!['content'] is List
          ? response.data!['content']
          : (response.data is List ? response.data as List : []);
      return items
          .map((e) => PharmacopeeProduitItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Récupère les avis publiés pour une pharmacopée.
  Future<List<PharmacopeeAvisItemModel>> getAvisByPharmacopee(
    int pharmacopeeId, {
    int page = 0,
    int size = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationPharmacopeeAvis(pharmacopeeId.toString()),
      queryParameters: {'page': page, 'size': size},
    );

    if (response.isSuccess && response.data != null) {
      final List items = response.data!['content'] is List
          ? response.data!['content']
          : (response.data is List ? response.data as List : []);
      return items
          .map((e) => PharmacopeeAvisItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Récupère les détails synthétiques d'une pharmacopée par son identifiant (rétrocompatibilité).
  Future<PharmacopeeModel?> getPharmacopeeDetail(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationPharmacopeeDetail(id.toString()),
    );

    if (response.isSuccess && response.data != null) {
      return PharmacopeeModel.fromJson(response.data!);
    }
    return null;
  }
}

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/favori_model.dart';

class FavoriService {
  final ApiClient _apiClient;

  FavoriService(this._apiClient);

  /// Récupère la liste paginée des favoris de l'utilisateur connecté.
  Future<List<FavoriItemModel>> getMesFavoris({
    TypeFavori? type,
    int page = 0,
    int size = 100,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationFavoris,
      queryParameters: {
        if (type != null) 'type': type.backendValue,
        'page': page,
        'size': size,
      },
    );

    if (response.isSuccess && response.data != null) {
      final content = response.data!['content'];
      if (content is List) {
        return content
            .whereType<Map<String, dynamic>>()
            .map(FavoriItemModel.fromJson)
            .toList();
      }
    }
    return const [];
  }

  /// Récupère les compteurs de favoris (total, plantes, produits, pharmacopées).
  Future<FavoriCountModel> getCounts() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationFavorisCount,
    );
    if (response.isSuccess && response.data != null) {
      return FavoriCountModel.fromJson(response.data!);
    }
    return const FavoriCountModel();
  }

  /// Vérifie si un élément cible est en favori.
  Future<bool> checkFavori({
    required TypeFavori type,
    required int cibleId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.populationFavorisCheck,
      queryParameters: {
        'type': type.backendValue,
        'cibleId': cibleId,
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!['favori'] == true;
    }
    return false;
  }

  /// Bascule l'état favori (ajoute ou retire) d'une plante, d'un produit ou d'une pharmacopée.
  Future<ToggleFavoriResponse> toggleFavori({
    required TypeFavori type,
    required int cibleId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.populationFavorisToggle,
      data: {
        'type': type.backendValue,
        'cibleId': cibleId,
      },
    );
    if (response.isSuccess && response.data != null) {
      return ToggleFavoriResponse.fromJson(response.data!);
    }
    throw Exception(
        response.message ?? 'Impossible de modifier les favoris.');
  }

  /// Supprime un favori par son ID de ligne.
  Future<void> deleteFavoriById(int favoriId) async {
    await _apiClient.delete<dynamic>(
      ApiEndpoints.populationFavoriDelete(favoriId),
    );
  }
}


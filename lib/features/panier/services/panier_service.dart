import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/network_providers.dart';
import '../models/panier_model.dart';

final panierServiceProvider = Provider<PanierService>((ref) {
  final dio = ref.watch(dioProvider);
  return PanierService(dio);
});

/// Service gérant les appels API du panier avec le backend Spring Boot LADAFURA.
class PanierService {
  final Dio _dio;

  PanierService(this._dio);

  /// Récupère le panier actif de l'utilisateur connecté.
  Future<PanierModel> getPanier() async {
    final response = await _dio.get(ApiEndpoints.populationPanier);
    if (response.statusCode == 200 && response.data != null) {
      return PanierModel.fromJson(response.data as Map<String, dynamic>);
    }
    return PanierModel.vide();
  }

  /// Ajoute un produit au panier (ou incrémente sa quantité).
  Future<PanierModel> ajouterProduit({
    required int produitId,
    int quantite = 1,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.populationPanierLignes,
      data: {
        'produitId': produitId,
        'quantite': quantite,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return PanierModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception("Impossible d'ajouter le produit au panier");
  }

  /// Modifie la quantité d'une ligne d'article dans le panier.
  Future<PanierModel> modifierQuantite({
    required int ligneId,
    required int quantite,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.populationPanierLigneDetail(ligneId.toString()),
      data: {
        'quantite': quantite,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return PanierModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception("Impossible de modifier la quantité");
  }

  /// Supprime une ligne du panier.
  Future<PanierModel> supprimerLigne(int ligneId) async {
    final response = await _dio.delete(
      ApiEndpoints.populationPanierLigneDetail(ligneId.toString()),
    );
    if (response.statusCode == 200 && response.data != null) {
      return PanierModel.fromJson(response.data as Map<String, dynamic>);
    }
    return PanierModel.vide();
  }

  /// Vide intégralement le panier.
  Future<void> viderPanier() async {
    await _dio.delete(ApiEndpoints.populationPanier);
  }
}

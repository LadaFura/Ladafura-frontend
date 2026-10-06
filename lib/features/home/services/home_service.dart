import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../../pharmacopees/models/pharmacopee_model.dart';
import '../../plantes/models/produit_model.dart';
import '../../../shared/models/plante_sommaire_model.dart';

final homeServiceProvider = Provider<HomeService>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeService(dio);
});

/// Service dédié aux données de découverte de l'écran d'accueil (Citoyen / Visiteur).
class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  /// Récupère la liste des pharmacopées
  Future<List<PharmacopeeModel>> fetchPharmacopees({int page = 0, int size = 10}) async {
    final response = await _dio.get('/population/pharmacopees', queryParameters: {
      'page': page,
      'size': size,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      return items.map((e) => PharmacopeeModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Récupère la liste des produits populaires
  Future<List<ProduitModel>> fetchPopularProduits({int page = 0, int size = 10}) async {
    final response = await _dio.get('/population/produits', queryParameters: {
      'page': page,
      'size': size,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      return items.map((e) => ProduitModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Récupère la liste des plantes populaires
  Future<List<PlanteSommaireModel>> fetchPopularPlantes({int page = 0, int size = 10}) async {
    final response = await _dio.get('/population/plantes', queryParameters: {
      'page': page,
      'size': size,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      return items.map((e) => PlanteSommaireModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

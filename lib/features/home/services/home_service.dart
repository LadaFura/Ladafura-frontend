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

  /// Compteur local de consultations en session/persistance légère (complément temps réel)
  static final Map<int, int> _localConsultationIncrements = {};

  /// Enregistre une consultation locale d'une plante pour mise à jour immédiate des statistiques.
  static void recordLocalPlantConsultation(int planteId) {
    _localConsultationIncrements[planteId] =
        (_localConsultationIncrements[planteId] ?? 0) + 1;
  }

  /// Récupère les pharmacopées les plus proches (maximum 10) à partir de la géolocalisation du citoyen.
  Future<List<PharmacopeeModel>> fetchPharmacopees({
    int page = 0,
    int size = 10,
    double? latitude,
    double? longitude,
  }) async {
    final int safeLimit = size.clamp(1, 10);

    // 1. Tenter l'endpoint dédié de proximité trié côté serveur
    try {
      final response = await _dio.get(
        '/population/pharmacopees/proximite',
        queryParameters: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'limit': safeLimit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['content'] is List ? response.data['content'] : []);
        if (items.isNotEmpty) {
          return items
              .map((e) => PharmacopeeModel.fromJson(e as Map<String, dynamic>))
              .take(safeLimit)
              .toList();
        }
      }
    } catch (_) {
      // Repli transparent sur l'endpoint paginé si le serveur n'a pas encore la route /proximite
    }

    // 2. Repli : récupérer l'ensemble des pharmacopées validées pour trier par distance réelle
    final response = await _dio.get('/population/pharmacopees', queryParameters: {
      'page': page,
      'size': 50,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      return items
          .map((e) => PharmacopeeModel.fromJson(e as Map<String, dynamic>))
          .toList();
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

  /// Récupère la liste des plantes les plus consultées (maximum 15 plantes).
  /// Filtre les nouvelles plantes non consultées et trie par nombre réel de consultations décroissant.
  Future<List<PlanteSommaireModel>> fetchPopularPlantes({
    int page = 0,
    int size = 15,
  }) async {
    final int safeLimit = size.clamp(1, 15);

    // 1. Tenter l'endpoint dédié aux plantes les plus consultées
    try {
      final response = await _dio.get(
        '/population/plantes/plus-consultees',
        queryParameters: {'limit': safeLimit},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['content'] is List ? response.data['content'] : []);
        final parsed = items
            .map((e) => PlanteSommaireModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          return _applyConsultationSortingAndLimit(parsed, safeLimit);
        }
      }
    } catch (_) {
      // Repli transparent sur /population/plantes si l'endpoint n'est pas encore déployé
    }

    // 2. Repli : récupérer le catalogue et appliquer le filtrage/tri par consultations
    final response = await _dio.get('/population/plantes', queryParameters: {
      'page': page,
      'size': 50,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      final parsed = items
          .map((e) => PlanteSommaireModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return _applyConsultationSortingAndLimit(parsed, safeLimit);
    }
    return [];
  }

  List<PlanteSommaireModel> _applyConsultationSortingAndLimit(
    List<PlanteSommaireModel> plantes,
    int safeLimit,
  ) {
    // Enrichir avec les éventuelles consultations enregistrées durant la session courante
    final enriched = plantes.map((p) {
      final localInc = _localConsultationIncrements[p.id] ?? 0;
      if (localInc > 0 && p.nombreConsultations == 0) {
        return p.copyWith(nombreConsultations: p.nombreConsultations + localInc);
      }
      return p;
    }).toList();

    // Si des plantes ont déjà des consultations (> 0), afficher uniquement celles qui ont été consultées
    final consultedOnly =
        enriched.where((p) => p.nombreConsultations > 0).toList();

    if (consultedOnly.isNotEmpty) {
      consultedOnly.sort((a, b) {
        final cmp = b.nombreConsultations.compareTo(a.nombreConsultations);
        if (cmp != 0) return cmp;
        return (b.nombreConnaissances + b.nombreEtudesScientifiques)
            .compareTo(a.nombreConnaissances + a.nombreEtudesScientifiques);
      });
      return consultedOnly.take(safeLimit).toList();
    }

    // Sinon (aucune consultation enregistrée en base pour le moment), exclure les nouvelles plantes
    // sans savoirs ni études et trier par richesse documentaire décroissante
    final documented = enriched
        .where(
            (p) => p.nombreConnaissances > 0 || p.nombreEtudesScientifiques > 0)
        .toList();

    final targetList = documented.isNotEmpty ? documented : enriched;
    targetList.sort((a, b) {
      final cmp = b.nombreConsultations.compareTo(a.nombreConsultations);
      if (cmp != 0) return cmp;
      return (b.nombreConnaissances + b.nombreEtudesScientifiques)
          .compareTo(a.nombreConnaissances + a.nombreEtudesScientifiques);
    });

    return targetList.take(safeLimit).toList();
  }
}

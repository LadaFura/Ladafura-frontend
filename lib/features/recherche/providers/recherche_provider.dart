import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import 'package:ladafura_frontend_flutter/core/services/location_service.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/providers/pharmacopee_provider.dart';
import 'package:ladafura_frontend_flutter/features/plantes/providers/plante_provider.dart';
import '../data/models/global_search_response.dart';
import '../data/models/search_category.dart';
import '../data/repositories/recherche_repository.dart';
import '../services/recherche_service.dart';

// Re-export pour faciliter l'accès depuis d'autres modules
export '../data/models/search_category.dart';
export '../data/models/global_search_response.dart';

/// Provider du repository de recherche (couche data).
final rechercheRepositoryProvider = Provider<IRechercheRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RechercheRepository(apiClient: apiClient);
});

/// Provider du service de recherche (conservé pour rétro-compatibilité).
final rechercheServiceProvider = Provider<RechercheService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RechercheService(apiClient: apiClient);
});

/// Provider asynchrone des maladies suggérées depuis la base de données réelle.
final maladiesSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(rechercheRepositoryProvider);
  return repo.getMaladiesPopulaires();
});

/// États possibles de la recherche.
enum RechercheStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

/// État immuable de l'écran de recherche.
class RechercheState {
  final RechercheStatus status;
  final String query;
  final GlobalSearchResponse? results;
  final String? errorMessage;
  final SearchCategory selectedCategory;

  const RechercheState({
    this.status = RechercheStatus.idle,
    this.query = '',
    this.results,
    this.errorMessage,
    this.selectedCategory = SearchCategory.all,
  });

  const RechercheState.idle({this.selectedCategory = SearchCategory.all})
      : status = RechercheStatus.idle,
        query = '',
        results = null,
        errorMessage = null;

  const RechercheState.loading(this.query,
      {this.selectedCategory = SearchCategory.all})
      : status = RechercheStatus.loading,
        results = null,
        errorMessage = null;

  RechercheState.success(this.query, GlobalSearchResponse this.results,
      {this.selectedCategory = SearchCategory.all})
      : status =
            results.isEmpty ? RechercheStatus.empty : RechercheStatus.success,
        errorMessage = null;

  const RechercheState.empty(this.query,
      {this.selectedCategory = SearchCategory.all})
      : status = RechercheStatus.empty,
        results = null,
        errorMessage = null;

  const RechercheState.error(this.query, String message,
      {this.selectedCategory = SearchCategory.all})
      : status = RechercheStatus.error,
        results = null,
        errorMessage = message;

  RechercheState copyWith({
    RechercheStatus? status,
    String? query,
    GlobalSearchResponse? results,
    String? errorMessage,
    SearchCategory? selectedCategory,
  }) {
    return RechercheState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  bool get isLoading => status == RechercheStatus.loading;
  bool get hasResults =>
      status == RechercheStatus.success &&
      results != null &&
      results!.isNotEmpty;
  bool get isEmpty => status == RechercheStatus.empty;
}

/// Notifier gérant la logique métier et l'orchestration des données de recherche.
class RechercheNotifier extends StateNotifier<RechercheState> {
  final Ref _ref;
  Timer? _debounceTimer;

  RechercheNotifier(this._ref) : super(const RechercheState.idle());

  /// Met à jour la catégorie sélectionnée
  void setCategory(SearchCategory category, {GeoCoordinates? userLocation}) {
    if (state.status == RechercheStatus.idle) {
      exploreCategory(category, userLocation: userLocation);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// Explore directement les entités réelles d'une catégorie depuis le backend :
  /// - Pharmacopées : pharmacopées triées par proximité géographique
  /// - Tous : pharmacopées et plantes médicinales
  /// - Plantes : plantes médicinales validées
  Future<void> exploreCategory(
    SearchCategory category, {
    GeoCoordinates? userLocation,
  }) async {
    _debounceTimer?.cancel();
    state = RechercheState.loading('', selectedCategory: category);

    List<PharmacopeeSearchItem> pharmacopees = [];
    List<PlanteSearchItem> plantes = [];

    final needPharmacopees = category == SearchCategory.all ||
        category == SearchCategory.pharmacopees;
    final needPlantes =
        category == SearchCategory.all || category == SearchCategory.plantes;

    try {
      if (needPharmacopees) {
        final pharmaService = _ref.read(pharmacopeeServiceProvider);
        final list = await pharmaService.getPharmacopees(page: 0, size: 20);
        if (list.isNotEmpty) {
          pharmacopees = list
              .map((p) => PharmacopeeSearchItem(
                    id: p.id,
                    nom: p.nom,
                    description: p.description,
                    telephone: p.telephone,
                    region: p.region,
                    cercle: p.cercle,
                    commune: p.commune,
                    localite: p.localite,
                    latitude: p.latitude,
                    longitude: p.longitude,
                    noteMoyenne: p.noteMoyenne,
                    nombreAvis: p.nombreAvis,
                    photoUrl: p.photoUrl,
                  ))
              .toList();

          // Tri par proximité géographique croissante si localisation disponible
          if (userLocation != null) {
            pharmacopees.sort((a, b) => a
                .distanceToKm(userLocation)
                .compareTo(b.distanceToKm(userLocation)));
          }
        }
      }

      if (needPlantes) {
        final planteService = _ref.read(planteServiceProvider);
        final list = await planteService.getPlantes(page: 0, size: 20);
        if (list.isNotEmpty) {
          plantes = list
              .map((p) => PlanteSearchItem(
                    id: p.id,
                    nomScientifique: p.nomScientifique,
                    description: p.description,
                    nomsVernaculaires: p.nomsVernaculaires
                        .map((nv) => nv.langue.isNotEmpty
                            ? '${nv.nom} (${nv.langue})'
                            : nv.nom)
                        .toList(),
                    photoUrl: p.photoUrl,
                  ))
              .toList();
        }
      }

      if (pharmacopees.isEmpty && plantes.isEmpty) {
        state = RechercheState.empty('', selectedCategory: category);
        return;
      }

      final response = GlobalSearchResponse(
        query: '',
        totalResultats: pharmacopees.length + plantes.length,
        pharmacopees: pharmacopees,
        plantes: plantes,
      );

      state = RechercheState.success('', response, selectedCategory: category);
    } catch (e) {
      state = RechercheState.error(
        '',
        'Erreur lors du chargement des données. Veuillez réessayer.',
        selectedCategory: category,
      );
    }
  }

  /// Déclenche la recherche avec un debouncing de 300 ms pour une frappe fluide
  void onQueryChanged(String query, {GeoCoordinates? userLocation}) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.length < 2) {
      if (state.status != RechercheStatus.idle) {
        state = RechercheState.idle(selectedCategory: state.selectedCategory);
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      search(trimmed, userLocation: userLocation);
    });
  }

  /// Exécute la recherche réelle multi-critères auprès de l'API REST
  Future<void> search(String query, {GeoCoordinates? userLocation}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = RechercheState.idle(selectedCategory: state.selectedCategory);
      return;
    }

    state = RechercheState.loading(trimmed,
        selectedCategory: state.selectedCategory);

    try {
      final repository = _ref.read(rechercheRepositoryProvider);
      final searchResult = await repository.search(trimmed);

      if (searchResult != null) {
        if (searchResult.isEmpty) {
          state = RechercheState.empty(trimmed,
              selectedCategory: state.selectedCategory);
          return;
        }

        var finalResult = searchResult;
        if (userLocation != null && searchResult.pharmacopees.isNotEmpty) {
          final sortedPharma =
              List<PharmacopeeSearchItem>.from(searchResult.pharmacopees)
                ..sort((a, b) => a
                    .distanceToKm(userLocation)
                    .compareTo(b.distanceToKm(userLocation)));
          finalResult = GlobalSearchResponse(
            query: searchResult.query,
            totalResultats: searchResult.totalResultats,
            pharmacopees: sortedPharma,
            plantes: searchResult.plantes,
            nomsVernaculaires: searchResult.nomsVernaculaires,
            maladies: searchResult.maladies,
            produits: searchResult.produits,
          );
        }
        state = RechercheState.success(trimmed, finalResult,
            selectedCategory: state.selectedCategory);
      } else {
        state = RechercheState.empty(trimmed,
            selectedCategory: state.selectedCategory);
      }
    } catch (e) {
      state = RechercheState.error(
        trimmed,
        'Impossible de contacter le serveur. Vérifiez votre connexion internet.',
        selectedCategory: state.selectedCategory,
      );
    }
  }

  /// Réinitialise l'état vers idle
  void reset() {
    _debounceTimer?.cancel();
    state = RechercheState.idle(selectedCategory: state.selectedCategory);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider d'état global pour la recherche LADAFURA.
final rechercheProvider =
    StateNotifierProvider<RechercheNotifier, RechercheState>((ref) {
  return RechercheNotifier(ref);
});

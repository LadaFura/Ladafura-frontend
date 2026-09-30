import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import '../data/models/global_search_response.dart';

enum RechercheStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

class RechercheState {
  final RechercheStatus status;
  final String query;
  final GlobalSearchResponse? results;
  final String? errorMessage;

  const RechercheState({
    this.status = RechercheStatus.idle,
    this.query = '',
    this.results,
    this.errorMessage,
  });

  const RechercheState.idle()
      : status = RechercheStatus.idle,
        query = '',
        results = null,
        errorMessage = null;

  const RechercheState.loading(this.query)
      : status = RechercheStatus.loading,
        results = null,
        errorMessage = null;

  RechercheState.success(this.query, GlobalSearchResponse this.results)
      : status =
            results.isEmpty ? RechercheStatus.empty : RechercheStatus.success,
        errorMessage = null;

  const RechercheState.error(this.query, String message)
      : status = RechercheStatus.error,
        results = null,
        errorMessage = message;

  bool get isLoading => status == RechercheStatus.loading;
  bool get hasResults =>
      status == RechercheStatus.success &&
      results != null &&
      results!.isNotEmpty;
  bool get isEmpty => status == RechercheStatus.empty;
}

class RechercheNotifier extends StateNotifier<RechercheState> {
  final Ref _ref;
  Timer? _debounceTimer;

  RechercheNotifier(this._ref) : super(const RechercheState.idle());

  /// Met à jour la recherche avec un debounce de 400ms.
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.length < 2) {
      state = const RechercheState.idle();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      search(trimmed);
    });
  }

  /// Exécute immédiatement la recherche auprès du backend Spring Boot.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const RechercheState.idle();
      return;
    }

    state = RechercheState.loading(trimmed);

    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.populationRecherche,
        queryParameters: {'query': trimmed},
      );

      if (response.isSuccess && response.data != null) {
        final searchResult = GlobalSearchResponse.fromJson(response.data!);
        state = RechercheState.success(trimmed, searchResult);
      } else {
        state = RechercheState.error(
          trimmed,
          response.message ?? 'Aucun résultat trouvé.',
        );
      }
    } catch (e) {
      state = RechercheState.error(
        trimmed,
        'Erreur de connexion. Vérifiez votre réseau.',
      );
    }
  }

  /// Réinitialise l'état de recherche.
  void reset() {
    _debounceTimer?.cancel();
    state = const RechercheState.idle();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider de recherche globale pour le mode visiteur et citoyen.
final rechercheProvider =
    StateNotifierProvider<RechercheNotifier, RechercheState>((ref) {
  return RechercheNotifier(ref);
});

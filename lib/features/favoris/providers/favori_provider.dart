import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../../../shared/enums/user_role.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../profil/providers/profil_provider.dart';
import '../models/favori_model.dart';
import '../services/favori_service.dart';

final favoriServiceProvider = Provider<FavoriService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FavoriService(apiClient);
});

class FavorisState {
  final List<FavoriItemModel> items;
  final FavoriCountModel counts;
  final Set<int> planteIds;
  final Set<int> produitIds;
  final Set<int> pharmacopeeIds;
  final bool isLoading;
  final String? error;

  const FavorisState({
    this.items = const [],
    this.counts = const FavoriCountModel(),
    this.planteIds = const {},
    this.produitIds = const {},
    this.pharmacopeeIds = const {},
    this.isLoading = false,
    this.error,
  });

  bool isFavorite(TypeFavori type, int cibleId) {
    switch (type) {
      case TypeFavori.plante:
        return planteIds.contains(cibleId);
      case TypeFavori.produit:
        return produitIds.contains(cibleId);
      case TypeFavori.pharmacopee:
        return pharmacopeeIds.contains(cibleId);
    }
  }

  FavorisState copyWith({
    List<FavoriItemModel>? items,
    FavoriCountModel? counts,
    Set<int>? planteIds,
    Set<int>? produitIds,
    Set<int>? pharmacopeeIds,
    bool? isLoading,
    String? error,
  }) {
    return FavorisState(
      items: items ?? this.items,
      counts: counts ?? this.counts,
      planteIds: planteIds ?? this.planteIds,
      produitIds: produitIds ?? this.produitIds,
      pharmacopeeIds: pharmacopeeIds ?? this.pharmacopeeIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavorisNotifier extends StateNotifier<FavorisState> {
  final FavoriService _service;
  final Ref _ref;

  FavorisNotifier(this._service, this._ref) : super(const FavorisState()) {
    final auth = _ref.read(authStateProvider);
    if (auth.isAuthenticated && auth.role == UserRole.population) {
      Future.microtask(chargerFavoris);
    }
  }

  Future<void> chargerFavoris() async {
    final auth = _ref.read(authStateProvider);
    if (!auth.isAuthenticated || auth.role != UserRole.population) {
      state = const FavorisState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getMesFavoris(size: 100),
        _service.getCounts(),
      ]);
      final items = results[0] as List<FavoriItemModel>;
      final counts = results[1] as FavoriCountModel;

      final plantes = <int>{};
      final produits = <int>{};
      final pharmacopees = <int>{};

      for (final item in items) {
        final cId = item.cibleId;
        if (cId <= 0) continue;
        switch (item.type) {
          case TypeFavori.plante:
            plantes.add(cId);
            break;
          case TypeFavori.produit:
            produits.add(cId);
            break;
          case TypeFavori.pharmacopee:
            pharmacopees.add(cId);
            break;
        }
      }

      state = state.copyWith(
        items: items,
        counts: counts,
        planteIds: plantes,
        produitIds: produits,
        pharmacopeeIds: pharmacopees,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Bascule l'état favori d'un élément (Plante, Produit, Pharmacopée) avec mise à jour optimiste.
  Future<ToggleFavoriResponse?> toggleFavori({
    required TypeFavori type,
    required int cibleId,
  }) async {
    final currentlyFav = state.isFavorite(type, cibleId);

    // Mise à jour optimiste immédiate de l'icône coeur
    _updateLocalSet(type, cibleId, !currentlyFav);

    try {
      final res = await _service.toggleFavori(type: type, cibleId: cibleId);
      _updateLocalSet(type, cibleId, res.favori);
      // Rafraîchir la liste complète et le profil en arrière-plan
      Future.microtask(() async {
        await chargerFavoris();
        try {
          await _ref.read(profilProvider.notifier).chargerProfil();
        } catch (_) {}
      });
      return res;
    } catch (e) {
      // Annuler la mise à jour optimiste en cas d'erreur
      _updateLocalSet(type, cibleId, currentlyFav);
      return null;
    }
  }

  Future<bool> supprimerFavoriById(FavoriItemModel item) async {
    final cId = item.cibleId;
    _updateLocalSet(item.type, cId, false);
    state = state.copyWith(
      items: state.items.where((i) => i.id != item.id).toList(),
    );
    try {
      await _service.deleteFavoriById(item.id);
      await chargerFavoris();
      try {
        await _ref.read(profilProvider.notifier).chargerProfil();
      } catch (_) {}
      return true;
    } catch (_) {
      await chargerFavoris();
      return false;
    }
  }

  void _updateLocalSet(TypeFavori type, int cibleId, bool isFav) {
    switch (type) {
      case TypeFavori.plante:
        final next = Set<int>.from(state.planteIds);
        isFav ? next.add(cibleId) : next.remove(cibleId);
        state = state.copyWith(planteIds: next);
        break;
      case TypeFavori.produit:
        final next = Set<int>.from(state.produitIds);
        isFav ? next.add(cibleId) : next.remove(cibleId);
        state = state.copyWith(produitIds: next);
        break;
      case TypeFavori.pharmacopee:
        final next = Set<int>.from(state.pharmacopeeIds);
        isFav ? next.add(cibleId) : next.remove(cibleId);
        state = state.copyWith(pharmacopeeIds: next);
        break;
    }
  }
}

final favorisProvider =
    StateNotifierProvider<FavorisNotifier, FavorisState>((ref) {
  final service = ref.watch(favoriServiceProvider);
  // Réagir aux changements de session utilisateur
  ref.watch(authStateProvider.select((s) => s.isAuthenticated));
  return FavorisNotifier(service, ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pharmacopee_produit_item_model.dart';
import 'pharmacopee_provider.dart';

/// État du filtre et de l'affichage de la fiche pharmacopée.
class PharmacopeeDetailState {
  final String searchQuery;
  final String initialSearchQuery;
  final List<String> matchedProduitNames;
  final String? selectedCategory;
  final String selectedModeRetrait; // 'ALL', 'LIVRAISON', 'PICKUP'

  const PharmacopeeDetailState({
    this.searchQuery = '',
    this.initialSearchQuery = '',
    this.matchedProduitNames = const [],
    this.selectedCategory,
    this.selectedModeRetrait = 'ALL',
  });

  PharmacopeeDetailState copyWith({
    String? searchQuery,
    String? initialSearchQuery,
    List<String>? matchedProduitNames,
    String? selectedCategory,
    bool clearCategory = false,
    String? selectedModeRetrait,
  }) {
    return PharmacopeeDetailState(
      searchQuery: searchQuery ?? this.searchQuery,
      initialSearchQuery: initialSearchQuery ?? this.initialSearchQuery,
      matchedProduitNames: matchedProduitNames ?? this.matchedProduitNames,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedModeRetrait: selectedModeRetrait ?? this.selectedModeRetrait,
    );
  }
}

/// Contrôleur Riverpod pour la gestion interactive de la fiche Pharmacopée.
class PharmacopeeDetailController extends StateNotifier<PharmacopeeDetailState> {
  PharmacopeeDetailController() : super(const PharmacopeeDetailState());

  void initFromSearch({
    String? query,
    List<String> matchedProduits = const [],
  }) {
    final cleanedQuery = (query ?? '').trim();
    final cleanedMatched = matchedProduits
        .map((label) {
          final idx = label.lastIndexOf(' (');
          return (idx > 0 ? label.substring(0, idx) : label).trim().toLowerCase();
        })
        .where((s) => s.isNotEmpty)
        .toList();

    state = state.copyWith(
      searchQuery: cleanedQuery,
      initialSearchQuery: cleanedQuery,
      matchedProduitNames: cleanedMatched,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      initialSearchQuery: '',
      matchedProduitNames: const [],
    );
  }

  void selectCategory(String? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(
        selectedCategory: category,
        clearCategory: category == null,
      );
    }
  }

  void selectModeRetrait(String mode) {
    state = state.copyWith(selectedModeRetrait: mode);
  }

  void reset() {
    state = const PharmacopeeDetailState();
  }
}

/// Fournisseur d'état interactif de la pharmacopée
final pharmacopeeDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<PharmacopeeDetailController, PharmacopeeDetailState, int>(
  (ref, pharmacopeeId) => PharmacopeeDetailController(),
);

/// Fournisseur des catégories uniques disponibles dans cette pharmacopée
final pharmacopeeCategoriesProvider =
    Provider.autoDispose.family<List<String>, int>((ref, pharmacopeeId) {
  final produitsAsync = ref.watch(pharmacopeeProduitsProvider(pharmacopeeId));
  return produitsAsync.maybeWhen(
    data: (produits) {
      final categories = produits
          .map((p) => p.categorieNom)
          .where((cat) => cat != null && cat.trim().isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      categories.sort();
      return categories;
    },
    orElse: () => const [],
  );
});

/// Fournisseur des produits filtrés selon la recherche interne, la maladie/plante recherchée et la catégorie sélectionnée
final pharmacopeeFilteredProduitsProvider =
    Provider.autoDispose.family<List<PharmacopeeProduitItemModel>, int>(
  (ref, pharmacopeeId) {
    final produitsAsync = ref.watch(pharmacopeeProduitsProvider(pharmacopeeId));
    final controllerState =
        ref.watch(pharmacopeeDetailControllerProvider(pharmacopeeId));

    return produitsAsync.maybeWhen(
      data: (produits) {
        // 1. Filtrer d'abord par disponibilité et catégorie
        final baseAvailable = produits.where((prod) {
          if (!prod.disponible || prod.quantiteStock <= 0) {
            return false;
          }
          if (controllerState.selectedCategory != null &&
              controllerState.selectedCategory!.isNotEmpty) {
            if (prod.categorieNom?.toLowerCase() !=
                controllerState.selectedCategory!.toLowerCase()) {
              return false;
            }
          }
          return true;
        }).toList();

        final query = controllerState.searchQuery.trim().toLowerCase();
        if (query.isEmpty) {
          return baseAvailable;
        }

        final isInitialSearch =
            query == controllerState.initialSearchQuery.trim().toLowerCase();

        final filtered = baseAvailable.where((prod) {
          final prodNomLower = prod.nom.toLowerCase();
          final matchesNom = prodNomLower.contains(query);
          final matchesDesc =
              prod.description?.toLowerCase().contains(query) ?? false;
          final matchesForme =
              prod.forme?.toLowerCase().contains(query) ?? false;
          final matchesCat =
              prod.categorieNom?.toLowerCase().contains(query) ?? false;
          final matchesMaladie =
              prod.maladies.any((m) => m.toLowerCase().contains(query));
          final matchesPlante =
              prod.plantes.any((pl) => pl.toLowerCase().contains(query));
          final matchesPrecomputed = isInitialSearch &&
              controllerState.matchedProduitNames.any(
                (mp) => prodNomLower.contains(mp) || mp.contains(prodNomLower),
              );

          return matchesNom ||
              matchesDesc ||
              matchesForme ||
              matchesCat ||
              matchesMaladie ||
              matchesPlante ||
              matchesPrecomputed;
        }).toList();

        // Si la requête initiale provenait du nom même de la pharmacopée ou de sa ville
        // (et qu'aucun produit spécifique ne correspond au mot-clé), afficher tous les produits disponibles
        if (filtered.isEmpty &&
            isInitialSearch &&
            controllerState.matchedProduitNames.isEmpty) {
          return baseAvailable;
        }

        return filtered;
      },
      orElse: () => const [],
    );
  },
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pharmacopee_produit_item_model.dart';
import 'pharmacopee_provider.dart';

/// État du filtre et de l'affichage de la fiche pharmacopée.
class PharmacopeeDetailState {
  final String searchQuery;
  final String? selectedCategory;
  final String selectedModeRetrait; // 'ALL', 'LIVRAISON', 'PICKUP'

  const PharmacopeeDetailState({
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedModeRetrait = 'ALL',
  });

  PharmacopeeDetailState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    String? selectedModeRetrait,
  }) {
    return PharmacopeeDetailState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedModeRetrait: selectedModeRetrait ?? this.selectedModeRetrait,
    );
  }
}

/// Contrôleur Riverpod pour la gestion interactive de la fiche Pharmacopée.
class PharmacopeeDetailController extends StateNotifier<PharmacopeeDetailState> {
  PharmacopeeDetailController() : super(const PharmacopeeDetailState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
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

/// Fournisseur des produits filtrés selon la recherche interne et la catégorie sélectionnée
final pharmacopeeFilteredProduitsProvider =
    Provider.autoDispose.family<List<PharmacopeeProduitItemModel>, int>(
  (ref, pharmacopeeId) {
    final produitsAsync = ref.watch(pharmacopeeProduitsProvider(pharmacopeeId));
    final controllerState =
        ref.watch(pharmacopeeDetailControllerProvider(pharmacopeeId));

    return produitsAsync.maybeWhen(
      data: (produits) {
        return produits.where((prod) {
          // Filtre : uniquement les produits en stock
          if (!prod.disponible || prod.quantiteStock <= 0) {
            return false;
          }

          // Filtre par catégorie
          if (controllerState.selectedCategory != null &&
              controllerState.selectedCategory!.isNotEmpty) {
            if (prod.categorieNom?.toLowerCase() !=
                controllerState.selectedCategory!.toLowerCase()) {
              return false;
            }
          }

          // Filtre par recherche textuelle (sur nom, description, forme)
          final query = controllerState.searchQuery.toLowerCase();
          if (query.isNotEmpty) {
            final matchesNom = prod.nom.toLowerCase().contains(query);
            final matchesDesc =
                prod.description?.toLowerCase().contains(query) ?? false;
            final matchesForme =
                prod.forme?.toLowerCase().contains(query) ?? false;
            final matchesCat =
                prod.categorieNom?.toLowerCase().contains(query) ?? false;

            if (!matchesNom && !matchesDesc && !matchesForme && !matchesCat) {
              return false;
            }
          }

          return true;
        }).toList();
      },
      orElse: () => const [],
    );
  },
);


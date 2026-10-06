import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../plantes/models/produit_model.dart';
import '../models/panier_item_model.dart';

class PanierNotifier extends StateNotifier<List<PanierItemModel>> {
  PanierNotifier() : super([]);

  void ajouterProduit(ProduitModel produit) {
    final existingIndex = state.indexWhere((item) => item.produit.id == produit.id);
    if (existingIndex >= 0) {
      final current = state[existingIndex];
      final updated = current.copyWith(quantite: current.quantite + 1);
      final list = List<PanierItemModel>.from(state);
      list[existingIndex] = updated;
      state = list;
    } else {
      state = [...state, PanierItemModel(produit: produit, quantite: 1)];
    }
  }

  void retirerProduit(int produitId) {
    state = state.where((item) => item.produit.id != produitId).toList();
  }

  void modifierQuantite(int produitId, int nouvelleQuantite) {
    if (nouvelleQuantite <= 0) {
      retirerProduit(produitId);
      return;
    }
    state = state.map((item) {
      if (item.produit.id == produitId) {
        return item.copyWith(quantite: nouvelleQuantite);
      }
      return item;
    }).toList();
  }

  void vider() {
    state = [];
  }

  double get montantTotal => state.fold(0.0, (sum, item) => sum + item.sousTotal);
  int get nombreArticles => state.fold(0, (sum, item) => sum + item.quantite);
}

final panierProvider =
    StateNotifierProvider<PanierNotifier, List<PanierItemModel>>((ref) {
  return PanierNotifier();
});

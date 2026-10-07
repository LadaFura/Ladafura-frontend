import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth.dart';
import '../../../core/services/storage_service.dart';
import '../../plantes/models/produit_model.dart';
import '../models/panier_item_model.dart';
import '../models/panier_model.dart';
import '../services/panier_service.dart';

/// État du panier d'achat.
class PanierState {
  final PanierModel panier;
  final bool isLoading;
  final String? errorMessage;
  final int? updatingLigneId;
  final int? pharmacopeeId;
  final String? nomPharmacopee;

  const PanierState({
    required this.panier,
    this.isLoading = false,
    this.errorMessage,
    this.updatingLigneId,
    this.pharmacopeeId,
    this.nomPharmacopee,
  });

  bool get estVide => panier.estVide;
  int get nombreArticles => panier.nombreArticles;
  double get montantTotal => panier.montantTotal;
  List<LignePanierModel> get lignes => panier.lignes;

  PanierState copyWith({
    PanierModel? panier,
    bool? isLoading,
    String? errorMessage,
    int? updatingLigneId,
    bool clearUpdating = false,
    int? pharmacopeeId,
    String? nomPharmacopee,
  }) {
    return PanierState(
      panier: panier ?? this.panier,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      updatingLigneId:
          clearUpdating ? null : (updatingLigneId ?? this.updatingLigneId),
      pharmacopeeId: pharmacopeeId ?? this.pharmacopeeId,
      nomPharmacopee: nomPharmacopee ?? this.nomPharmacopee,
    );
  }
}

/// Notifier Riverpod gérant le panier d'achat connecté à l'API Spring Boot.
class PanierNotifier extends StateNotifier<PanierState> {
  final PanierService _service;
  final Ref _ref;

  PanierNotifier(this._service, this._ref)
      : super(PanierState(
          panier: PanierModel.vide(),
          pharmacopeeId: StorageService.instance.getCartPharmacopeeId(),
          nomPharmacopee: StorageService.instance.getCartPharmacopeeNom(),
        )) {
    chargerPanier();
  }

  /// Charge le panier depuis le backend si l'utilisateur est authentifié.
  Future<void> chargerPanier() async {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      state = state.copyWith(panier: PanierModel.vide(), isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final panier = await _service.getPanier();
      final savedPharmaId = StorageService.instance.getCartPharmacopeeId();
      final savedPharmaNom = StorageService.instance.getCartPharmacopeeNom();

      state = state.copyWith(
        panier: panier,
        isLoading: false,
        pharmacopeeId: state.pharmacopeeId ?? savedPharmaId,
        nomPharmacopee: state.nomPharmacopee ?? savedPharmaNom,
      );

      // Si le panier distant est vide, réinitialiser la pharmacopée
      if (panier.estVide) {
        StorageService.instance.clearCartPharmacopee();
        state = state.copyWith(pharmacopeeId: null, nomPharmacopee: null);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erreur lors du chargement du panier : $e",
      );
    }
  }

  /// Associe explicitement la pharmacopée source active.
  void setPharmacopeeSource(int pharmacopeeId, String nomPharmacopee) {
    StorageService.instance.saveCartPharmacopee(pharmacopeeId, nomPharmacopee);
    state = state.copyWith(
      pharmacopeeId: pharmacopeeId,
      nomPharmacopee: nomPharmacopee,
    );
  }

  /// Ajoute un produit au panier.
  Future<bool> ajouterProduit(
    int produitId, {
    int quantite = 1,
    int? pharmacopeeId,
    String? nomPharmacopee,
  }) async {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      return false; // Devra rediriger vers login
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _service.ajouterProduit(
        produitId: produitId,
        quantite: quantite,
      );

      final finalPharmaId = pharmacopeeId ?? state.pharmacopeeId;
      final finalPharmaNom = nomPharmacopee ?? state.nomPharmacopee;

      if (finalPharmaId != null && finalPharmaNom != null) {
        StorageService.instance.saveCartPharmacopee(finalPharmaId, finalPharmaNom);
      }

      state = state.copyWith(
        panier: updated,
        isLoading: false,
        pharmacopeeId: finalPharmaId,
        nomPharmacopee: finalPharmaNom,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Impossible d'ajouter le produit au panier : $e",
      );
      return false;
    }
  }

  /// Met à jour la quantité d'une ligne d'article.
  Future<void> modifierQuantite(int ligneId, int nouvelleQuantite) async {
    if (nouvelleQuantite <= 0) {
      await supprimerLigne(ligneId);
      return;
    }

    state = state.copyWith(updatingLigneId: ligneId, errorMessage: null);
    try {
      final updated = await _service.modifierQuantite(
        ligneId: ligneId,
        quantite: nouvelleQuantite,
      );
      state = state.copyWith(
        panier: updated,
        clearUpdating: true,
      );
    } catch (e) {
      state = state.copyWith(
        clearUpdating: true,
        errorMessage: "Impossible de modifier la quantité",
      );
    }
  }

  /// Supprime une ligne spécifique.
  Future<void> supprimerLigne(int ligneId) async {
    state = state.copyWith(updatingLigneId: ligneId, errorMessage: null);
    try {
      final updated = await _service.supprimerLigne(ligneId);
      state = state.copyWith(
        panier: updated,
        clearUpdating: true,
      );
      if (updated.estVide) {
        StorageService.instance.clearCartPharmacopee();
        state = state.copyWith(pharmacopeeId: null, nomPharmacopee: null);
      }
    } catch (e) {
      state = state.copyWith(
        clearUpdating: true,
        errorMessage: "Impossible de supprimer l'article",
      );
    }
  }

  /// Vide complètement le panier.
  Future<void> vider() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _service.viderPanier();
      StorageService.instance.clearCartPharmacopee();
      state = state.copyWith(
        panier: PanierModel.vide(),
        isLoading: false,
        pharmacopeeId: null,
        nomPharmacopee: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Impossible de vider le panier",
      );
    }
  }
}

/// Provider du panier principal (StateNotifier).
final panierStateProvider =
    StateNotifierProvider<PanierNotifier, PanierState>((ref) {
  final service = ref.watch(panierServiceProvider);
  return PanierNotifier(service, ref);
});

/// Adaptateur de compatibilité pour l'ancien `panierProvider` utilisé dans certains tests ou widgets.
final panierProvider = Provider<List<PanierItemModel>>((ref) {
  final state = ref.watch(panierStateProvider);
  return state.panier.lignes.map((l) {
    return PanierItemModel(
      produit: ProduitModel(
        id: l.produitId,
        nom: l.nomProduit,
        forme: l.forme,
        prixIndicatif: l.prixUnitaire,
        photoUrl: l.photoUrl,
        disponibleEnPharmacie: l.disponible,
      ),
      quantite: l.quantite,
    );
  }).toList();
});

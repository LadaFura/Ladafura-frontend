import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth.dart';
import '../models/commande_model.dart';
import '../models/mode_retrait_model.dart';
import '../models/paiement_model.dart';
import '../services/commande_service.dart';

// --- Fournisseurs de consultation ---

/// Liste des méthodes de paiement disponibles sur LADAFURA
final methodesPaiementProvider =
    FutureProvider<List<MethodePaiementModel>>((ref) async {
  final service = ref.watch(commandeServiceProvider);
  return await service.getMethodesPaiement();
});

/// Modes de retrait proposés par une pharmacopée donnée
final pharmacopeeRetraitOptionsProvider = FutureProvider.family<
    PharmacopeeRetraitOptionsModel, int>((ref, pharmacopeeId) async {
  final service = ref.watch(commandeServiceProvider);
  return await service.getOptionsRetrait(pharmacopeeId);
});

/// Historique des commandes avec filtre de statut optionnel
final commandesHistoriqueProvider =
    FutureProvider.family<List<CommandeSummaryModel>, String?>((ref, statut) async {
  final auth = ref.watch(authStateProvider);
  if (!auth.isAuthenticated) return [];
  final service = ref.watch(commandeServiceProvider);
  return await service.getHistoriqueCommandes(statut: statut);
});

/// Détail d'une commande spécifique
final commandeDetailProvider =
    FutureProvider.family<CommandeDetailModel, int>((ref, commandeId) async {
  final service = ref.watch(commandeServiceProvider);
  return await service.getCommandeDetail(commandeId);
});

// Compatibilité avec l'ancien mesCommandesProvider
final mesCommandesProvider = FutureProvider<List<CommandeModel>>((ref) async {
  final auth = ref.watch(authStateProvider);
  if (!auth.isAuthenticated) return [];
  final service = ref.watch(commandeServiceProvider);
  try {
    return await service.fetchMesCommandes();
  } catch (_) {
    return [];
  }
});

// --- StateNotifier pour le Tunnel de Commande (Checkout) ---

class CheckoutState {
  final int? pharmacopeeId;
  final String? nomPharmacopee;
  final ModeRetraitOptionModel? selectedModeRetrait;
  final String? adresseLivraison;
  final String? notes;
  final CommandeRecapitulatifModel? recapitulatif;
  final bool isLoading;
  final String? errorMessage;
  final CommandeDetailModel? commandeCreee;

  const CheckoutState({
    this.pharmacopeeId,
    this.nomPharmacopee,
    this.selectedModeRetrait,
    this.adresseLivraison,
    this.notes,
    this.recapitulatif,
    this.isLoading = false,
    this.errorMessage,
    this.commandeCreee,
  });

  CheckoutState copyWith({
    int? pharmacopeeId,
    String? nomPharmacopee,
    ModeRetraitOptionModel? selectedModeRetrait,
    String? adresseLivraison,
    String? notes,
    CommandeRecapitulatifModel? recapitulatif,
    bool? isLoading,
    String? errorMessage,
    CommandeDetailModel? commandeCreee,
    bool clearRecapitulatif = false,
  }) {
    return CheckoutState(
      pharmacopeeId: pharmacopeeId ?? this.pharmacopeeId,
      nomPharmacopee: nomPharmacopee ?? this.nomPharmacopee,
      selectedModeRetrait: selectedModeRetrait ?? this.selectedModeRetrait,
      adresseLivraison: adresseLivraison ?? this.adresseLivraison,
      notes: notes ?? this.notes,
      recapitulatif:
          clearRecapitulatif ? null : (recapitulatif ?? this.recapitulatif),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      commandeCreee: commandeCreee ?? this.commandeCreee,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CommandeService _service;

  CheckoutNotifier(this._service) : super(const CheckoutState());

  void initCheckout({required int pharmacopeeId, required String nomPharmacopee}) {
    state = CheckoutState(
      pharmacopeeId: pharmacopeeId,
      nomPharmacopee: nomPharmacopee,
    );
  }

  void selectModeRetrait(ModeRetraitOptionModel mode) {
    state = state.copyWith(
      selectedModeRetrait: mode,
      errorMessage: null,
    );
    _calculerRecapitulatif();
  }

  void updateAdresseLivraison(String adresse) {
    state = state.copyWith(adresseLivraison: adresse);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<void> _calculerRecapitulatif() async {
    if (state.pharmacopeeId == null || state.selectedModeRetrait == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final recap = await _service.getRecapitulatif(
        pharmacopeeId: state.pharmacopeeId!,
        modeRetraitId: state.selectedModeRetrait!.id,
      );
      state = state.copyWith(recapitulatif: recap, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Impossible de calculer le montant : $e",
      );
    }
  }

  /// Valide la commande et son paiement simultanément de façon atomique.
  /// Si le paiement échoue, aucune commande n'est créée et le panier reste intact.
  Future<CommandeDetailModel?> passerEtPayerCommande({
    required String methode,
    String? operateur,
    String? telephoneMobileMoney,
    String? referenceTransaction,
    bool simulerSucces = true,
  }) async {
    if (state.pharmacopeeId == null || state.selectedModeRetrait == null) {
      state = state.copyWith(
          errorMessage: "Veuillez sélectionner un mode de mise à disposition.");
      return null;
    }

    if (state.selectedModeRetrait!.isLivraison &&
        (state.adresseLivraison == null ||
            state.adresseLivraison!.trim().isEmpty)) {
      state = state.copyWith(
          errorMessage: "L'adresse de livraison est requise pour la livraison.");
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final commande = await _service.passerCommande(
        pharmacopeeId: state.pharmacopeeId!,
        modeRetraitId: state.selectedModeRetrait!.id,
        adresseLivraison: state.adresseLivraison,
        notes: state.notes,
        methode: methode,
        operateur: operateur,
        telephoneMobileMoney: telephoneMobileMoney,
        referenceTransaction: referenceTransaction,
        simulerSucces: simulerSucces,
      );
      state = state.copyWith(
        isLoading: false,
        commandeCreee: commande,
      );
      return commande;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Échec du règlement : $e",
      );
      rethrow;
    }
  }

  /// Rétrocompatibilité : passe la commande avec la méthode CASH par défaut
  Future<CommandeDetailModel?> passerCommande({String methode = 'CASH'}) async {
    return passerEtPayerCommande(methode: methode);
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final service = ref.watch(commandeServiceProvider);
  return CheckoutNotifier(service);
});

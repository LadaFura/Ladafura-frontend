import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/agent_api_service.dart';
import '../models/agent_collecte_detail_model.dart';
import '../../collectes/models/agent_collecte_summary_response.dart';
import '../models/agent_dashboard_model.dart';
import '../models/agent_maladie_model.dart';
import '../models/agent_plante_model.dart';
import '../models/agent_recapitulatif_model.dart';
import '../models/agent_source_model.dart';

/// Provider singleton du service API Agent
final agentApiServiceProvider = Provider<AgentApiService>((ref) {
  return AgentApiService();
});

/// Provider du tableau de bord consolidé en direct
final agentDashboardFutureProvider = FutureProvider<AgentDashboardModel>((ref) async {
  final api = ref.watch(agentApiServiceProvider);
  return api.getDashboard();
});

/// Filtre actuel des collectes (TOUTES, BROUILLON, SOUMISE, VALIDEE, REJETEE)
final agentCollectesFilterProvider = StateProvider<String>((ref) => 'TOUTES');

/// Provider de la liste des collectes (filtrable)
final agentCollectesListProvider = FutureProvider<List<AgentCollecteSummaryResponse>>((ref) async {
  final api = ref.watch(agentApiServiceProvider);
  final filter = ref.watch(agentCollectesFilterProvider);
  return api.getCollectes(statut: filter);
});

/// Provider du détail d'une collecte par identifiant
final agentCollecteDetailProvider =
    FutureProvider.family<AgentCollecteDetailModel, int>((ref, collecteId) async {
  final api = ref.watch(agentApiServiceProvider);
  return api.getCollecteDetail(collecteId);
});

/// Provider du récapitulatif pré-soumission
final agentCollecteRecapitulatifProvider =
    FutureProvider.family<AgentCollecteRecapitulatifModel, int>((ref, collecteId) async {
  final api = ref.watch(agentApiServiceProvider);
  return api.getRecapitulatif(collecteId);
});

/// Provider de la liste des sources
final agentSourcesListProvider = FutureProvider<List<AgentSourceModel>>((ref) async {
  final api = ref.watch(agentApiServiceProvider);
  return api.getSources();
});

// =============================================================================
// STATE & NOTIFIER DU WIZARD « NOUVELLE COLLECTE »
// =============================================================================

class NouvelleCollecteDraftState {
  final int currentStep; // 0 à 5
  final int? collecteId;
  final bool isDraftSaved;
  final bool isLoading;
  final String? errorMessage;

  // Step 1 : Plante
  final AgentPlanteModel? selectedPlante;

  // Step 2 : Maladies sélectionnées
  final List<AgentMaladieModel> selectedMaladies;

  // Step 3 : Connaissance traditionnelle
  final String usageRapporte;
  final String partieUtilisee;
  final String preparation;
  final String precaution;

  // Step 4 : Source
  final AgentSourceModel? selectedSource;

  // Step 5 : Localisation & Médias
  final String region;
  final String cercle;
  final String commune;
  final String localite;
  final double? latitude;
  final double? longitude;
  final File? photoFile;
  final File? audioFile;

  // Step 6 : Récapitulatif
  final AgentCollecteRecapitulatifModel? recapitulatif;

  const NouvelleCollecteDraftState({
    this.currentStep = 0,
    this.collecteId,
    this.isDraftSaved = false,
    this.isLoading = false,
    this.errorMessage,
    this.selectedPlante,
    this.selectedMaladies = const [],
    this.usageRapporte = '',
    this.partieUtilisee = '',
    this.preparation = '',
    this.precaution = '',
    this.selectedSource,
    this.region = '',
    this.cercle = '',
    this.commune = '',
    this.localite = '',
    this.latitude,
    this.longitude,
    this.photoFile,
    this.audioFile,
    this.recapitulatif,
  });

  NouvelleCollecteDraftState copyWith({
    int? currentStep,
    int? collecteId,
    bool? isDraftSaved,
    bool? isLoading,
    String? errorMessage,
    AgentPlanteModel? selectedPlante,
    List<AgentMaladieModel>? selectedMaladies,
    String? usageRapporte,
    String? partieUtilisee,
    String? preparation,
    String? precaution,
    AgentSourceModel? selectedSource,
    String? region,
    String? cercle,
    String? commune,
    String? localite,
    double? latitude,
    double? longitude,
    File? photoFile,
    File? audioFile,
    AgentCollecteRecapitulatifModel? recapitulatif,
  }) {
    return NouvelleCollecteDraftState(
      currentStep: currentStep ?? this.currentStep,
      collecteId: collecteId ?? this.collecteId,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedPlante: selectedPlante ?? this.selectedPlante,
      selectedMaladies: selectedMaladies ?? this.selectedMaladies,
      usageRapporte: usageRapporte ?? this.usageRapporte,
      partieUtilisee: partieUtilisee ?? this.partieUtilisee,
      preparation: preparation ?? this.preparation,
      precaution: precaution ?? this.precaution,
      selectedSource: selectedSource ?? this.selectedSource,
      region: region ?? this.region,
      cercle: cercle ?? this.cercle,
      commune: commune ?? this.commune,
      localite: localite ?? this.localite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoFile: photoFile ?? this.photoFile,
      audioFile: audioFile ?? this.audioFile,
      recapitulatif: recapitulatif ?? this.recapitulatif,
    );
  }
}

class NouvelleCollecteWizardNotifier extends StateNotifier<NouvelleCollecteDraftState> {
  final AgentApiService _api;
  final Ref _ref;

  NouvelleCollecteWizardNotifier(this._api, this._ref)
      : super(const NouvelleCollecteDraftState());

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void selectPlante(AgentPlanteModel plante) {
    state = state.copyWith(selectedPlante: plante);
  }

  void addMaladie(AgentMaladieModel maladie) {
    if (state.selectedMaladies.any((m) => m.id == maladie.id)) return;
    state = state.copyWith(selectedMaladies: [...state.selectedMaladies, maladie]);
  }

  void removeMaladie(int maladieId) {
    state = state.copyWith(
      selectedMaladies: state.selectedMaladies.where((m) => m.id != maladieId).toList(),
    );
  }

  void setConnaissances({
    required String usageRapporte,
    required String partieUtilisee,
    required String preparation,
    String? precaution,
  }) {
    state = state.copyWith(
      usageRapporte: usageRapporte,
      partieUtilisee: partieUtilisee,
      preparation: preparation,
      precaution: precaution ?? '',
    );
  }

  void selectSource(AgentSourceModel source) {
    state = state.copyWith(selectedSource: source);
  }

  void setLocalisation({
    required String region,
    String? cercle,
    String? commune,
    String? localite,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      region: region,
      cercle: cercle ?? '',
      commune: commune ?? '',
      localite: localite ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  void setPhoto(File? photo) {
    state = state.copyWith(photoFile: photo);
  }

  void setAudio(File? audio) {
    state = state.copyWith(audioFile: audio);
  }

  /// Sauvegarde la progression sous forme de brouillon
  Future<bool> saveDraft() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      int id = state.collecteId ?? 0;
      if (id == 0) {
        final draft = await _api.createDraft(
          description: state.usageRapporte.isNotEmpty
              ? state.usageRapporte
              : 'Collecte de ${state.selectedPlante?.nomScientifique ?? "terrain"}',
          sourceId: state.selectedSource?.id,
        );
        id = draft.id;
        state = state.copyWith(collecteId: id, isDraftSaved: true);
      }

      // Associer la plante si sélectionnée
      if (state.selectedPlante != null) {
        try {
          await _api.associerPlanteACollecte(
            collecteId: id,
            planteId: state.selectedPlante!.id,
          );
        } catch (_) {}
      }

      // Enregistrer connaissance & maladies
      if (state.selectedPlante != null && state.usageRapporte.isNotEmpty) {
        try {
          await _api.enregistrerConnaissance(
            collecteId: id,
            planteId: state.selectedPlante!.id,
            usageRapporte: state.usageRapporte,
            partieUtilisee: state.partieUtilisee.isNotEmpty ? state.partieUtilisee : 'Feuilles',
            preparation: state.preparation.isNotEmpty ? state.preparation : 'Décoction',
            precaution: state.precaution.isNotEmpty ? state.precaution : null,
            sourceId: state.selectedSource?.id,
            maladieIds: state.selectedMaladies.map((m) => m.id).toList(),
          );
        } catch (_) {}
      }

      // Enregistrer localisation si saisie
      if (state.region.isNotEmpty) {
        try {
          await _api.enregistrerLocalisation(
            collecteId: id,
            region: state.region,
            cercle: state.cercle.isNotEmpty ? state.cercle : null,
            commune: state.commune.isNotEmpty ? state.commune : null,
            localite: state.localite.isNotEmpty ? state.localite : null,
            latitude: state.latitude,
            longitude: state.longitude,
          );
        } catch (_) {}
      }

      // Médias
      if (state.photoFile != null) {
        try {
          await _api.uploadPhoto(collecteId: id, file: state.photoFile!);
        } catch (_) {}
      }
      if (state.audioFile != null) {
        try {
          await _api.uploadAudio(collecteId: id, file: state.audioFile!);
        } catch (_) {}
      }

      // Rafraîchir les listes
      _ref.invalidate(agentCollectesListProvider);
      _ref.invalidate(agentDashboardFutureProvider);

      state = state.copyWith(isLoading: false, isDraftSaved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Charge le récapitulatif officiel avant soumission finale
  Future<void> fetchRecapitulatif() async {
    if (state.collecteId == null) {
      await saveDraft();
    }
    if (state.collecteId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final recap = await _api.getRecapitulatif(state.collecteId!);
      state = state.copyWith(isLoading: false, recapitulatif: recap);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Soumet définitivement la collecte au comité de validation
  Future<bool> soumettre() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (state.collecteId == null) {
        final saved = await saveDraft();
        if (!saved || state.collecteId == null) {
          throw Exception("Impossible de créer le dossier de collecte");
        }
      }
      await _api.soumettreCollecte(state.collecteId!);
      _ref.invalidate(agentCollectesListProvider);
      _ref.invalidate(agentDashboardFutureProvider);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const NouvelleCollecteDraftState();
  }
}

final nouvelleCollecteWizardProvider =
    StateNotifierProvider<NouvelleCollecteWizardNotifier, NouvelleCollecteDraftState>((ref) {
  final api = ref.watch(agentApiServiceProvider);
  return NouvelleCollecteWizardNotifier(api, ref);
});


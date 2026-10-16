import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/error_handler.dart';
import '../data/agent_api_service.dart';
import '../models/agent_collecte_detail_model.dart';
import '../../collectes/models/agent_collecte_summary_response.dart';
import '../models/agent_dashboard_model.dart';
import '../models/agent_maladie_model.dart';
import '../models/agent_notification_response.dart';
import '../models/agent_plante_model.dart';
import '../models/agent_profile_model.dart';
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

/// Provider du profil de l'agent de collecte connecté
final agentProfileProvider = FutureProvider<AgentProfileModel>((ref) async {
  final api = ref.watch(agentApiServiceProvider);
  return api.getProfile();
});

/// Filtre actuel des notifications agent (TOUTES, NON_LUES, COLLECTE_VALIDEE, COLLECTE_REJETEE, COLLECTE_CORRECTION)
final agentNotificationsFilterProvider = StateProvider<String>((ref) => 'TOUTES');

/// Provider de la liste des notifications de l'agent (filtrable)
final agentNotificationsListProvider =
    FutureProvider<List<AgentNotificationResponse>>((ref) async {
  final api = ref.watch(agentApiServiceProvider);
  final filter = ref.watch(agentNotificationsFilterProvider);

  if (filter == 'NON_LUES') {
    return api.getNotifications(lue: false);
  } else if (filter != 'TOUTES') {
    return api.getNotifications(type: filter);
  }
  return api.getNotifications();
});

/// Provider du compteur de notifications non lues pour l'agent de collecte
final agentUnreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(agentApiServiceProvider);
  return api.getUnreadNotificationsCount();
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
  final String? existingPhotoUrl;
  final String? existingAudioUrl;

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
    this.partieUtilisee = 'Feuilles',
    this.preparation = '',
    this.precaution = '',
    this.selectedSource,
    this.region = 'Sikasso',
    this.cercle = '',
    this.commune = '',
    this.localite = '',
    this.latitude,
    this.longitude,
    this.photoFile,
    this.audioFile,
    this.existingPhotoUrl,
    this.existingAudioUrl,
    this.recapitulatif,
  });

  /// Vérifie si les champs obligatoires d'une étape donnée sont remplis
  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return selectedPlante != null && selectedPlante!.id > 0;
      case 1:
        return selectedMaladies.isNotEmpty;
      case 2:
        return usageRapporte.trim().isNotEmpty &&
            partieUtilisee.trim().isNotEmpty &&
            preparation.trim().isNotEmpty;
      case 3:
        return selectedSource != null && selectedSource!.id > 0;
      case 4:
        return region.trim().isNotEmpty &&
            cercle.trim().isNotEmpty &&
            commune.trim().isNotEmpty &&
            localite.trim().isNotEmpty;
      case 5:
        return isAllStepsValid;
      default:
        return true;
    }
  }

  /// Indique si les 5 étapes de saisie sont complètes
  bool get isAllStepsValid =>
      isStepValid(0) &&
      isStepValid(1) &&
      isStepValid(2) &&
      isStepValid(3) &&
      isStepValid(4);

  /// Message explicite indiquant le champ obligatoire manquant pour l'étape courante
  String? stepValidationMessage(int step) {
    if (isStepValid(step)) return null;
    switch (step) {
      case 0:
        return 'Veuillez sélectionner ou ajouter une plante botanique avant de continuer.';
      case 1:
        return 'Veuillez sélectionner ou ajouter au moins une maladie ou symptôme ciblé.';
      case 2:
        if (partieUtilisee.trim().isEmpty) {
          return 'Veuillez saisir ou sélectionner la ou les partie(s) de plante utilisée(s).';
        }
        if (usageRapporte.trim().isEmpty) {
          return 'Veuillez renseigner l’usage traditionnel rapporté avant de continuer.';
        }
        return 'Veuillez renseigner le mode de préparation et d’administration.';
      case 3:
        return 'Veuillez sélectionner ou ajouter l’informateur / tradipraticien source.';
      case 4:
        return 'Veuillez renseigner la région, le cercle, la commune et le village / localité.';
      default:
        return 'Veuillez compléter les champs obligatoires de cette étape.';
    }
  }

  NouvelleCollecteDraftState copyWith({
    int? currentStep,
    int? collecteId,
    bool? isDraftSaved,
    bool? isLoading,
    String? errorMessage,
    AgentPlanteModel? selectedPlante,
    bool clearSelectedPlante = false,
    List<AgentMaladieModel>? selectedMaladies,
    String? usageRapporte,
    String? partieUtilisee,
    String? preparation,
    String? precaution,
    AgentSourceModel? selectedSource,
    bool clearSelectedSource = false,
    String? region,
    String? cercle,
    String? commune,
    String? localite,
    double? latitude,
    double? longitude,
    File? photoFile,
    File? audioFile,
    String? existingPhotoUrl,
    bool clearExistingPhotoUrl = false,
    String? existingAudioUrl,
    bool clearExistingAudioUrl = false,
    AgentCollecteRecapitulatifModel? recapitulatif,
  }) {
    return NouvelleCollecteDraftState(
      currentStep: currentStep ?? this.currentStep,
      collecteId: collecteId ?? this.collecteId,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedPlante: clearSelectedPlante ? null : (selectedPlante ?? this.selectedPlante),
      selectedMaladies: selectedMaladies ?? this.selectedMaladies,
      usageRapporte: usageRapporte ?? this.usageRapporte,
      partieUtilisee: partieUtilisee ?? this.partieUtilisee,
      preparation: preparation ?? this.preparation,
      precaution: precaution ?? this.precaution,
      selectedSource: clearSelectedSource ? null : (selectedSource ?? this.selectedSource),
      region: region ?? this.region,
      cercle: cercle ?? this.cercle,
      commune: commune ?? this.commune,
      localite: localite ?? this.localite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoFile: photoFile ?? this.photoFile,
      audioFile: audioFile ?? this.audioFile,
      existingPhotoUrl: clearExistingPhotoUrl ? null : (existingPhotoUrl ?? this.existingPhotoUrl),
      existingAudioUrl: clearExistingAudioUrl ? null : (existingAudioUrl ?? this.existingAudioUrl),
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

  void selectPlante(AgentPlanteModel? plante) {
    if (plante == null || plante.id <= 0) {
      state = state.copyWith(clearSelectedPlante: true);
    } else {
      state = state.copyWith(selectedPlante: plante);
    }
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

  void selectSource(AgentSourceModel? source) {
    if (source == null || source.id <= 0) {
      state = state.copyWith(clearSelectedSource: true);
    } else {
      state = state.copyWith(selectedSource: source);
    }
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
      final validSourceId =
          (state.selectedSource != null && state.selectedSource!.id > 0)
              ? state.selectedSource!.id
              : null;
      final validPlanteId =
          (state.selectedPlante != null && state.selectedPlante!.id > 0)
              ? state.selectedPlante!.id
              : null;

      int id = state.collecteId ?? 0;
      if (id == 0) {
        final draft = await _api.createDraft(
          description: state.usageRapporte.isNotEmpty
              ? state.usageRapporte
              : 'Collecte de ${state.selectedPlante?.nomScientifique ?? "terrain"}',
          sourceId: validSourceId,
        );
        id = draft.id;
        state = state.copyWith(collecteId: id, isDraftSaved: true);
      } else {
        await _api.updateCollecte(
          id,
          description: state.usageRapporte.isNotEmpty
              ? state.usageRapporte
              : 'Collecte de ${state.selectedPlante?.nomScientifique ?? "terrain"}',
          sourceId: validSourceId,
        );
      }

      // Associer la plante si sélectionnée
      if (validPlanteId != null) {
        try {
          await _api.associerPlanteACollecte(
            collecteId: id,
            planteId: validPlanteId,
          );
        } catch (_) {}
      }

      // Enregistrer connaissance & maladies
      if (validPlanteId != null && state.usageRapporte.trim().isNotEmpty) {
        try {
          await _api.enregistrerConnaissance(
            collecteId: id,
            planteId: validPlanteId,
            usageRapporte: state.usageRapporte.trim(),
            partieUtilisee: state.partieUtilisee.trim().isNotEmpty
                ? state.partieUtilisee.trim()
                : 'Feuilles',
            preparation: state.preparation.trim().isNotEmpty
                ? state.preparation.trim()
                : 'Décoction',
            precaution: state.precaution.trim().isNotEmpty
                ? state.precaution.trim()
                : null,
            sourceId: validSourceId,
            maladieIds: state.selectedMaladies.map((m) => m.id).toList(),
          );
        } catch (_) {}
      }

      // Enregistrer localisation si saisie
      final reg = state.region.trim();
      if (reg.isNotEmpty) {
        try {
          await _api.enregistrerLocalisation(
            collecteId: id,
            region: reg,
            cercle: state.cercle.trim().isNotEmpty ? state.cercle.trim() : reg,
            commune:
                state.commune.trim().isNotEmpty ? state.commune.trim() : reg,
            localite:
                state.localite.trim().isNotEmpty ? state.localite.trim() : reg,
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
      final error = ErrorHandler.handle(e);
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    }
  }

  /// Synchronise toutes les étapes avec le serveur puis charge le récapitulatif officiel
  Future<void> fetchRecapitulatif() async {
    await saveDraft();
    if (state.collecteId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final recap = await _api.getRecapitulatif(state.collecteId!);
      state = state.copyWith(isLoading: false, recapitulatif: recap);
    } catch (e) {
      final error = ErrorHandler.handle(e);
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  /// Synchronise toutes les étapes et soumet définitivement la collecte au comité de validation
  Future<bool> soumettre() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final saved = await saveDraft();
      if (!saved || state.collecteId == null) {
        throw Exception('Impossible de sauvegarder le dossier de collecte');
      }
      await _api.soumettreCollecte(state.collecteId!);
      _ref.invalidate(agentCollectesListProvider);
      _ref.invalidate(agentDashboardFutureProvider);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final error = ErrorHandler.handle(e);
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    }
  }

  void reset() {
    state = const NouvelleCollecteDraftState();
  }

  void clearExistingPhoto() {
    state = state.copyWith(clearExistingPhotoUrl: true);
  }

  void clearExistingAudio() {
    state = state.copyWith(clearExistingAudioUrl: true);
  }

  void loadFromDetail(
    AgentCollecteDetailModel detail,
    AgentCollecteRecapitulatifModel? recap,
  ) {
    state = NouvelleCollecteDraftState(
      currentStep: 0,
      collecteId: detail.id,
      isDraftSaved: true,
      selectedPlante: (recap?.planteId != null && recap?.planteNomScientifique != null)
          ? AgentPlanteModel(
              id: recap!.planteId!,
              nomScientifique: recap.planteNomScientifique!,
              description: detail.description,
              photoUrl: detail.photoUrl,
              nomsVernaculaires: recap.nomsVernaculaires,
            )
          : null,
      selectedMaladies: (recap != null && recap.maladiesAssociees.isNotEmpty)
          ? recap.maladiesAssociees
              .asMap()
              .entries
              .map((e) => AgentMaladieModel(id: e.key + 1, nom: e.value))
              .toList()
          : const [],
      usageRapporte: recap != null && recap.usagesRapportes.isNotEmpty
          ? recap.usagesRapportes.first
          : (detail.description ?? ''),
      partieUtilisee: recap != null && recap.partiesUtilisees.isNotEmpty
          ? recap.partiesUtilisees.join(', ')
          : 'Feuilles',
      preparation: recap != null && recap.modesPreparation.isNotEmpty
          ? recap.modesPreparation.first
          : '',
      precaution: recap != null && recap.precautions.isNotEmpty
          ? recap.precautions.first
          : '',
      selectedSource: (detail.sourceId != null && detail.sourceNomComplet != null)
          ? AgentSourceModel(
              id: detail.sourceId!,
              nom: detail.sourceNomComplet!,
              nomComplet: detail.sourceNomComplet!,
              specialite: detail.sourceSpecialite,
              telephone: detail.sourceTelephone,
            )
          : null,
      region: detail.region ?? 'Sikasso',
      cercle: detail.cercle ?? '',
      commune: detail.commune ?? '',
      localite: detail.localite ?? '',
      latitude: detail.latitude,
      longitude: detail.longitude,
      existingPhotoUrl: detail.photoUrl,
      existingAudioUrl: detail.audioUrl,
      recapitulatif: recap,
    );
  }
}

final nouvelleCollecteWizardProvider =
    StateNotifierProvider<NouvelleCollecteWizardNotifier, NouvelleCollecteDraftState>((ref) {
  final api = ref.watch(agentApiServiceProvider);
  return NouvelleCollecteWizardNotifier(api, ref);
});


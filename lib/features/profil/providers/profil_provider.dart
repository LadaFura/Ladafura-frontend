import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../models/profil_model.dart';
import '../services/profil_service.dart';

enum ProfilStatus {
  initial,
  loading,
  success,
  error,
  updating,
}

class ProfilState {
  final ProfilStatus status;
  final ProfilModel? profil;
  final int unreadNotificationsCount;
  final String? errorMessage;
  final String? successMessage;

  const ProfilState({
    this.status = ProfilStatus.initial,
    this.profil,
    this.unreadNotificationsCount = 0,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading =>
      status == ProfilStatus.loading || status == ProfilStatus.initial;
  bool get isUpdating => status == ProfilStatus.updating;

  ProfilState copyWith({
    ProfilStatus? status,
    ProfilModel? profil,
    int? unreadNotificationsCount,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ProfilState(
      status: status ?? this.status,
      profil: profil ?? this.profil,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class ProfilNotifier extends StateNotifier<ProfilState> {
  final ProfilService _service;
  final Ref _ref;

  ProfilNotifier(this._service, this._ref) : super(const ProfilState()) {
    chargerProfil();
  }

  /// Charge le profil réel depuis le backend.
  Future<void> chargerProfil() async {
    state = state.copyWith(status: ProfilStatus.loading, clearMessages: true);

    try {
      final profil = await _service.fetchMonProfil();
      final unreadCount = await _service.fetchUnreadNotificationsCount();

      state = state.copyWith(
        status: ProfilStatus.success,
        profil: profil,
        unreadNotificationsCount: unreadCount,
      );
    } catch (e) {
      // Repli gracieux sur les données de l'utilisateur connecté en session
      final authUser = _ref.read(currentUserProvider);
      if (authUser != null) {
        final fallbackProfil = ProfilModel(
          id: authUser.id,
          nom: authUser.nom,
          prenom: authUser.prenom,
          email: authUser.email,
          telephone: authUser.telephone,
          role: authUser.role,
        );
        state = state.copyWith(
          status: ProfilStatus.success,
          profil: fallbackProfil,
        );
        return;
      }

      state = state.copyWith(
        status: ProfilStatus.error,
        errorMessage: "Impossible de charger votre profil : $e",
      );
    }
  }

  /// Actualise les informations du profil sans bloquer l'affichage.
  Future<void> actualiserProfil() async {
    try {
      final profil = await _service.fetchMonProfil();
      final unreadCount = await _service.fetchUnreadNotificationsCount();

      state = state.copyWith(
        status: ProfilStatus.success,
        profil: profil,
        unreadNotificationsCount: unreadCount,
        clearMessages: true,
      );
    } catch (_) {
      // Ignorer pour préserver les données en cache
    }
  }

  /// Met à jour les informations modifiables du profil (nom, prénom, téléphone).
  Future<bool> modifierProfil({
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    state = state.copyWith(
      status: ProfilStatus.updating,
      clearMessages: true,
    );

    try {
      final updated = await _service.updateProfil(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
      );

      state = state.copyWith(
        status: ProfilStatus.success,
        profil: updated,
        successMessage: "Profil mis à jour avec succès !",
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ProfilStatus.error,
        errorMessage: "Erreur lors de la mise à jour : $e",
      );
      return false;
    }
  }
}

/// Provider d'état du profil utilisateur.
final profilProvider =
    StateNotifierProvider<ProfilNotifier, ProfilState>((ref) {
  final service = ref.watch(profilServiceProvider);
  return ProfilNotifier(service, ref);
});

/// Alias rétrocompatible pour les widgets existants
final citoyenProfilProvider = Provider<ProfilModel?>((ref) {
  return ref.watch(profilProvider).profil;
});

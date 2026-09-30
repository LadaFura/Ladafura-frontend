import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import 'package:ladafura_frontend_flutter/core/routing/app_router.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';
import '../data/models/register_request_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/firebase_auth_service.dart';
import '../../../core/config/firebase_options.dart';

/// Statut de l'état d'authentification de l'utilisateur.
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// État immuable de la session utilisateur dans Riverpod.
class AuthState {
  final AuthStatus status;
  final UtilisateurModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null;

  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        errorMessage = message;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading =>
      status == AuthStatus.loading || status == AuthStatus.initial;
  UserRole? get role => user?.role;
}

/// Fournisseur du service Firebase Auth officiel.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(
    firebaseApiKey: DefaultFirebaseOptions.firebaseApiKey,
    mockMode: false,
  );
});

/// Fournisseur du dépôt d'authentification.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final firebaseAuth = ref.watch(firebaseAuthServiceProvider);
  final storageService = ref.watch(storageServiceProvider);

  return AuthRepository(
    apiClient: apiClient,
    firebaseAuthService: firebaseAuth,
    storageService: storageService,
  );
});

/// Gestionnaire d'état de l'authentification Riverpod (StateNotifier).
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier({
    required AuthRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(const AuthState.initial()) {
    checkAuthStatus();
  }

  /// Vérifie si une session active existe en local et auprès du backend.
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    _ref.read(authRoutingStateProvider).update(
          isAuthenticated: false,
          role: null,
          isInitializing: true,
        );

    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
        _ref.read(authRoutingStateProvider).update(
              isAuthenticated: true,
              role: user.role,
              isInitializing: false,
            );
      } else {
        state = const AuthState.unauthenticated();
        _ref.read(authRoutingStateProvider).update(
              isAuthenticated: false,
              role: null,
              isInitializing: false,
            );
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
      _ref.read(authRoutingStateProvider).update(
            isAuthenticated: false,
            role: null,
            isInitializing: false,
          );
    }
  }

  /// Connexion Email + Mot de passe (Firebase Auth + Synchronisation Spring Boot).
  Future<bool> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.login(
        email: email,
        password: password,
        role: role,
      );

      state = AuthState.authenticated(user);
      _ref.read(authRoutingStateProvider).update(
            isAuthenticated: true,
            role: user.role,
            isInitializing: false,
          );
      return true;
    } catch (e) {
      final cleanMsg = e.toString().replaceFirst('Exception: ', '');
      state = AuthState.error(cleanMsg);
      _ref.read(authRoutingStateProvider).update(
            isAuthenticated: false,
            role: null,
            isInitializing: false,
          );
      return false;
    }
  }

  /// Inscription d'un nouvel utilisateur.
  Future<bool> register(RegisterRequestModel request) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.register(request);
      state = AuthState.authenticated(user);
      _ref.read(authRoutingStateProvider).update(
            isAuthenticated: true,
            role: user.role,
            isInitializing: false,
          );
      return true;
    } catch (e) {
      final cleanMsg = e.toString().replaceFirst('Exception: ', '');
      state = AuthState.error(cleanMsg);
      _ref.read(authRoutingStateProvider).update(
            isAuthenticated: false,
            role: null,
            isInitializing: false,
          );
      return false;
    }
  }

  /// Déconnexion complète de l'utilisateur.
  Future<void> logout() async {
    state = const AuthState.loading();
    await _repository.logout();
    state = const AuthState.unauthenticated();
    _ref.read(authRoutingStateProvider).update(
          isAuthenticated: false,
          role: null,
          isInitializing: false,
        );
  }
}

/// Fournisseur Riverpod global de l'état d'authentification.
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository: repository, ref: ref);
});

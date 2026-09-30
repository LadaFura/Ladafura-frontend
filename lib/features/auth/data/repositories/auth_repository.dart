import 'package:dio/dio.dart';
import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';
import '../models/auth_me_model.dart';
import '../models/register_request_model.dart';
import '../services/firebase_auth_service.dart';

/// Dépôt central d'authentification orchestrant Firebase Auth et le backend Spring Boot.
class AuthRepository {
  final ApiClient _apiClient;
  final FirebaseAuthService _firebaseAuthService;
  final StorageService _storageService;

  AuthRepository({
    required ApiClient apiClient,
    required FirebaseAuthService firebaseAuthService,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _firebaseAuthService = firebaseAuthService,
        _storageService = storageService {
    // Configurer l'intercepteur Dio pour qu'il injecte toujours le Bearer token
    _apiClient.authInterceptor.setTokenProvider(() async => _storageService.getToken());
    final existingToken = _storageService.getToken();
    if (existingToken != null && existingToken.isNotEmpty) {
      _apiClient.setAuthToken(existingToken);
    }
  }

  /// Résout l'utilisateur et son rôle auprès de l'endpoint neutre /api/v1/auth/me.
  Future<UtilisateurModel?> resolveCurrentUser() async {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    _apiClient.setAuthToken(token);

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.authMe,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.isSuccess && response.data != null) {
      final authMe = AuthMeModel.fromJson(response.data!);
      return authMe.toUtilisateurModel();
    }
    return null;
  }

  /// Connexion par Email + Mot de passe (Firebase Auth + Synchronisation Spring Boot).
  Future<UtilisateurModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    // 1. Authentification auprès de Firebase Auth
    final firebaseResult =
        await _firebaseAuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Enregistrement temporaire du jeton pour que l'intercepteur Dio l'injecte
    await _storageService.saveToken(firebaseResult.idToken);
    _apiClient.setAuthToken(firebaseResult.idToken);

    // 3. Récupération neutre du profil utilisateur depuis Spring Boot
    UtilisateurModel? user;
    try {
      user = await resolveCurrentUser();
    } catch (_) {
      user = null;
    }

    // Si non trouvé (ex: premier citoyen connecté via Firebase), tentative de synchronisation
    if (user == null) {
      try {
        user = await _syncPopulationUser(email);
      } catch (e) {
        // En cas d'échec de synchronisation ou si rôle spécifié de secours
        if (role != null) {
          try {
            user = await _fetchUserProfileForRole(role);
          } catch (_) {
            await _storageService.clearSession();
            rethrow;
          }
        } else {
          await _storageService.clearSession();
          rethrow;
        }
      }
    }

    // 4. Sauvegarde définitive de la session active
    await _storageService.saveSession(
      token: firebaseResult.idToken,
      email: user.email,
      role: user.role.backendValue,
      userId: user.id.toString(),
    );

    return user;
  }

  /// Inscription autonome d'un citoyen (US-01 / EF01) et provisionnement Firebase.
  Future<UtilisateurModel> register(RegisterRequestModel request) async {
    // Appel à l'endpoint Spring Boot d'inscription
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.populationRegister,
      data: request.toBackendJson(),
    );

    if (response.isSuccess && response.data != null) {
      final user = UtilisateurModel.fromJson(response.data!);

      // Connexion automatique après inscription
      try {
        final firebaseResult =
            await _firebaseAuthService.signInWithEmailAndPassword(
          email: request.email,
          password: request.motDePasse,
        );

        await _storageService.saveSession(
          token: firebaseResult.idToken,
          email: user.email,
          role: user.role.backendValue,
          userId: user.id.toString(),
        );
      } catch (_) {
        await _storageService.saveEmail(user.email);
        await _storageService.saveRole(user.role.backendValue);
      }

      return user;
    } else {
      throw Exception(response.message ?? 'Échec de l\'inscription');
    }
  }

  /// Récupère l'utilisateur actuellement connecté depuis sa session locale et vérifie auprès du backend.
  Future<UtilisateurModel?> getCurrentUser() async {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      // 1. Essayer d'abord la résolution neutre /api/v1/auth/me
      final user = await resolveCurrentUser();
      if (user != null) {
        await _storageService.saveRole(user.role.backendValue);
        return user;
      }
    } catch (_) {
      // Erreur réseau ou token expiré
    }

    // 2. Si le rôle était déjà mémorisé, tentative avec l'endpoint dédié
    final roleStr = _storageService.getRole();
    if (roleStr != null) {
      final role = UserRole.fromString(roleStr) ?? UserRole.population;
      try {
        final user = await _fetchUserProfileForRole(role);
        return user;
      } catch (_) {
        // Session expirée ou invalide
        await _storageService.clearSession();
        return null;
      }
    }

    await _storageService.clearSession();
    return null;
  }

  /// Déconnexion de l'utilisateur.
  Future<void> logout() async {
    await _storageService.clearSession();
    _apiClient.clearAuthToken();
  }

  /// Récupère les informations de profil selon le rôle auprès du backend Spring Boot.
  Future<UtilisateurModel> _fetchUserProfileForRole(UserRole role) async {
    final String endpoint;
    switch (role) {
      case UserRole.population:
        endpoint = ApiEndpoints.populationMe;
        break;
      case UserRole.agentCollecte:
        endpoint = ApiEndpoints.agentMe;
        break;
    }

    final token = _storageService.getToken();
    final response = await _apiClient.get<Map<String, dynamic>>(
      endpoint,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    if (response.isSuccess && response.data != null) {
      return UtilisateurModel.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Impossible de récupérer le profil.');
    }
  }

  /// Synchronise un compte Firebase direct avec MySQL pour la population.
  Future<UtilisateurModel> _syncPopulationUser(String email) async {
    final token = _storageService.getToken();
    if (token != null) {
      _apiClient.setAuthToken(token);
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.populationSync,
      data: {'email': email},
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    if (response.isSuccess && response.data != null) {
      return UtilisateurModel.fromJson(response.data!);
    } else {
      throw Exception(
          response.message ?? 'Impossible de synchroniser le compte.');
    }
  }
}

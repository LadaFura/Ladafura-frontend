import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';
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
        _storageService = storageService;

  /// Connexion par Email + Mot de passe (Firebase Auth + Synchronisation Spring Boot).
  Future<UtilisateurModel> login({
    required String email,
    required String password,
    UserRole role = UserRole.population,
  }) async {
    // 1. Authentification auprès de Firebase Auth
    final firebaseResult =
        await _firebaseAuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Enregistrement temporaire du jeton pour que l'intercepteur Dio l'injecte
    await _storageService.saveToken(firebaseResult.idToken);

    // 3. Récupération ou synchronisation du profil utilisateur depuis Spring Boot
    UtilisateurModel user;
    try {
      user = await _fetchUserProfileForRole(role);
    } catch (e) {
      // Si l'utilisateur est un citoyen nouvellement connecté via Firebase, tentative de synchronisation
      if (role == UserRole.population) {
        user = await _syncPopulationUser(email);
      } else {
        await _storageService.clearSession();
        rethrow;
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
    final roleStr = _storageService.getRole();

    if (token == null || token.isEmpty || roleStr == null) {
      return null;
    }

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

  /// Déconnexion de l'utilisateur.
  Future<void> logout() async {
    await _storageService.clearSession();
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

    final response = await _apiClient.get<Map<String, dynamic>>(endpoint);

    if (response.isSuccess && response.data != null) {
      return UtilisateurModel.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Impossible de récupérer le profil.');
    }
  }

  /// Synchronise un compte Firebase direct avec MySQL pour la population.
  Future<UtilisateurModel> _syncPopulationUser(String email) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.populationSync,
      data: {'email': email},
    );

    if (response.isSuccess && response.data != null) {
      return UtilisateurModel.fromJson(response.data!);
    } else {
      throw Exception(
          response.message ?? 'Impossible de synchroniser le compte.');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';
import '../models/auth_me_model.dart';
import '../models/register_request_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/google_auth_service.dart';

/// Dépôt central d'authentification orchestrant Firebase Auth, Google Sign-In et le backend Spring Boot.
class AuthRepository {
  final ApiClient _apiClient;
  final FirebaseAuthService _firebaseAuthService;
  final GoogleAuthService _googleAuthService;
  final StorageService _storageService;

  AuthRepository({
    required ApiClient apiClient,
    required FirebaseAuthService firebaseAuthService,
    GoogleAuthService? googleAuthService,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _firebaseAuthService = firebaseAuthService,
        _googleAuthService = googleAuthService ?? GoogleAuthService(),
        _storageService = storageService {
    // Configurer l'intercepteur Dio pour qu'il injecte toujours le Bearer token
    _apiClient.authInterceptor
        .setTokenProvider(() async => _storageService.getToken());
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

  StorageService get storageService => _storageService;

  /// Restitue le profil utilisateur mis en cache local sans appel réseau (démarrage instantané).
  UtilisateurModel? getCachedUser() {
    final token = _storageService.getToken();
    final roleStr = _storageService.getRole();
    if (token == null || token.isEmpty || roleStr == null) {
      return null;
    }

    final role = UserRole.fromString(roleStr) ?? UserRole.population;
    final email = _storageService.getUserEmail() ?? '';
    final name = _storageService.getUserName() ??
        (role == UserRole.agentCollecte ? 'Agent Terrain' : 'Citoyen');
    final userId = int.tryParse(_storageService.getUserId() ?? '0') ?? 0;

    return UtilisateurModel(
      id: userId,
      email: email,
      nom: name,
      prenom: '',
      role: role,
      matricule: role == UserRole.agentCollecte
          ? (_storageService.getUserId() ?? 'AGT-MALI-001')
          : null,
      statut: 'ACTIF',
    );
  }

  /// Récupère l'utilisateur actuellement connecté depuis sa session locale et vérifie auprès du backend.
  Future<UtilisateurModel?> getCurrentUser() async {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final cachedUser = getCachedUser();

    try {
      // 1. Essayer d'abord la résolution neutre /api/v1/auth/me
      final user = await resolveCurrentUser();
      if (user != null) {
        await _storageService.saveRole(user.role.backendValue);
        await _storageService.saveEmail(user.email);
        return user;
      }
    } on DioException catch (e) {
      // Si le serveur répond explicitement 401 Unauthorized (token révoqué ou invalide)
      if (e.response?.statusCode == 401) {
        await _storageService.clearSession();
        _apiClient.clearAuthToken();
        return null;
      }
      if (cachedUser != null) return cachedUser;
    } catch (_) {
      if (cachedUser != null) return cachedUser;
    }

    // 2. Si le rôle était déjà mémorisé, tentative avec l'endpoint dédié
    final roleStr = _storageService.getRole();
    if (roleStr != null) {
      final role = UserRole.fromString(roleStr) ?? UserRole.population;
      try {
        final user = await _fetchUserProfileForRole(role);
        return user;
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _storageService.clearSession();
          _apiClient.clearAuthToken();
          return null;
        }
        if (cachedUser != null) return cachedUser;
      } catch (_) {
        if (cachedUser != null) return cachedUser;
      }
    }

    return cachedUser;
  }

  /// Connexion ou Inscription avec un compte Google (Google Sign-In).
  ///
  /// Orchestre :
  /// 1. La sélection interactive de compte Google
  /// 2. L'échange du jeton avec Firebase Identity Toolkit
  /// 3. La synchronisation et récupération du profil auprès de Spring Boot
  /// 4. La mémorisation de session locale
  Future<UtilisateurModel?> signInWithGoogle({UserRole? role}) async {
    // 1. Authentification Google native
    final googleCreds = await _googleAuthService.signIn();
    if (googleCreds == null) {
      // Annulé par l'utilisateur
      return null;
    }

    // 2. Échange avec Firebase Auth
    final firebaseResult = await _firebaseAuthService.signInWithGoogleIdToken(
      idToken: googleCreds.idToken,
      accessToken: googleCreds.accessToken,
    );

    // 3. Enregistrement temporaire du jeton
    await _storageService.saveToken(firebaseResult.idToken);
    _apiClient.setAuthToken(firebaseResult.idToken);

    // 4. Résolution du profil auprès du backend Spring Boot
    UtilisateurModel? user;
    try {
      user = await resolveCurrentUser();
    } catch (_) {
      user = null;
    }

    // Si l'utilisateur n'existe pas encore en base, création/synchronisation citoyen
    if (user == null) {
      try {
        user = await _syncPopulationUser(firebaseResult.email);
      } catch (_) {
        final effectiveRole = role ?? UserRole.population;
        try {
          user = await _fetchUserProfileForRole(effectiveRole);
        } catch (_) {
          user = UtilisateurModel(
            id: 0,
            firebaseUid: firebaseResult.uid,
            email: firebaseResult.email,
            nom: googleCreds.displayName ?? 'Citoyen',
            prenom: '',
            role: UserRole.population,
            statut: 'ACTIF',
          );
        }
      }
    }

    // 5. Sauvegarde définitive de la session active
    await _storageService.saveSession(
      token: firebaseResult.idToken,
      email: user.email,
      role: user.role.backendValue,
      userId: user.id.toString(),
    );

    return user;
  }

  /// Déconnexion de l'utilisateur (Firebase, Google et Spring Boot).
  Future<void> logout() async {
    await _storageService.clearSession();
    _apiClient.clearAuthToken();
    await _googleAuthService.signOut();
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

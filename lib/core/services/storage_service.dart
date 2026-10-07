import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/enums/user_role.dart';

/// Service de stockage local persistant pour LADAFURA.
///
/// Gère de manière centralisée :
/// - Les jetons d'authentification (Token JWT Firebase, Refresh Token).
/// - Le profil et rôle de l'utilisateur actif ([UserRole]).
/// - Les préférences de l'application (thème, langue, indicateur d'onboarding).
class StorageService {
  static const String _keyAuthToken = 'ladafura_jwt_token';
  static const String _keyRefreshToken = 'ladafura_refresh_token';
  static const String _keyUserId = 'ladafura_user_id';
  static const String _keyUserEmail = 'ladafura_user_email';
  static const String _keyFirebaseUid = 'ladafura_firebase_uid';
  static const String _keyUserRole = 'ladafura_user_role';
  static const String _keyUserPhone = 'ladafura_user_phone';
  static const String _keyUserName = 'ladafura_user_name';
  static const String _keyOnboardingDone = 'ladafura_onboarding_completed';
  static const String _keyThemeMode = 'ladafura_theme_mode';
  static const String _keyRecentSearches = 'ladafura_recent_searches';

  static const List<String> defaultRecentSearches = [
    'Moringa',
    'Pharmacopée dagaba',
    'Diabète',
    'Kinkeliba',
    'Bissap',
  ];

  final SharedPreferences _prefs;
  static StorageService? _instance;

  StorageService(this._prefs) {
    _instance = this;
  }

  static StorageService init(SharedPreferences prefs) {
    final service = StorageService(prefs);
    _instance = service;
    return service;
  }

  static StorageService get instance {
    if (_instance == null) {
      throw StateError('StorageService non initialisé.');
    }
    return _instance!;
  }

  static void setMockInstance(StorageService service) {
    _instance = service;
  }

  /// Usine asynchrone pour initialiser le service avec l'instance SharedPreferences du système.
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    _instance = service;
    return service;
  }

  // ===========================================================================
  // 1. GESTION DU JETON & DE LA SESSION AUTH
  // ===========================================================================

  /// Enregistre le jeton Bearer JWT Firebase.
  Future<bool> saveAuthToken(String token) {
    return _prefs.setString(_keyAuthToken, token);
  }

  /// Récupère le jeton JWT actif.
  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }

  /// Enregistre le jeton de rafraîchissement.
  Future<bool> saveRefreshToken(String token) {
    return _prefs.setString(_keyRefreshToken, token);
  }

  /// Récupère le jeton de rafraîchissement.
  String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }

  /// Vérifie si un jeton d'authentification est actuellement enregistré.
  bool hasAuthToken() {
    final token = getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Enregistre le rôle de l'utilisateur.
  Future<bool> saveUserRole(UserRole role) {
    return _prefs.setString(_keyUserRole, role.value);
  }

  /// Récupère le rôle de l'utilisateur actif.
  UserRole? getUserRole() {
    final roleStr = _prefs.getString(_keyUserRole);
    return UserRole.fromString(roleStr);
  }

  /// Enregistre les métadonnées de base de l'utilisateur connecté.
  Future<void> saveUserSession({
    required String token,
    required UserRole role,
    String? refreshToken,
    String? userId,
    String? email,
    String? firebaseUid,
    String? phone,
    String? name,
  }) async {
    await saveAuthToken(token);
    await saveUserRole(role);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    if (userId != null) {
      await _prefs.setString(_keyUserId, userId);
    }
    if (email != null) {
      await _prefs.setString(_keyUserEmail, email);
    }
    if (firebaseUid != null) {
      await _prefs.setString(_keyFirebaseUid, firebaseUid);
    }
    if (phone != null) {
      await _prefs.setString(_keyUserPhone, phone);
    }
    if (name != null) {
      await _prefs.setString(_keyUserName, name);
    }
  }

  /// Identifiant unique de l'utilisateur en base Spring Boot.
  String? getUserId() => _prefs.getString(_keyUserId);

  /// Adresse email de l'utilisateur (utilisée pour l'authentification Firebase).
  String? getUserEmail() => _prefs.getString(_keyUserEmail);

  /// Identifiant unique Firebase Authentication (UID).
  String? getFirebaseUid() => _prefs.getString(_keyFirebaseUid);

  /// Numéro de téléphone de l'utilisateur (+223...).
  String? getUserPhone() => _prefs.getString(_keyUserPhone);

  /// Nom ou pseudonyme de l'utilisateur.
  String? getUserName() => _prefs.getString(_keyUserName);

  /// Supprime tous les jetons et données de session lors de la déconnexion.
  Future<void> clearAuth() async {
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyFirebaseUid);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserPhone);
    await _prefs.remove(_keyUserName);
  }

  // --- Méthodes de commodité & Aliases ---
  Future<bool> saveToken(String token) => saveAuthToken(token);
  String? getToken() => getAuthToken();
  Future<bool> saveRole(String roleStr) =>
      saveUserRole(UserRole.fromString(roleStr) ?? UserRole.population);
  String? getRole() => getUserRole()?.value;
  Future<bool> saveEmail(String email) =>
      _prefs.setString(_keyUserEmail, email);
  Future<void> saveSession({
    required String token,
    required String email,
    required String role,
    String? userId,
  }) =>
      saveUserSession(
        token: token,
        role: UserRole.fromString(role) ?? UserRole.population,
        email: email,
        userId: userId,
      );
  Future<void> clearSession() => clearAuth();
  bool hasCompletedOnboarding() => isOnboardingCompleted();

  // ===========================================================================
  // 2. PRÉFÉRENCES APPLICATIVES & INTERFACE
  // ===========================================================================

  /// Indique si l'utilisateur a déjà complété les écrans d'onboarding.
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingDone) ?? false;
  }

  /// Marque l'onboarding comme complété.
  Future<bool> setOnboardingCompleted(bool completed) {
    return _prefs.setBool(_keyOnboardingDone, completed);
  }

  /// Enregistre le mode de thème sous forme de chaîne ('light', 'dark', 'system').
  Future<bool> setThemeMode(String themeMode) {
    return _prefs.setString(_keyThemeMode, themeMode);
  }

  /// Récupère la valeur brute du thème ('light', 'dark', 'system') ou null si non défini.
  String? getThemeMode() {
    return _prefs.getString(_keyThemeMode);
  }

  /// Enregistre le [ThemeMode] Flutter dans le stockage persistant.
  Future<bool> saveThemeMode(ThemeMode mode) {
    return _prefs.setString(_keyThemeMode, mode.name);
  }

  /// Récupère le [ThemeMode] actif, avec prise en compte par défaut du thème système ([ThemeMode.system]).
  ThemeMode getAppThemeMode() {
    final raw = getThemeMode();
    if (raw == null || raw.isEmpty) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (m) => m.name.toLowerCase() == raw.toLowerCase(),
      orElse: () => ThemeMode.system,
    );
  }

  // ===========================================================================
  // 3. HISTORIQUE DES RECHERCHES RÉCENTES
  // ===========================================================================

  /// Récupère la liste des termes recherchés récemment.
  List<String> getRecentSearches() {
    return _prefs.getStringList(_keyRecentSearches) ?? defaultRecentSearches;
  }

  /// Sauvegarde la liste complète des recherches récentes.
  Future<bool> saveRecentSearches(List<String> searches) {
    return _prefs.setStringList(_keyRecentSearches, searches);
  }

  /// Ajoute un terme en tête de l'historique sans doublon (max 10 éléments).
  Future<bool> addRecentSearch(String term) {
    final clean = term.trim();
    if (clean.isEmpty) return Future.value(false);
    final list = List<String>.from(getRecentSearches());
    list.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
    list.insert(0, clean);
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    return saveRecentSearches(list);
  }

  /// Supprime un terme de l'historique de recherche.
  Future<bool> removeRecentSearch(String term) {
    final list = List<String>.from(getRecentSearches());
    list.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    return saveRecentSearches(list);
  }

  // ===========================================================================
  // 4. PHARMACOPÉE DU PANIER
  // ===========================================================================

  static const String _keyCartPharmacopeeId = 'ladafura_cart_pharmacopee_id';
  static const String _keyCartPharmacopeeNom = 'ladafura_cart_pharmacopee_nom';

  /// Enregistre la pharmacopée liée au panier actif.
  Future<void> saveCartPharmacopee(int id, String nom) async {
    await _prefs.setInt(_keyCartPharmacopeeId, id);
    await _prefs.setString(_keyCartPharmacopeeNom, nom);
  }

  /// Récupère l'ID de la pharmacopée associée au panier.
  int? getCartPharmacopeeId() => _prefs.getInt(_keyCartPharmacopeeId);

  /// Récupère le nom de la pharmacopée associée au panier.
  String? getCartPharmacopeeNom() => _prefs.getString(_keyCartPharmacopeeNom);

  /// Supprime la pharmacopée associée au panier.
  Future<void> clearCartPharmacopee() async {
    await _prefs.remove(_keyCartPharmacopeeId);
    await _prefs.remove(_keyCartPharmacopeeNom);
  }

  // ===========================================================================
  // 5. UTILITAIRES GÉNÉRIQUES
  // ===========================================================================

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  /// Vide l'intégralité du stockage local.
  Future<bool> clearAll() => _prefs.clear();
}

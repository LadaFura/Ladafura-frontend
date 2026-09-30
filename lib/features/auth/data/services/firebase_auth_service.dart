import 'package:dio/dio.dart';

/// Résultat d'une authentification réussie auprès de Firebase Auth.
class FirebaseAuthResult {
  final String idToken;
  final String refreshToken;
  final String email;
  final String uid;
  final int expiresIn;

  const FirebaseAuthResult({
    required this.idToken,
    required this.refreshToken,
    required this.email,
    required this.uid,
    required this.expiresIn,
  });

  factory FirebaseAuthResult.fromJson(Map<String, dynamic> json) {
    return FirebaseAuthResult(
      idToken: json['idToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      uid: json['localId']?.toString() ?? '',
      expiresIn: int.tryParse(json['expiresIn']?.toString() ?? '3600') ?? 3600,
    );
  }
}

/// Service client gérant l'authentification Firebase (Email + Mot de passe).
///
/// Fonctionne via :
/// 1. L'API REST officielle Google Identity Toolkit Firebase Auth
/// 2. Ou un mode de développement / mock pour les tests hors ligne et tests unitaires.
class FirebaseAuthService {
  final Dio _dio;
  final String? _firebaseApiKey;
  bool _mockMode = false;

  FirebaseAuthService({
    Dio? dio,
    String? firebaseApiKey,
    bool mockMode = false,
  })  : _dio = dio ?? Dio(),
        _firebaseApiKey = firebaseApiKey,
        _mockMode = mockMode;

  /// Active ou désactive le mode mock (utile pour les environnements de test / démo).
  void setMockMode(bool enabled) {
    _mockMode = enabled;
  }

  bool get isMockMode => _mockMode;

  /// Connexion avec Email et Mot de passe auprès de Firebase Auth.
  Future<FirebaseAuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_mockMode || _firebaseApiKey == null || _firebaseApiKey.isEmpty) {
      // Simulation locale pour développement et tests unitaires
      return FirebaseAuthResult(
        idToken: 'mock-firebase-id-token-$cleanEmail',
        refreshToken: 'mock-firebase-refresh-token',
        email: cleanEmail,
        uid: 'uid-${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
        expiresIn: 3600,
      );
    }

    try {
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseApiKey',
        data: {
          'email': cleanEmail,
          'password': password,
          'returnSecureToken': true,
        },
      );

      return FirebaseAuthResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMsg = _extractFirebaseErrorMessage(e);
      throw Exception(errorMsg);
    }
  }

  /// Inscription avec Email et Mot de passe auprès de Firebase Auth.
  Future<FirebaseAuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_mockMode || _firebaseApiKey == null || _firebaseApiKey.isEmpty) {
      return FirebaseAuthResult(
        idToken: 'mock-firebase-id-token-$cleanEmail',
        refreshToken: 'mock-firebase-refresh-token',
        email: cleanEmail,
        uid: 'uid-${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
        expiresIn: 3600,
      );
    }

    try {
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseApiKey',
        data: {
          'email': cleanEmail,
          'password': password,
          'returnSecureToken': true,
        },
      );

      return FirebaseAuthResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMsg = _extractFirebaseErrorMessage(e);
      throw Exception(errorMsg);
    }
  }

  /// Authentification via jeton Google Identity (Google Sign-In).
  ///
  /// Échange le jeton Google auprès de l'API Identity Toolkit Firebase
  /// pour obtenir un jeton JWT Firebase complet reconnu par le backend Spring Boot.
  Future<FirebaseAuthResult> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
  }) async {
    if (_mockMode || _firebaseApiKey == null || _firebaseApiKey.isEmpty) {
      return const FirebaseAuthResult(
        idToken: 'mock-firebase-id-token-google.jwt.mock',
        refreshToken: 'mock-firebase-refresh-token',
        email: 'citoyen.google@ladafura.ml',
        uid: 'uid-google-mock-12345',
        expiresIn: 3600,
      );
    }

    try {
      final postBody = accessToken != null && accessToken.isNotEmpty
          ? 'access_token=$accessToken&id_token=$idToken&providerId=google.com'
          : 'id_token=$idToken&providerId=google.com';

      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=$_firebaseApiKey',
        data: {
          'postBody': postBody,
          'requestUri': 'http://localhost',
          'returnIdpCredential': true,
          'returnSecureToken': true,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return FirebaseAuthResult(
        idToken: data['idToken']?.toString() ?? '',
        refreshToken: data['refreshToken']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        uid: data['localId']?.toString() ?? '',
        expiresIn: int.tryParse(data['expiresIn']?.toString() ?? '3600') ?? 3600,
      );
    } on DioException catch (e) {
      final errorMsg = _extractFirebaseErrorMessage(e);
      throw Exception(errorMsg);
    }
  }

  /// Décodage des messages d'erreurs standard Firebase vers des messages en français.
  String _extractFirebaseErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      final error = data['error'];
      if (error is Map && error['message'] != null) {
        final code = error['message'].toString();
        if (code.contains('EMAIL_NOT_FOUND') ||
            code.contains('INVALID_PASSWORD') ||
            code.contains('INVALID_LOGIN_CREDENTIALS')) {
          return 'Adresse email ou mot de passe incorrect.';
        }
        if (code.contains('EMAIL_EXISTS')) {
          return 'Un compte existe déjà avec cette adresse email.';
        }
        if (code.contains('USER_DISABLED')) {
          return 'Ce compte utilisateur a été désactivé.';
        }
        if (code.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
          return 'Trop de tentatives échouées. Veuillez réessayer plus tard.';
        }
        if (code.contains('WEAK_PASSWORD')) {
          return 'Le mot de passe doit comporter au moins 6 caractères.';
        }
        return 'Erreur Firebase : $code';
      }
    }
    return 'Impossible de joindre le service d\'authentification Firebase.';
  }
}

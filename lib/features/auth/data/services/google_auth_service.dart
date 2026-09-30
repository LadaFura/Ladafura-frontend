import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Données renvoyées suite à une authentification réussie avec le SDK Google.
class GoogleAuthCredentials {
  final String idToken;
  final String? accessToken;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const GoogleAuthCredentials({
    required this.idToken,
    this.accessToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

/// Service client encapsulant l'authentification Google Sign-In.
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  bool _mockMode;
  GoogleAuthCredentials? _mockCredentials;
  bool _isInitialized = false;

  GoogleAuthService({
    GoogleSignIn? googleSignIn,
    bool mockMode = false,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _mockMode = mockMode;

  /// Configure des identifiants simulés pour les tests unitaires et widgets
  void setMockCredentials(GoogleAuthCredentials? credentials) {
    _mockCredentials = credentials;
    _mockMode = true;
  }

  void setMockMode(bool enabled) {
    _mockMode = enabled;
  }

  bool get isMockMode => _mockMode;

  Future<void> _ensureInitialized() async {
    if (_isInitialized || _mockMode) return;
    try {
      await _googleSignIn.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Avertissement initialisation GoogleSignIn : $e');
    }
  }

  /// Lance le flux d'authentification Google interactif.
  ///
  /// Retourne [GoogleAuthCredentials] si l'utilisateur a sélectionné un compte,
  /// ou `null` si l'utilisateur a annulé la fenêtre de dialogue.
  Future<GoogleAuthCredentials?> signIn() async {
    if (_mockMode) {
      return _mockCredentials ??
          const GoogleAuthCredentials(
            idToken: 'mock-google-id-token-abc.xyz.123',
            email: 'citoyen.test@gmail.com',
            displayName: 'Fatoumata Traoré',
          );
    }

    try {
      await _ensureInitialized();
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Impossible de récupérer le jeton d\'identité Google (idToken manquant).');
      }

      return GoogleAuthCredentials(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // L'utilisateur a annulé la connexion
        return null;
      }
      debugPrint('Erreur Google Sign-In : $e');
      rethrow;
    } catch (e) {
      debugPrint('Erreur Google Sign-In générique : $e');
      rethrow;
    }
  }

  /// Déconnecte la session active Google locale.
  Future<void> signOut() async {
    if (_mockMode) return;
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      if (e is! UnimplementedError) {
        debugPrint('Erreur déconnexion Google : $e');
      }
    }
  }
}

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

  final String? _serverClientId;
  final String? _clientId;

  GoogleAuthService({
    GoogleSignIn? googleSignIn,
    String? serverClientId,
    String? clientId,
    bool mockMode = false,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _serverClientId = serverClientId,
        _clientId = clientId,
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
      // Sur Android, l'application est identifiée par son package_name et son SHA-1 ;
      // seul serverClientId (Web Client ID) doit être fourni.
      final effectiveClientId =
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              ? null
              : _clientId;

      await _googleSignIn.initialize(
        serverClientId: _serverClientId,
        clientId: effectiveClientId,
      );
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
      GoogleSignInAccount? account;

      try {
        account = await _googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled ||
            e.code == GoogleSignInExceptionCode.interrupted) {
          return null;
        }
        // Fallback sur le flux One-Tap / CredentialManager léger sur certains appareils Android
        debugPrint(
            'Fallback attemptLightweightAuthentication suite à ${e.code}: ${e.description}');
        account = await _googleSignIn.attemptLightweightAuthentication(
          reportAllExceptions: true,
        );
      }

      if (account == null) {
        return null;
      }

      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
            'Impossible de récupérer le jeton d\'identité Google (idToken manquant).');
      }

      return GoogleAuthCredentials(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        // L'utilisateur a annulé la connexion
        return null;
      }
      debugPrint('Erreur Google Sign-In (${e.code}) : ${e.description}');
      final desc = e.description ?? '';
      if (desc.contains('No credential available') ||
          desc.contains('noCredential')) {
        throw Exception(
            'Aucun compte Google n\'est configuré sur cet appareil Android. Veuillez ajouter un compte Google dans les Paramètres du téléphone.');
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw Exception(
            'Erreur de configuration Google Sign-In (${e.code.name}). Vérifiez les services Google Play sur l\'appareil.');
      }
      throw Exception(
          'Impossible de se connecter avec Google : ${e.description ?? e.code.name}');
    } catch (e) {
      debugPrint('Erreur Google Sign-In générique : $e');
      rethrow;
    }
  }

  /// Déconnecte la session active Google locale sans bloquer.
  Future<void> signOut() async {
    if (_mockMode) return;
    try {
      await _googleSignIn.signOut().timeout(
            const Duration(milliseconds: 1200),
            onTimeout: () => null,
          );
    } catch (e) {
      debugPrint('Avertissement déconnexion Google : $e');
    }
  }
}

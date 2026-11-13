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

  static const String _messageIndisponible =
      'La connexion avec Google n\'est pas disponible sur cette version de l\'application. Connectez-vous avec votre adresse e-mail et votre mot de passe.';
  static const String _messageEchec =
      'La connexion avec Google a échoué. Réessayez, ou connectez-vous avec votre adresse e-mail et votre mot de passe.';
  static const String _messageAucunCompte =
      'Aucun compte Google n\'est configuré sur cet appareil. Ajoutez un compte Google dans les paramètres du téléphone, puis réessayez.';

  /// Lance le flux d'authentification Google interactif.
  ///
  /// Retourne [GoogleAuthCredentials] si l'utilisateur a sélectionné un compte,
  /// ou `null` si l'utilisateur a annulé la fenêtre de dialogue.
  /// Toute erreur remonte sous forme d'[Exception] au message français affichable
  /// tel quel ; le détail technique part dans les logs.
  Future<GoogleAuthCredentials?> signIn() async {
    if (_mockMode) {
      return _mockCredentials ??
          const GoogleAuthCredentials(
            idToken: 'mock-google-id-token-abc.xyz.123',
            email: 'citoyen.test@gmail.com',
            displayName: 'Fatoumata Traoré',
          );
    }

    await _ensureInitialized();
    // Sur le web, le SDK Google n'autorise pas l'ouverture du sélecteur de compte par le code.
    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception(_messageIndisponible);
    }

    final GoogleSignInAccount? account;
    final String? idToken;
    try {
      account = await _authentifier();
      idToken = account?.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (_estAnnulation(e)) {
        return null;
      }
      debugPrint('Erreur Google Sign-In (${e.code}) : ${e.description}');
      throw Exception(_messagePour(e));
    } catch (e) {
      debugPrint('Erreur Google Sign-In générique : $e');
      throw Exception(_messageEchec);
    }

    if (account == null) {
      return null;
    }
    if (idToken == null || idToken.isEmpty) {
      debugPrint('Google Sign-In : idToken manquant.');
      throw Exception(_messageEchec);
    }

    return GoogleAuthCredentials(
      idToken: idToken,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }

  Future<GoogleSignInAccount?> _authentifier() async {
    try {
      return await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (_estAnnulation(e)) {
        rethrow;
      }
      // Fallback sur le flux One-Tap / CredentialManager léger sur certains appareils Android
      debugPrint(
          'Fallback attemptLightweightAuthentication suite à ${e.code}: ${e.description}');
      return _googleSignIn.attemptLightweightAuthentication(
        reportAllExceptions: true,
      );
    }
  }

  bool _estAnnulation(GoogleSignInException e) =>
      e.code == GoogleSignInExceptionCode.canceled ||
      e.code == GoogleSignInExceptionCode.interrupted;

  String _messagePour(GoogleSignInException e) {
    final description = e.description ?? '';
    if (description.contains('No credential available') ||
        description.contains('noCredential')) {
      return _messageAucunCompte;
    }
    if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
        e.code == GoogleSignInExceptionCode.providerConfigurationError) {
      return _messageIndisponible;
    }
    return _messageEchec;
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

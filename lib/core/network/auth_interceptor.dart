import 'package:dio/dio.dart';

/// Type de fonction asynchrone pour récupérer dynamiquement le jeton Firebase JWT.
typedef TokenProvider = Future<String?> Function();

/// Type de callback déclenché lorsqu'une erreur 401 (Jeton expiré ou invalide) survient.
typedef OnTokenExpiredCallback = void Function();

/// Intercepteur Dio chargé de l'injection automatique du jeton Bearer Firebase JWT
/// et de la gestion de l'expiration de session (401 Unauthorized).
class AuthInterceptor extends Interceptor {
  String? _cachedToken;
  TokenProvider? _tokenProvider;
  OnTokenExpiredCallback? _onTokenExpired;

  AuthInterceptor({
    String? initialToken,
    TokenProvider? tokenProvider,
    OnTokenExpiredCallback? onTokenExpired,
  })  : _cachedToken = initialToken,
        _tokenProvider = tokenProvider,
        _onTokenExpired = onTokenExpired;

  /// Met à jour manuellement le token en cache mémoire.
  void setToken(String? token) {
    _cachedToken = token;
  }

  /// Réinitialise le token en mémoire lors d'une déconnexion.
  void clearToken() {
    _cachedToken = null;
  }

  /// Définit le fournisseur dynamique de token (ex: Firebase Auth ou StorageService).
  void setTokenProvider(TokenProvider? provider) {
    _tokenProvider = provider;
  }

  /// Définit le callback d'expiration de session (401).
  void setOnTokenExpired(OnTokenExpiredCallback? callback) {
    _onTokenExpired = callback;
  }

  /// Récupère le token actif (soit depuis le provider, soit depuis le cache).
  Future<String?> getActiveToken() async {
    if (_tokenProvider != null) {
      final freshToken = await _tokenProvider!();
      if (freshToken != null && freshToken.isNotEmpty) {
        _cachedToken = freshToken;
        return freshToken;
      }
    }
    return _cachedToken;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. En-têtes standard HTTP pour Spring Boot
    options.headers['Accept'] = 'application/json';
    options.headers['Accept-Language'] = 'fr-FR';

    // Ne pas écraser Content-Type s'il s'agit d'un FormData (upload multimédia US-15)
    if (options.data is! FormData) {
      options.headers['Content-Type'] ??= 'application/json';
    }

    // 2. Récupération et injection du Bearer Token Firebase JWT si disponible
    final token = await getActiveToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Détection de l'invalidation ou de l'expiration du jeton (401)
    if (err.response?.statusCode == 401) {
      _cachedToken = null;
      _onTokenExpired?.call();
    }
    return handler.next(err);
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import 'api_response.dart';
import 'auth_interceptor.dart';
import 'error_handler.dart';

/// Client HTTP Singleton Dio configuré pour l'écosystème LADAFURA.
///
/// Caractéristiques techniques :
/// - Timeouts stricts de 15s (adaptés aux conditions réseaux 3G/4G du Mali).
/// - Injection automatique du jeton Bearer Firebase JWT via [AuthInterceptor].
/// - Encodage et décodage harmonisés avec les contrôleurs Spring Boot.
/// - Support natif de l'upload multimédia terrain (US-15 : Photos géotaguées & Récits audio).
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  static ApiClient get instance => _instance;

  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  ApiClient._internal() {
    final baseOptions = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': 'fr-FR',
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    );

    _dio = Dio(baseOptions);
    _authInterceptor = AuthInterceptor();
    _dio.interceptors.add(_authInterceptor);

    // Bascule automatique vers localhost / 10.0.2.2 si l'IP Wi-Fi locale a changé
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final isConnectionFailure =
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError;
          final alreadyRetried =
              error.requestOptions.extra['_hostFallbackRetried'] == true;

          if (isConnectionFailure && !alreadyRetried && !kIsWeb) {
            String? fallbackHost;
            if (defaultTargetPlatform == TargetPlatform.android) {
              fallbackHost = _dio.options.baseUrl.contains('10.0.2.2')
                  ? 'http://${ApiEndpoints.devMachineIp}:8080'
                  : ApiEndpoints.androidEmulatorHost;
            } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS) {
              fallbackHost = _dio.options.baseUrl.contains(ApiEndpoints.devMachineIp)
                  ? ApiEndpoints.defaultHost
                  : 'http://${ApiEndpoints.devMachineIp}:8080';
            }

            if (fallbackHost != null) {
              final fallbackBaseUrl = '$fallbackHost${ApiEndpoints.apiVersion}';

              if (_dio.options.baseUrl != fallbackBaseUrl) {
                final previousBaseUrl = _dio.options.baseUrl;
                final opts = error.requestOptions;
                opts.baseUrl = fallbackBaseUrl;
                opts.extra['_hostFallbackRetried'] = true;

                try {
                  final response = await _dio.fetch<dynamic>(opts);
                  // La bascule a réussi, on adopte la nouvelle baseUrl
                  _dio.options.baseUrl = fallbackBaseUrl;
                  ApiEndpoints.baseUrl = fallbackBaseUrl;
                  debugPrint('[DIO] Bascule d\'URL réussie vers $fallbackBaseUrl');
                  return handler.resolve(response);
                } on DioException catch (retryError) {
                  // Le fallback a échoué : on restaure impérativement l'URL initiale
                  _dio.options.baseUrl = previousBaseUrl;
                  ApiEndpoints.baseUrl = previousBaseUrl;
                  return handler.next(retryError);
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Logging en mode débogage sans polluer les tests unitaires
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (log) => debugPrint('[DIO] $log'),
        ),
      );
    }
  }

  /// Instance Dio sous-jacente pour les cas d'utilisation avancés.
  Dio get dio => _dio;

  /// Intercepteur d'authentification pour gérer le jeton JWT.
  AuthInterceptor get authInterceptor => _authInterceptor;

  /// URL de base actuelle.
  String get baseUrl => _dio.options.baseUrl;

  /// Met à jour l'URL de base (ex: bascule dynamique vers émulateur Android ou serveur distant).
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Injecte manuellement le jeton Firebase JWT dans l'intercepteur.
  void setAuthToken(String? token) {
    _authInterceptor.setToken(token);
  }

  /// Réinitialise le jeton lors de la déconnexion.
  void clearAuthToken() {
    _authInterceptor.clearToken();
  }

  /// Fournit une fonction pour rafraîchir ou récupérer le jeton de manière asynchrone.
  void setTokenProvider(TokenProvider? provider) {
    _authInterceptor.setTokenProvider(provider);
  }

  /// Enregistre une fonction de rappel déclenchée lors de l'expiration du jeton (401).
  void setOnTokenExpired(OnTokenExpiredCallback? callback) {
    _authInterceptor.setOnTokenExpired(callback);
  }

  // ===========================================================================
  // REQUÊTES HTTP SÉCURISÉES AVEC RETOUR TYPE-SAFE [ApiResponse<T>]
  // ===========================================================================

  /// Effectue une requête HTTP GET sécurisée.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _buildSuccessResponse<T>(response, decoder);
    } catch (e) {
      return _buildErrorResponse<T>(e);
    }
  }

  /// Effectue une requête HTTP POST sécurisée.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _buildSuccessResponse<T>(response, decoder);
    } catch (e) {
      return _buildErrorResponse<T>(e);
    }
  }

  /// Effectue une requête HTTP PUT sécurisée.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _buildSuccessResponse<T>(response, decoder);
    } catch (e) {
      return _buildErrorResponse<T>(e);
    }
  }

  /// Effectue une requête HTTP PATCH sécurisée.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _buildSuccessResponse<T>(response, decoder);
    } catch (e) {
      return _buildErrorResponse<T>(e);
    }
  }

  /// Effectue une requête HTTP DELETE sécurisée.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _buildSuccessResponse<T>(response, decoder);
    } catch (e) {
      return _buildErrorResponse<T>(e);
    }
  }

  /// Téléverse un fichier multimédia (Photo géotaguée ou Enregistrement audio de tradipraticien - US-15).
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    required String fileFieldName,
    String? customFileName,
    Map<String, dynamic>? extraFields,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final fileName = customFileName ?? file.path.split('/').last;
      final multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      );

      final formDataMap = <String, dynamic>{
        fileFieldName: multipartFile,
        if (extraFields != null) ...extraFields,
      };

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return _buildSuccessResponse<T>(response, decoder);
    } catch (e) {
      return _buildErrorResponse<T>(e);
    }
  }

  // ===========================================================================
  // CONSTRUCTEURS INTERNES DE RÉPONSES
  // ===========================================================================

  ApiResponse<T> _buildSuccessResponse<T>(
    Response<dynamic> response,
    T Function(dynamic data)? decoder,
  ) {
    final responseData = response.data;
    if (decoder != null) {
      return ApiResponse.fromJson(
        responseData,
        decoder,
        statusCode: response.statusCode,
      );
    }

    if (responseData is T) {
      return ApiResponse.success(
        responseData,
        statusCode: response.statusCode,
        rawResponse: responseData,
      );
    }

    return ApiResponse.fromJson(
      responseData,
      (data) => data as T,
      statusCode: response.statusCode,
    );
  }

  ApiResponse<T> _buildErrorResponse<T>(dynamic error) {
    final appException = ErrorHandler.handle(error);
    return ApiResponse<T>.error(
      appException.message,
      statusCode: appException.statusCode,
      validationErrors: appException.validationErrors,
      rawResponse: appException.originalError,
    );
  }
}

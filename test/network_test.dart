import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/constants.dart';
import 'package:ladafura_frontend_flutter/core/network/network.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Network Layer Tests - LADAFURA', () {
    test('ApiClient singleton and configuration conform to specs', () {
      final client1 = ApiClient();
      final client2 = ApiClient.instance;

      expect(identical(client1, client2), isTrue);
      expect(client1.baseUrl, ApiEndpoints.baseUrl);
      expect(client1.dio.options.connectTimeout, const Duration(seconds: 15));
      expect(client1.dio.options.receiveTimeout, const Duration(seconds: 15));
      expect(client1.dio.options.sendTimeout, const Duration(seconds: 15));

      // Vérification des headers standard
      expect(client1.dio.options.headers['Accept'], 'application/json');
      expect(client1.dio.options.headers['Accept-Language'], 'fr-FR');

      // Vérification de la présence de l'AuthInterceptor
      expect(
        client1.dio.interceptors.any((i) => i is AuthInterceptor),
        isTrue,
      );
    });

    test('AuthInterceptor injects Bearer token and handles 401 expiration',
        () async {
      final interceptor = AuthInterceptor();
      interceptor.setToken('test_firebase_jwt_token_123');

      // Simulation d'une requête sortante
      final options = RequestOptions(path: '/population/panier');
      final handler = _TestRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(
        options.headers['Authorization'],
        'Bearer test_firebase_jwt_token_123',
      );
      expect(options.headers['Accept'], 'application/json');
      expect(options.headers['Accept-Language'], 'fr-FR');

      // Test expiration de session sur 401
      var sessionExpiredTriggered = false;
      interceptor.setOnTokenExpired(() {
        sessionExpiredTriggered = true;
      });

      final errResponse = Response(
        requestOptions: options,
        statusCode: HttpStatus.unauthorized,
      );
      final dioError = DioException(
        requestOptions: options,
        response: errResponse,
        type: DioExceptionType.badResponse,
      );

      final errorHandler = _TestErrorInterceptorHandler();
      interceptor.onError(dioError, errorHandler);

      expect(sessionExpiredTriggered, isTrue);
      final activeToken = await interceptor.getActiveToken();
      expect(activeToken, isNull);
    });

    test('ApiResponse handles success, errors, and when pattern matching', () {
      // 1. Succès
      const successResponse = ApiResponse<String>.success(
        'Baobab (Adansonia digitata)',
        message: 'Plante trouvée',
        statusCode: 200,
      );
      expect(successResponse.isSuccess, isTrue);
      expect(successResponse.isError, isFalse);
      expect(successResponse.hasData, isTrue);
      expect(successResponse.data, 'Baobab (Adansonia digitata)');

      final result1 = successResponse.when(
        success: (data, msg) => 'OK: $data',
        error: (msg, code, errs) => 'ERR',
      );
      expect(result1, 'OK: Baobab (Adansonia digitata)');

      // 2. Échec avec validation errors
      const errorResponse = ApiResponse<String>.error(
        'Numéro de téléphone invalide',
        statusCode: 400,
        validationErrors: {'telephone': 'Doit comporter 8 chiffres maliens'},
      );
      expect(errorResponse.isSuccess, isFalse);
      expect(errorResponse.isError, isTrue);
      expect(errorResponse.hasValidationErrors, isTrue);
      expect(
        errorResponse.fieldError('telephone'),
        'Doit comporter 8 chiffres maliens',
      );

      final result2 = errorResponse.when(
        success: (data, msg) => 'OK',
        error: (msg, code, errs) => 'ERR: $msg ($code)',
      );
      expect(result2, 'ERR: Numéro de téléphone invalide (400)');
    });

    test('ApiResponse.fromJson parses Spring Boot direct & enveloped responses',
        () {
      // Payload Spring Boot classique
      final jsonDirect = {
        'id': 1,
        'nomScientifique': 'Adansonia digitata',
        'nomCommun': 'Baobab',
      };
      final apiResp1 = ApiResponse.fromJson(
        jsonDirect,
        (json) => json['nomCommun'] as String,
        statusCode: 200,
      );
      expect(apiResp1.isSuccess, isTrue);
      expect(apiResp1.data, 'Baobab');

      // Payload d'erreur Spring Boot GlobalExceptionHandler
      final jsonError = {
        'timestamp': '2026-09-29T22:30:00',
        'status': 400,
        'error': 'Bad Request',
        'message': 'Données invalides',
        'path': '/api/v1/agent/collectes',
        'validationErrors': {
          'planteNom': 'Le nom de la plante est obligatoire',
        },
      };

      final apiResp2 = ApiResponse<dynamic>.fromJson(
        jsonError,
        (json) => json,
        statusCode: 400,
      );
      expect(apiResp2.isError, isTrue);
      expect(apiResp2.message, 'Données invalides');
      expect(apiResp2.statusCode, 400);
      expect(
        apiResp2.fieldError('planteNom'),
        'Le nom de la plante est obligatoire',
      );
    });

    test(
        'ErrorHandler decodes timeouts and HTTP status codes into friendly messages',
        () {
      final reqOptions = RequestOptions(path: '/api/v1/population/plantes');

      // 1. Timeout de connexion
      final timeoutErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionTimeout,
      );
      final ex1 = ErrorHandler.handle(timeoutErr);
      expect(ex1, isA<NetworkException>());
      expect(ex1.message, contains('15s'));

      // 2. Erreur 400 avec message backend
      final badReqErr = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 400,
          data: {
            'message': 'Champs requis manquants',
            'validationErrors': {'nom': 'Obligatoire'},
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final ex2 = ErrorHandler.handle(badReqErr);
      expect(ex2, isA<BadRequestException>());
      expect(ex2.message, 'Champs requis manquants');
      expect(ex2.validationErrors?['nom'], 'Obligatoire');

      // 3. Erreur 401 Session expirée
      final unauthErr = DioException(
        requestOptions: reqOptions,
        response: Response(requestOptions: reqOptions, statusCode: 401),
        type: DioExceptionType.badResponse,
      );
      final ex3 = ErrorHandler.handle(unauthErr);
      expect(ex3, isA<UnauthorizedException>());
      expect(ex3.statusCode, 401);
      expect(ex3.message, contains('reconnecter'));

      // 4. Erreur 403 Accès interdit
      final forbiddenErr = DioException(
        requestOptions: reqOptions,
        response: Response(requestOptions: reqOptions, statusCode: 403),
        type: DioExceptionType.badResponse,
      );
      final ex4 = ErrorHandler.handle(forbiddenErr);
      expect(ex4, isA<ForbiddenException>());
      expect(ex4.statusCode, 403);

      // 5. Erreur 404 Ressource introuvable
      final notFoundErr = DioException(
        requestOptions: reqOptions,
        response: Response(requestOptions: reqOptions, statusCode: 404),
        type: DioExceptionType.badResponse,
      );
      final ex5 = ErrorHandler.handle(notFoundErr);
      expect(ex5, isA<NotFoundException>());
      expect(ex5.statusCode, 404);

      // 6. Erreur 500 Serveur
      final serverErr = DioException(
        requestOptions: reqOptions,
        response: Response(requestOptions: reqOptions, statusCode: 500),
        type: DioExceptionType.badResponse,
      );
      final ex6 = ErrorHandler.handle(serverErr);
      expect(ex6, isA<ServerException>());
      expect(ex6.statusCode, 500);
    });

    test(
        'Riverpod network providers inject ApiClient, Dio and AuthInterceptor correctly',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final client = container.read(apiClientProvider);
      final dio = container.read(dioProvider);
      final authInterceptor = container.read(authInterceptorProvider);

      expect(client, isNotNull);
      expect(dio, isNotNull);
      expect(authInterceptor, isNotNull);
      expect(identical(client, ApiClient.instance), isTrue);
      expect(identical(dio, client.dio), isTrue);
      expect(identical(authInterceptor, client.authInterceptor), isTrue);
    });
  });
}

// Helpers pour tester les handlers d'intercepteurs Dio
class _TestRequestInterceptorHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}

class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException err) {}
}

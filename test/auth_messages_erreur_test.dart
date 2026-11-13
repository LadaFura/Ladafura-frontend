import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simule la réponse de l'API Identity Toolkit sans accès réseau.
class _AdaptateurFirebaseFactice implements HttpClientAdapter {
  _AdaptateurFirebaseFactice.code(String code) : _code = code;
  _AdaptateurFirebaseFactice.horsLigne() : _code = null;

  final String? _code;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final code = _code;
    if (code == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Failed host lookup',
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'error': {'code': 400, 'message': code},
      }),
      400,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Service Google dont le plugin lève une erreur technique (cas du web).
class _GoogleEnPanne extends GoogleAuthService {
  _GoogleEnPanne() : super(mockMode: true);

  @override
  Future<GoogleAuthCredentials?> signIn() =>
      throw UnimplementedError('authenticate is not supported on the web');
}

Future<String> _messageDeConnexion(
    _AdaptateurFirebaseFactice adaptateur) async {
  final service = FirebaseAuthService(
    dio: Dio()..httpClientAdapter = adaptateur,
    firebaseApiKey: 'cle-de-test',
  );
  try {
    await service.signInWithEmailAndPassword(
      email: 'awa.diarra@example.ml',
      password: 'motdepasse',
    );
  } on Exception catch (e) {
    return e.toString();
  }
  fail('Une exception était attendue.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Messages d\'erreur Firebase affichés à l\'utilisateur', () {
    test('identifiants incorrects : message français précis', () async {
      final message = await _messageDeConnexion(
        _AdaptateurFirebaseFactice.code('INVALID_LOGIN_CREDENTIALS'),
      );

      expect(message, contains('Adresse e-mail ou mot de passe incorrect.'));
    });

    test('code Firebase inconnu : aucun terme technique à l\'écran', () async {
      final message = await _messageDeConnexion(
        _AdaptateurFirebaseFactice.code('OPERATION_NOT_ALLOWED'),
      );

      expect(message, contains('momentanément indisponible'));
      expect(message, isNot(contains('OPERATION_NOT_ALLOWED')));
      expect(message, isNot(contains('Firebase')));
    });

    test('pas de réseau : invite à vérifier la connexion Internet', () async {
      final message = await _messageDeConnexion(
        _AdaptateurFirebaseFactice.horsLigne(),
      );

      expect(message, contains('Vérifiez votre connexion Internet'));
    });
  });

  group('Connexion Google en échec', () {
    test('erreur technique du plugin : message générique en français',
        () async {
      SharedPreferences.setMockInitialValues({});
      final storageService =
          StorageService(await SharedPreferences.getInstance());
      final firebaseAuthService = FirebaseAuthService(mockMode: true);
      final googleAuthService = _GoogleEnPanne();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            AuthRepository(
              apiClient: ApiClient(),
              firebaseAuthService: firebaseAuthService,
              googleAuthService: googleAuthService,
              storageService: storageService,
            ),
          ),
          googleAuthServiceProvider.overrideWithValue(googleAuthService),
          firebaseAuthServiceProvider.overrideWithValue(firebaseAuthService),
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );
      addTearDown(container.dispose);

      final connecte =
          await container.read(authStateProvider.notifier).signInWithGoogle();

      final etat = container.read(authStateProvider);
      expect(connecte, isFalse);
      expect(etat.isAuthenticated, isFalse);
      expect(etat.errorMessage, contains('Une erreur inattendue est survenue'));
      expect(etat.errorMessage, isNot(contains('UnimplementedError')));
    });
  });
}

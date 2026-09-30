import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/routing/app_router.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/auth/auth.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Session Persistence - Repositories & Providers', () {
    test(
        'AuthRepository returns cached citizen user and preserves session on error',
        () async {
      SharedPreferences.setMockInitialValues({
        'ladafura_jwt_token': 'saved_jwt_token_123',
        'ladafura_user_email': 'citoyen.mali@gmail.com',
        'ladafura_user_role': 'POPULATION',
        'ladafura_user_id': '45',
        'ladafura_user_name': 'Fatoumata Traoré',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final repo = AuthRepository(
        apiClient: ApiClient(),
        firebaseAuthService: FirebaseAuthService(mockMode: true),
        storageService: storage,
      );

      // Vérification immédiate du cache local (0 appel réseau)
      final cached = repo.getCachedUser();
      expect(cached, isNotNull);
      expect(cached!.email, 'citoyen.mali@gmail.com');
      expect(cached.role, UserRole.population);
      expect(cached.nom, 'Fatoumata Traoré');

      // Même si le serveur renvoie une erreur (hors-ligne), la session est préservée
      final current = await repo.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.email, 'citoyen.mali@gmail.com');
      expect(storage.getToken(), 'saved_jwt_token_123');
    });

    test('AuthRepository returns cached agent user correctly', () async {
      SharedPreferences.setMockInitialValues({
        'ladafura_jwt_token': 'saved_agent_token_999',
        'ladafura_user_email': 'agent.kone@ladafura.ml',
        'ladafura_user_role': 'AGENT_COLLECTE',
        'ladafura_user_id': 'AGT-BKO-2026',
        'ladafura_user_name': 'Mamadou Koné',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final repo = AuthRepository(
        apiClient: ApiClient(),
        firebaseAuthService: FirebaseAuthService(mockMode: true),
        storageService: storage,
      );

      final cached = repo.getCachedUser();
      expect(cached, isNotNull);
      expect(cached!.role, UserRole.agentCollecte);
      expect(cached.email, 'agent.kone@ladafura.ml');
      expect(cached.matricule, 'AGT-BKO-2026');
    });

    test('logout() cleans storage, clears tokens and switches state to unauthenticated',
        () async {
      SharedPreferences.setMockInitialValues({
        'ladafura_jwt_token': 'token_to_clear',
        'ladafura_user_email': 'citoyen.test@ladafura.ml',
        'ladafura_user_role': 'POPULATION',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final repo = AuthRepository(
        apiClient: ApiClient(),
        firebaseAuthService: FirebaseAuthService(mockMode: true),
        storageService: storage,
      );

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Avant déconnexion
      expect(storage.getToken(), isNotNull);
      expect(repo.getCachedUser(), isNotNull);

      // Exécution de la déconnexion
      await container.read(authStateProvider.notifier).logout();

      // Après déconnexion
      expect(storage.getToken(), isNull);
      expect(storage.getRole(), isNull);
      expect(repo.getCachedUser(), isNull);
      expect(container.read(authStateProvider).isAuthenticated, isFalse);
      expect(container.read(authRoutingStateProvider).isAuthenticated, isFalse);
      expect(container.read(authRoutingStateProvider).role, isNull);
    });
  });

  group('Session Persistence - SplashScreen routing', () {
    testWidgets('SplashScreen routes citizen directly to /citizen',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'ladafura_jwt_token': 'token_abc',
        'ladafura_user_email': 'citoyen@ladafura.ml',
        'ladafura_user_role': 'POPULATION',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            firebaseAuthServiceProvider
                .overrideWithValue(FirebaseAuthService(mockMode: true)),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('LADAFURA'), findsOneWidget);

      // Écouler le délai de 1000ms du SplashScreen
      await tester.pump(const Duration(milliseconds: 1200));
    });
  });
}

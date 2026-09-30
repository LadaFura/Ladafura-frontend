import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/routing/app_router.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/auth/auth.dart';
import 'package:ladafura_frontend_flutter/features/auth/data/services/google_auth_service.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/google_sign_in_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Google Auth - Service & Credentials', () {
    test('GoogleAuthCredentials model holds token, email and metadata', () {
      const creds = GoogleAuthCredentials(
        idToken: 'sample-google-id-token',
        accessToken: 'sample-access-token',
        email: 'fatoumata.diarra@gmail.com',
        displayName: 'Fatoumata Diarra',
        photoUrl: 'https://example.com/avatar.jpg',
      );

      expect(creds.idToken, 'sample-google-id-token');
      expect(creds.accessToken, 'sample-access-token');
      expect(creds.email, 'fatoumata.diarra@gmail.com');
      expect(creds.displayName, 'Fatoumata Diarra');
      expect(creds.photoUrl, 'https://example.com/avatar.jpg');
    });

    test('GoogleAuthService mock mode returns mock credentials', () async {
      final service = GoogleAuthService(mockMode: true);
      expect(service.isMockMode, isTrue);

      // Default mock credentials
      final defaultCreds = await service.signIn();
      expect(defaultCreds, isNotNull);
      expect(defaultCreds!.email, 'citoyen.test@gmail.com');
      expect(defaultCreds.idToken, startsWith('mock-google-id-token'));

      // Custom mock credentials
      service.setMockCredentials(
        const GoogleAuthCredentials(
          idToken: 'custom-google-token',
          email: 'custom.user@gmail.com',
          displayName: 'Custom User',
        ),
      );
      final customCreds = await service.signIn();
      expect(customCreds?.email, 'custom.user@gmail.com');
      expect(customCreds?.idToken, 'custom-google-token');
    });

    test('GoogleAuthService mock sign out completes without error', () async {
      final service = GoogleAuthService(mockMode: true);
      await expectLater(service.signOut(), completes);
    });
  });

  group('Google Auth - Widget Button', () {
    testWidgets('GoogleSignInButton renders custom label and icon',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              label: 'Continuer avec Google',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Continuer avec Google'), findsOneWidget);
      await tester.tap(find.byType(GoogleSignInButton));
      expect(tapped, isTrue);
    });

    testWidgets('GoogleSignInButton shows loader and disables click when isLoading is true',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              label: 'Continuer avec Google',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continuer avec Google'), findsNothing);

      await tester.tap(find.byType(GoogleSignInButton));
      expect(tapped, isFalse);
    });
  });

  group('Google Auth - Provider & AuthNotifier flow', () {
    late StorageService storageService;
    late FirebaseAuthService firebaseAuthService;
    late GoogleAuthService googleAuthService;
    late ApiClient apiClient;
    late AuthRepository authRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
      firebaseAuthService = FirebaseAuthService(mockMode: true);
      googleAuthService = GoogleAuthService(mockMode: true);
      apiClient = ApiClient();

      authRepository = AuthRepository(
        apiClient: apiClient,
        firebaseAuthService: firebaseAuthService,
        googleAuthService: googleAuthService,
        storageService: storageService,
      );
    });

    test('AuthNotifier signInWithGoogle updates state on success', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          googleAuthServiceProvider.overrideWithValue(googleAuthService),
          firebaseAuthServiceProvider.overrideWithValue(firebaseAuthService),
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authStateProvider.notifier);
      final routingState = container.read(authRoutingStateProvider);

      // Trigger Google Sign-In
      final result = await notifier.signInWithGoogle(role: UserRole.population);

      expect(result, isTrue);
      final state = container.read(authStateProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.user, isNotNull);
      expect(state.user?.role, UserRole.population);
      expect(routingState.isAuthenticated, isTrue);
      expect(routingState.role, UserRole.population);
    });
  });

  group('Google Auth - Screen Integration', () {
    testWidgets('LoginScreen displays GoogleSignInButton and "OU" divider',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            firebaseAuthServiceProvider
                .overrideWithValue(FirebaseAuthService(mockMode: true)),
            googleAuthServiceProvider
                .overrideWithValue(GoogleAuthService(mockMode: true)),
          ],
          child: const MaterialApp(
            home: LoginScreen(initialRole: UserRole.population),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.text('Continuer avec Google'), findsOneWidget);
      expect(find.text('OU'), findsOneWidget);
    });

    testWidgets('RegisterScreen displays GoogleSignInButton with appropriate text',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            firebaseAuthServiceProvider
                .overrideWithValue(FirebaseAuthService(mockMode: true)),
            googleAuthServiceProvider
                .overrideWithValue(GoogleAuthService(mockMode: true)),
          ],
          child: const MaterialApp(
            home: RegisterScreen(initialRole: UserRole.population),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.text('S\'inscrire avec Google'), findsOneWidget);
      expect(find.text('OU'), findsOneWidget);
    });
  });
}

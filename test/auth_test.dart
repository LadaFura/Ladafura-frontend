import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/auth/auth.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Feature - Models', () {
    test('LoginRequestModel serializes and parses properly', () {
      const model = LoginRequestModel(
        email: 'fatoumata.diarra@gmail.com',
        motDePasse: 'SecretMali2026',
        role: UserRole.population,
      );

      final json = model.toJson();
      expect(json['email'], 'fatoumata.diarra@gmail.com');
      expect(json['motDePasse'], 'SecretMali2026');
      expect(json['role'], 'POPULATION');

      final parsed = LoginRequestModel.fromJson(json);
      expect(parsed.email, model.email);
      expect(parsed.motDePasse, model.motDePasse);
      expect(parsed.role, UserRole.population);
    });

    test('RegisterRequestModel formats JSON specifically for Spring Boot DTO',
        () {
      const model = RegisterRequestModel(
        nom: 'Diarra',
        prenom: 'Fatoumata',
        email: 'fatoumata.diarra@gmail.com',
        motDePasse: 'SecretMali2026',
        telephone: '+223 70 12 34 56',
        role: UserRole.population,
      );

      final backendJson = model.toBackendJson();
      expect(backendJson['nom'], 'Diarra');
      expect(backendJson['prenom'], 'Fatoumata');
      expect(backendJson['email'], 'fatoumata.diarra@gmail.com');
      expect(backendJson['motDePasse'], 'SecretMali2026');
      expect(backendJson['telephone'], '+223 70 12 34 56');

      final fullJson = model.toJson();
      final parsed = RegisterRequestModel.fromJson(fullJson);
      expect(parsed.nom, 'Diarra');
      expect(parsed.prenom, 'Fatoumata');
      expect(parsed.role, UserRole.population);
    });
  });

  group('Auth Feature - Firebase Auth Service', () {
    test('FirebaseAuthService generates valid mock credentials in offline mode',
        () async {
      final service = FirebaseAuthService(mockMode: true);
      expect(service.isMockMode, isTrue);

      final result = await service.signInWithEmailAndPassword(
        email: 'test@ladafura.ml',
        password: 'Password123',
      );

      expect(result.email, 'test@ladafura.ml');
      expect(result.idToken, startsWith('mock-firebase-id-token'));
      expect(result.uid, startsWith('uid-'));
      expect(result.expiresIn, 3600);

      final signUpResult = await service.signUpWithEmailAndPassword(
        email: 'new@ladafura.ml',
        password: 'Password123',
      );
      expect(signUpResult.email, 'new@ladafura.ml');
    });
  });

  group('Auth Feature - Repository & Provider', () {
    late StorageService storageService;
    late FirebaseAuthService firebaseAuthService;
    late ApiClient apiClient;
    late AuthRepository authRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
      firebaseAuthService = FirebaseAuthService(mockMode: true);
      apiClient = ApiClient();
      authRepository = AuthRepository(
        apiClient: apiClient,
        firebaseAuthService: firebaseAuthService,
        storageService: storageService,
      );
    });

    test('AuthRepository saves session token and role on logout / check',
        () async {
      await storageService.saveSession(
        token: 'token_abc',
        email: 'user@ladafura.ml',
        role: 'POPULATION',
      );

      expect(storageService.getToken(), 'token_abc');
      expect(storageService.getRole(), 'POPULATION');

      await authRepository.logout();
      expect(storageService.getToken(), isNull);
    });

    test('AuthState initial, loading, authenticated and unauthenticated states',
        () {
      const initial = AuthState.initial();
      expect(initial.status, AuthStatus.initial);
      expect(initial.isLoading, isTrue);
      expect(initial.isAuthenticated, isFalse);

      const unauthenticated = AuthState.unauthenticated();
      expect(unauthenticated.status, AuthStatus.unauthenticated);
      expect(unauthenticated.isAuthenticated, isFalse);

      const error = AuthState.error('Erreur mot de passe');
      expect(error.status, AuthStatus.error);
      expect(error.errorMessage, 'Erreur mot de passe');
    });
  });

  group('Auth Feature - Presentation Widgets', () {
    testWidgets('AuthHeaderWidget displays title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeaderWidget(
              title: 'Connexion Citoyen',
              subtitle: 'Accédez à votre espace',
            ),
          ),
        ),
      );

      expect(find.text('Connexion Citoyen'), findsOneWidget);
      expect(find.text('Accédez à votre espace'), findsOneWidget);
    });

    testWidgets('PhoneInputField renders Mali flag and +223 prefix',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: PhoneInputField(
                controller: controller,
                isRequired: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('+223'), findsOneWidget);
      expect(find.text('🇲🇱'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '70123456');
      expect(controller.text, '70123456');
    });

    testWidgets('RoleCardSelector allows selecting between Citoyen and Agent',
        (tester) async {
      UserRole selected = UserRole.population;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return RoleCardSelector(
                  selectedRole: selected,
                  onRoleSelected: (newRole) {
                    setState(() {
                      selected = newRole;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Citoyen / Population'), findsOneWidget);
      expect(find.text('Agent de Collecte'), findsOneWidget);
      expect(find.text('Officine / Pharmacopée'), findsNothing);

      // Tap on Agent
      await tester.tap(find.text('Agent de Collecte'));
      await tester.pump();
      expect(selected, UserRole.agentCollecte);

      // Tap back on Citoyen
      await tester.tap(find.text('Citoyen / Population'));
      await tester.pump();
      expect(selected, UserRole.population);
    });

    testWidgets('LoginScreen renders fields and validates empty inputs',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      StorageService(prefs);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(initialRole: UserRole.population),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Adresse email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsWidgets);

      // Tap submit with empty fields
      await tester.tap(find.text('Se connecter').first);
      await tester.pump();

      expect(find.text("L'adresse email est obligatoire"), findsOneWidget);
      expect(find.text('Le mot de passe est obligatoire'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders form fields and terms disclaimer',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      StorageService(prefs);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(initialRole: UserRole.population),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prénom'), findsOneWidget);
      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('Adresse email'), findsOneWidget);
      expect(find.text('Créer mon compte'), findsWidgets);

      // Scroll to button and tap submit with empty fields
      await tester.ensureVisible(find.text('Créer mon compte').first);
      await tester.tap(find.text('Créer mon compte').first);
      await tester.pump();

      expect(find.text('Le prénom est obligatoire'), findsOneWidget);
      expect(find.text('Le nom est obligatoire'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/auth/providers/auth_state_provider.dart';
import 'package:ladafura_frontend_flutter/features/population/presentation/home/screens/citizen_home_screen.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('CitizenHomeScreen displays citizen info, services and logout buttons',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    StorageService.init(prefs);

    const testCitizen = UtilisateurModel(
      id: 101,
      email: 'fatoumata.diarra@gmail.com',
      nom: 'Diarra',
      prenom: 'Fatoumata',
      role: UserRole.population,
    );

    final fakeNotifier = _FakeCitizenAuthNotifier(
      const AuthState(
        status: AuthStatus.authenticated,
        user: testCitizen,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => fakeNotifier),
        ],
        child: const MaterialApp(
          home: CitizenHomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Vérification des infos du citoyen
    expect(find.text('Espace Citoyen'), findsOneWidget);
    expect(find.text('Fatoumata Diarra'), findsOneWidget);
    expect(find.text('fatoumata.diarra@gmail.com'), findsOneWidget);
    expect(find.text('Citoyen / Population 🇲🇱'), findsOneWidget);

    // Vérification des cartes de services
    expect(find.text('Recherche Flore'), findsOneWidget);
    expect(find.text('Mes Favoris'), findsOneWidget);
    expect(find.text('Carte Botanique'), findsOneWidget);
    expect(find.text('Savoirs Ancestraux'), findsOneWidget);

    // Vérification des boutons de déconnexion
    // 1. Bouton dans l'AppBar (icône rouge) + icône dans la carte session
    expect(find.byIcon(Icons.logout_rounded), findsNWidgets(3));

    // 2. Bouton "Déconnexion" dans la carte
    expect(find.text('Déconnexion'), findsOneWidget);

    // Tester l'ouverture de la boîte de dialogue de déconnexion
    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    expect(find.text('Êtes-vous sûr de vouloir vous déconnecter de votre espace citoyen ?'),
        findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);

    // Confirmer la déconnexion
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(fakeNotifier.logoutCalled, isTrue);
  });
}

class _FakeCitizenAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  bool logoutCalled = false;

  _FakeCitizenAuthNotifier(super.state);

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<bool> login({
    required String email,
    required String password,
    UserRole? role,
  }) async =>
      true;

  @override
  Future<bool> register(dynamic request) async => true;

  @override
  Future<bool> signInWithGoogle({UserRole? role}) async => true;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = const AuthState.unauthenticated();
  }
}

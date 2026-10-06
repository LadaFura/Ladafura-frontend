import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/auth/providers/auth_state_provider.dart';
import 'package:ladafura_frontend_flutter/features/home/presentation/pages/citizen_home_screen.dart';
import 'package:ladafura_frontend_flutter/features/home/presentation/widgets/home_banner_widget.dart';
import 'package:ladafura_frontend_flutter/features/home/presentation/widgets/home_quick_categories.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'CitizenHomeScreen displays home banner, categories and no login/logout buttons',
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

    // Vérification de la structure d'accueil identique au visiteur
    expect(find.byType(HomeBannerWidget), findsOneWidget);
    expect(find.byType(HomeQuickCategories), findsOneWidget);
    expect(find.text('Pharmacopées à proximité'), findsOneWidget);
    expect(find.text('Produits populaires'), findsNothing);
    expect(find.text('Plantes les plus consultées'), findsOneWidget);

    // Vérification de l'absence de boutons de connexion et déconnexion
    expect(find.byIcon(Icons.logout_rounded), findsNothing);
    expect(find.text('Déconnexion'), findsNothing);
    expect(find.text('Se déconnecter'), findsNothing);
    expect(find.text('Connexion'), findsNothing);
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

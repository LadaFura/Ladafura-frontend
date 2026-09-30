import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/agent/presentation/dashboard/screens/agent_dashboard_screen.dart';
import 'package:ladafura_frontend_flutter/features/auth/providers/auth_state_provider.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AgentDashboardScreen displays agent info and logout buttons',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    StorageService.init(prefs);

    const testUser = UtilisateurModel(
      id: 42,
      email: 'agent.kone@ladafura.ml',
      nom: 'Koné',
      prenom: 'Mamadou',
      role: UserRole.agentCollecte,
      matricule: 'AGT-MKT-2026',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => _FakeAuthNotifier(
              const AuthState(
                status: AuthStatus.authenticated,
                user: testUser,
              ),
              ref: ref,
            ),
          ),
        ],
        child: const MaterialApp(
          home: AgentDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Vérification des infos de l'agent
    expect(find.text('Espace Agent'), findsOneWidget);
    expect(find.text('Mamadou Koné'), findsOneWidget);
    expect(find.text('agent.kone@ladafura.ml'), findsOneWidget);
    expect(find.text('Matricule : AGT-MKT-2026'), findsOneWidget);
    expect(find.text('AGENT TERRAIN'), findsOneWidget);

    // Vérification des boutons de déconnexion
    // 1. Dans l'AppBar
    expect(find.byIcon(Icons.logout_rounded), findsNWidgets(2));

    // 2. Dans le corps de la page
    expect(
      find.text('Se déconnecter de l\'espace Agent'),
      findsOneWidget,
    );

    // Tap sur le bouton de déconnexion dans le corps
    await tester.ensureVisible(find.text('Se déconnecter de l\'espace Agent'));
    await tester.tap(find.text('Se déconnecter de l\'espace Agent'));
    await tester.pumpAndSettle();

    // Vérification de la boîte de dialogue de confirmation
    expect(find.text('Déconnexion'), findsOneWidget);
    expect(
      find.text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre espace Agent de Collecte ?'),
      findsOneWidget,
    );
    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);

    // Tap sur Annuler
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    // La boîte de dialogue s'est fermée
    expect(
      find.text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre espace Agent de Collecte ?'),
      findsNothing,
    );
  });
}

class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier(super.initial, {required Ref ref});

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
    state = const AuthState.unauthenticated();
  }
}

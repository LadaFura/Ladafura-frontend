import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/features/auth/providers/auth_state_provider.dart';
import 'package:ladafura_frontend_flutter/features/panier/providers/panier_provider.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/models/pharmacopee_detail_model.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/models/pharmacopee_produit_item_model.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/presentation/pages/pharmacopee_detail_page.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/presentation/widgets/pharmacopee_modes_retrait_selector.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/providers/pharmacopee_provider.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/utilisateur_model.dart';

void main() {
  const samplePharma = PharmacopeeDetailModel(
    id: 1,
    nom: 'Grande Pharmacopée de Bamako',
    description: 'Centre d\'excellence en phytothérapie et remèdes maliens',
    telephone: '+223 70 00 00 00',
    localisation: PharmacopeeLocalisationModel(
      commune: 'Commune IV',
      localite: 'Lafiabougou',
      region: 'Bamako',
      latitude: 12.6392,
      longitude: -8.0029,
    ),
    modesRetrait: [
      PharmacopeeModeRetraitModel(
        id: 1,
        type: 'LIVRAISON',
        actif: true,
        frais: 1000.0,
      ),
      PharmacopeeModeRetraitModel(
        id: 2,
        type: 'PICKUP',
        actif: true,
        frais: 0.0,
      ),
    ],
    nombreProduits: 2,
    noteMoyenne: 4.8,
    nombreAvis: 14,
  );

  final sampleProduits = [
    const PharmacopeeProduitItemModel(
      disponibiliteId: 10,
      produitId: 101,
      nom: 'Tisane Kinkéliba Bio',
      description: 'Décoction détoxifiante pour le foie',
      forme: 'Sachet 100g',
      prix: 1500.0,
      disponible: true,
      quantiteStock: 15,
      categorieNom: 'Tisanes',
    ),
    const PharmacopeeProduitItemModel(
      disponibiliteId: 11,
      produitId: 102,
      nom: 'Baume Moringa Purifiant',
      description: 'Pommade naturelle pour affections cutanées',
      forme: 'Pot 50ml',
      prix: 2500.0,
      disponible: true,
      quantiteStock: 5,
      categorieNom: 'Baumes',
    ),
  ];

  group('PharmacopeeDetailPage Tests', () {
    testWidgets('Renders detail header, withdrawal modes and products list',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pharmacopeeFullDetailProvider(1)
                .overrideWith((ref) => Future.value(samplePharma)),
            pharmacopeeProduitsProvider(1)
                .overrideWith((ref) => Future.value(sampleProduits)),
            pharmacopeeAvisProvider(1)
                .overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(
            home: PharmacopeeDetailPage(pharmacopeeId: 1),
          ),
        ),
      );

      // Laisser le chargement se résoudre
      await tester.pumpAndSettle();

      // Vérifier le nom de la pharmacopée
      expect(find.text('Grande Pharmacopée de Bamako'), findsOneWidget);
      expect(find.text('Agréée LADAFURA'), findsOneWidget);

      // Vérifier les modes de retrait
      expect(find.text('Livraison'), findsOneWidget);
      expect(find.text('Retrait sur place'), findsOneWidget);

      // Vérifier la présence des produits
      expect(find.text('Tisane Kinkéliba Bio'), findsOneWidget);
      expect(find.text('Baume Moringa Purifiant'), findsOneWidget);
      expect(find.text('1 500 FCFA'), findsOneWidget);
      expect(find.text('2 500 FCFA'), findsOneWidget);
    });

    testWidgets('Unauthenticated user attempting to add product sees login prompt',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          pharmacopeeFullDetailProvider(1)
              .overrideWith((ref) => Future.value(samplePharma)),
          pharmacopeeProduitsProvider(1)
              .overrideWith((ref) => Future.value(sampleProduits)),
          pharmacopeeAvisProvider(1)
              .overrideWith((ref) => Future.value([])),
          // Utilisateur non connecté par défaut
          authStateProvider.overrideWith(
            (ref) => _FakeTestAuthNotifier(const AuthState.unauthenticated()),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PharmacopeeDetailPage(pharmacopeeId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Aucun article dans le panier
      expect(container.read(panierProvider), isEmpty);

      // Cliquer sur le bouton "+"
      final addButtons = find.byIcon(Icons.add_rounded);
      expect(addButtons, findsWidgets);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // La modale Connexion requise doit être visible
      expect(find.text('Connexion requise'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);

      // Le panier ne doit pas avoir été modifié
      expect(container.read(panierProvider), isEmpty);
    });

    testWidgets('Authenticated user can add product to cart',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const dummyUser = UtilisateurModel(
        id: 1,
        nom: 'Traore',
        prenom: 'Ousmane',
        email: 'ousmane@ladafura.ml',
        role: UserRole.population,
      );

      final container = ProviderContainer(
        overrides: [
          pharmacopeeFullDetailProvider(1)
              .overrideWith((ref) => Future.value(samplePharma)),
          pharmacopeeProduitsProvider(1)
              .overrideWith((ref) => Future.value(sampleProduits)),
          pharmacopeeAvisProvider(1)
              .overrideWith((ref) => Future.value([])),
          // Utilisateur connecté
          authStateProvider.overrideWith(
            (ref) => _FakeTestAuthNotifier(const AuthState.authenticated(dummyUser)),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PharmacopeeDetailPage(pharmacopeeId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Aucun article initialement dans le panier
      expect(container.read(panierProvider), isEmpty);

      // Cliquer sur le premier bouton "+" circulaire d'ajout au panier
      final addButtons = find.byIcon(Icons.add_rounded);
      expect(addButtons, findsWidgets);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Vérifier que le produit est bien ajouté au panier
      final panierItems = container.read(panierProvider);
      expect(panierItems.length, 1);
      expect(panierItems.first.produit.nom, 'Tisane Kinkéliba Bio');
      expect(panierItems.first.quantite, 1);

      // Vérifier que le bouton flottant "Mon Panier" s'affiche
      expect(find.text('Mon Panier'), findsOneWidget);
    });

    testWidgets('Modes de retrait selector displays pickup only when livraison not available',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PharmacopeeModesRetraitSelector(
              modes: const [
                PharmacopeeModeRetraitModel(
                  id: 2,
                  type: 'PICKUP',
                  actif: true,
                  frais: 0.0,
                ),
              ],
              selectedMode: 'PICKUP',
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Retrait sur place'), findsOneWidget);
      expect(find.text('Livraison'), findsNothing);
    });
  });
}

class _FakeTestAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeTestAuthNotifier(super.state);

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

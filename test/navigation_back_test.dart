import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/routing/app_router.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    StorageService(prefs);
  });

  GoRouter createTestRouter(
      {String initialLocation = RouteNames.visitorHomePath}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(location: state.matchedLocation, child: child),
          routes: [
            GoRoute(
              path: RouteNames.visitorHomePath,
              builder: (context, state) =>
                  const Scaffold(body: Text('Contenu Accueil Visiteur')),
            ),
            GoRoute(
              path: RouteNames.visitorRecherchePath,
              builder: (context, state) =>
                  const RoutePlaceholderScreen(title: 'Recherche Universelle'),
            ),
            GoRoute(
              path: RouteNames.visitorCartePath,
              builder: (context, state) => const RoutePlaceholderScreen(
                  title: 'Carte de la Flore Malienne'),
            ),
            GoRoute(
              path: RouteNames.visitorPanierPath,
              builder: (context, state) =>
                  const RoutePlaceholderScreen(title: 'Mon Panier'),
            ),
            GoRoute(
              path: RouteNames.visitorProfilPath,
              builder: (context, state) =>
                  const RoutePlaceholderScreen(title: 'Mon Profil'),
            ),
            GoRoute(
              path: RouteNames.visitorPlanteDetailPath,
              builder: (context, state) => RoutePlaceholderScreen(
                title: 'Détail Plante (${state.pathParameters['id']})',
                isSecondary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  group('Navigation & BottomNavBar Back Button Rules', () {
    testWidgets(
        'Main bottom bar sections (Recherche, Carte, Panier, Profil) have NO back arrow',
        (tester) async {
      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Sur Accueil : Aucune icône retour
      expect(find.text('Contenu Accueil Visiteur'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // 2. Clic sur onglet 1 (Recherche)
      final rechercheTab = find.byKey(const ValueKey('nav_item_1'));
      expect(rechercheTab, findsOneWidget);
      await tester.tap(rechercheTab);
      await tester.pumpAndSettle();

      expect(find.text('Recherche Universelle'), findsWidgets);
      // AUCUNE icône de retour sur la section principale Recherche
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // 3. Clic sur onglet 2 (Carte)
      final carteTab = find.byKey(const ValueKey('nav_item_2'));
      await tester.tap(carteTab);
      await tester.pumpAndSettle();

      expect(find.text('Carte de la Flore Malienne'), findsWidgets);
      // AUCUNE icône de retour sur la section principale Carte
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // 4. Clic sur onglet 3 (Panier)
      final panierTab = find.byKey(const ValueKey('nav_item_3'));
      await tester.tap(panierTab);
      await tester.pumpAndSettle();

      expect(find.text('Mon Panier'), findsWidgets);
      // AUCUNE icône de retour sur la section principale Panier
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // 5. Clic sur onglet 4 (Profil)
      final profilTab = find.byKey(const ValueKey('nav_item_4'));
      await tester.tap(profilTab);
      await tester.pumpAndSettle();

      expect(find.text('Mon Profil'), findsWidgets);
      // AUCUNE icône de retour sur la section principale Profil
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets(
        'Secondary pages (Détail Plante) HAVE a back arrow that returns to previous page',
        (tester) async {
      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Naviguer vers la page secondaire Détail Plante
      router.go(RouteNames.visitorPlanteDetailUrl('42'));
      await tester.pumpAndSettle();

      expect(find.text('Détail Plante (42)'), findsWidgets);

      // Une icône retour DOIT être présente sur la page secondaire
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Clic sur l'icône retour
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // On est revenu en arrière (sur Recherche ou Accueil)
      expect(find.text('Détail Plante (42)'), findsNothing);
    });

    testWidgets(
        'Secondary pages handle system PopScope back action to previous page',
        (tester) async {
      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Naviguer vers la page secondaire Détail Plante
      router.go(RouteNames.visitorPlanteDetailUrl('99'));
      await tester.pumpAndSettle();

      expect(find.text('Détail Plante (99)'), findsWidgets);

      // Simuler le retour système Android / geste iOS
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // On est revenu en arrière
      expect(find.text('Détail Plante (99)'), findsNothing);
    });
  });
}

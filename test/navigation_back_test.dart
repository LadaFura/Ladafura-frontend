import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/routing/routing.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/app_shell.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/navigation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    StorageService(prefs);
  });

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: RouteNames.visitorHomePath,
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
              builder: (context, state) => PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                  ProviderScope.containerOf(context)
                      .read(navigationIndexProvider.notifier)
                      .setIndex(0);
                  context.go(RouteNames.visitorHomePath);
                },
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Recherche Universelle'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Retour à l\'accueil',
                      onPressed: () {
                        ProviderScope.containerOf(context)
                            .read(navigationIndexProvider.notifier)
                            .setIndex(0);
                        context.go(RouteNames.visitorHomePath);
                      },
                    ),
                  ),
                  body: const Center(child: Text('Recherche Universelle')),
                ),
              ),
            ),
            GoRoute(
              path: RouteNames.visitorCartePath,
              builder: (context, state) => PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                  ProviderScope.containerOf(context)
                      .read(navigationIndexProvider.notifier)
                      .setIndex(0);
                  context.go(RouteNames.visitorHomePath);
                },
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Carte de la Flore Malienne'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Retour à l\'accueil',
                      onPressed: () {
                        ProviderScope.containerOf(context)
                            .read(navigationIndexProvider.notifier)
                            .setIndex(0);
                        context.go(RouteNames.visitorHomePath);
                      },
                    ),
                  ),
                  body: const Center(child: Text('Carte de la Flore Malienne')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  group('Navigation & BottomNavBar Back Button Tests', () {
    testWidgets(
        'Clicking back arrow on Recherche tab redirects to Accueil (index 0)',
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

      // Au démarrage : Accueil actif
      expect(find.text('Contenu Accueil Visiteur'), findsOneWidget);
      expect(find.byType(AppShell), findsOneWidget);

      // Clic sur l'onglet 1 (Recherche)
      final rechercheTab = find.byKey(const ValueKey('nav_item_1'));
      expect(rechercheTab, findsOneWidget);
      await tester.tap(rechercheTab);
      await tester.pumpAndSettle();

      // On est sur Recherche Universelle
      expect(find.text('Recherche Universelle'), findsWidgets);

      // Clic sur la flèche retour
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Redirigé vers Accueil
      expect(find.text('Contenu Accueil Visiteur'), findsOneWidget);
      expect(find.text('Recherche Universelle'), findsNothing);
    });

    testWidgets(
        'Clicking back arrow on Carte tab redirects to Accueil (index 0)',
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

      // Clic sur l'onglet 2 (Carte)
      final carteTab = find.byKey(const ValueKey('nav_item_2'));
      expect(carteTab, findsOneWidget);
      await tester.tap(carteTab);
      await tester.pumpAndSettle();

      // On est sur Carte
      expect(find.text('Carte de la Flore Malienne'), findsWidgets);

      // Clic sur la flèche retour
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Redirigé vers Accueil
      expect(find.text('Contenu Accueil Visiteur'), findsOneWidget);
      expect(find.text('Carte de la Flore Malienne'), findsNothing);
    });

    testWidgets(
        'PopScope system back navigation from secondary tab redirects to Accueil (index 0)',
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

      // Clic sur l'onglet 1 (Recherche)
      final rechercheTab = find.byKey(const ValueKey('nav_item_1'));
      await tester.tap(rechercheTab);
      await tester.pumpAndSettle();
      expect(find.text('Recherche Universelle'), findsWidgets);

      // Simulation du retour système (ex: bouton physique Android / gesture)
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Doit être revenu à l'accueil
      expect(find.text('Contenu Accueil Visiteur'), findsOneWidget);
      expect(find.text('Recherche Universelle'), findsNothing);
    });
  });
}

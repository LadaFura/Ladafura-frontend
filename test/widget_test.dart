import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/core/theme/app_theme.dart';
import 'package:ladafura_frontend_flutter/core/theme/theme_provider.dart';
import 'package:ladafura_frontend_flutter/dev/design_system_showcase.dart';
import 'package:ladafura_frontend_flutter/features/visitor/presentation/screens/accueil_screen.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/media/app_logo.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/ladafura_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    StorageService.init(prefs);
  });

  testWidgets(
      'DesignSystemShowcaseScreen smoke test - verifies initialization, logo, dark theme toggle and modern navbar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeModeProvider);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const DesignSystemShowcaseScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Vérifie que les logos SVG sont présents
    expect(find.byType(AppLogo), findsWidgets);

    // Vérifie le titre LADAFURA
    expect(find.text('LADAFURA'), findsWidgets);

    // Vérifie la présence de la barre de navigation moderne et de l'onglet actif initial (Accueil)
    expect(find.byType(LadafuraBottomNavBar), findsOneWidget);
    expect(find.text('Accueil'), findsWidgets);

    // Vérifie la présence du bouton de bascule de thème
    final themeToggleFinder = find.byTooltip('Passer en mode sombre');
    expect(themeToggleFinder, findsOneWidget);

    // Bascule en mode sombre
    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();

    // Vérifie que le tooltip s'est mis à jour pour proposer le mode clair
    final lightToggleFinder = find.byTooltip('Passer en mode clair');
    expect(lightToggleFinder, findsOneWidget);

    // Bascule en mode clair
    await tester.tap(lightToggleFinder);
    await tester.pumpAndSettle();

    // Vérifie que le tooltip est repassé en mode sombre
    expect(find.byTooltip('Passer en mode sombre'), findsOneWidget);

    // Teste le clic sur l'onglet Recherche via son infobulle
    await tester.tap(find.byTooltip('Recherche'));
    await tester.pumpAndSettle();
    expect(find.text('Recherche'), findsWidgets);

    // Teste le clic sur l'onglet Panier via la barre de navigation
    final panierTab = find.descendant(
      of: find.byType(LadafuraBottomNavBar),
      matching: find.byTooltip('Panier'),
    );
    await tester.tap(panierTab);
    await tester.pumpAndSettle();
    expect(find.text('Panier'), findsWidgets);
  });

  testWidgets(
      'AccueilScreen renders all public sections and quick access cards with AppTheme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const AccueilScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Vérifie les 4 catégories rapides conformes à la maquette
    expect(find.text('Pharmacopée'), findsWidgets);
    expect(find.text('Fura'), findsOneWidget);
    expect(find.text('Plante'), findsOneWidget);
    expect(find.text('Maladie'), findsOneWidget);

    // Vérifie les sections de découverte
    expect(find.text('Pharmacopée près de vous'), findsOneWidget);
    expect(find.text('Produits populaires'), findsOneWidget);
    expect(find.text('Plantes les plus consultées'), findsOneWidget);

    // Vérifie la section Agent de collecte
    expect(find.text('Vous êtes agent de collecte ?'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);

    // Test avec le thème sombre
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const AccueilScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pharmacopée'), findsWidgets);
    expect(find.text('Connexion'), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/main.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/media/app_logo.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/ladafura_bottom_nav_bar.dart';

void main() {
  testWidgets(
      'LadafuraApp smoke test - verifies initialization, logo, dark theme toggle and modern navbar',
      (WidgetTester tester) async {
    // Construction de l'arbre de widgets avec ProviderScope Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: LadafuraApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Vérifie que les logos SVG sont présents
    expect(find.byType(AppLogo), findsWidgets);

    // Vérifie le titre LADAFURA
    expect(find.text('LADAFURA'), findsWidgets);

    // Vérifie la présence de la barre de navigation moderne
    expect(find.byType(LadafuraBottomNavBar), findsOneWidget);
    expect(find.text('Recherche'), findsOneWidget);

    // Vérifie le badge du panier (2 articles par défaut)
    expect(find.text('2'), findsOneWidget);

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

    // Teste le clic sur l'onglet Recherche dans la barre de navigation
    await tester.tap(find.text('Recherche'));
    await tester.pumpAndSettle();
  });
}

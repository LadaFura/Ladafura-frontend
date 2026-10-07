import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/features/carte/presentation/pages/carte_screen.dart';
import 'package:ladafura_frontend_flutter/features/carte/presentation/widgets/carte_pharmacopee_detail_card.dart';
import 'package:ladafura_frontend_flutter/features/carte/providers/carte_provider.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/models/pharmacopee_model.dart';

void main() {
  testWidgets('CarteScreen renders search bar, filters and details card on selection', (tester) async {
    const samplePharma = PharmacopeeModel(
      id: 1,
      nom: 'Pharmacopée Agaba',
      region: 'Bamako',
      localite: 'Bamako, Mali',
      latitude: 12.6392,
      longitude: -8.0029,
      proposeLivraison: true,
      proposePickup: true,
      nombreProduits: 28,
      noteMoyenne: 4.7,
      nombreAvis: 124,
    );

    final router = GoRouter(
      initialLocation: '/citizen/carte',
      routes: [
        GoRoute(
          path: '/citizen/carte',
          builder: (context, state) => const CarteScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartePharmacopeesProvider.overrideWith((ref) => Future.value([samplePharma])),
          selectedCartePharmacopeeProvider.overrideWith((ref) => samplePharma),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Vérification de la barre de recherche
    expect(find.text('Rechercher une pharmacopée, maladie, produit...'), findsOneWidget);

    // Vérification des boutons de filtres
    expect(find.text('Filtres'), findsOneWidget);
    expect(find.text('Distance'), findsNothing);
    expect(find.text('Ouvert'), findsOneWidget);
    expect(find.text('Livraison'), findsNWidgets(2)); // Puce filtre + badge détail
    expect(find.text('Retrait sur place'), findsOneWidget);
    expect(find.text('Mieux notées'), findsOneWidget);

    // Vérification de la carte de détail
    expect(find.byType(CartePharmacopeeDetailCard), findsOneWidget);
    expect(find.text('Pharmacopée Agaba'), findsOneWidget);
    expect(find.text('28 produits disponibles'), findsOneWidget);
    expect(find.text('Voir la pharmacopée'), findsOneWidget);

    // Vérification de la présence du bouton de recentrage GPS
    expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
  });

  testWidgets('CarteScreen recenter button triggers location request', (tester) async {
    final router = GoRouter(
      initialLocation: '/visitor/carte',
      routes: [
        GoRoute(
          path: '/visitor/carte',
          builder: (context, state) => const CarteScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartePharmacopeesProvider.overrideWith((ref) => Future.value([])),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final recenterBtn = find.byIcon(Icons.my_location_rounded);
    expect(recenterBtn, findsOneWidget);
    await tester.tap(recenterBtn);
    await tester.pumpAndSettle();
  });
}


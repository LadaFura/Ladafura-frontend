import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/models/pharmacopee_model.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/providers/pharmacopee_provider.dart';
import 'package:ladafura_frontend_flutter/features/pharmacopees/services/pharmacopee_service.dart';
import 'package:ladafura_frontend_flutter/features/plantes/models/plante_model.dart';
import 'package:ladafura_frontend_flutter/features/plantes/providers/plante_provider.dart';
import 'package:ladafura_frontend_flutter/features/plantes/services/plante_service.dart';
import 'package:ladafura_frontend_flutter/features/recherche/presentation/pages/citizen_search_screen.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recent_searches_provider.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recherche_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePharmacopeeService extends PharmacopeeService {
  FakePharmacopeeService() : super(apiClient: ApiClient());

  @override
  Future<List<PharmacopeeModel>> getPharmacopees(
      {int page = 0, int size = 10}) async {
    return const [
      PharmacopeeModel(
        id: 1,
        nom: 'Pharmacie Jnane Awrad',
        description: 'Officine agréée spécialisée en phytothérapie.',
        telephone: '+223 76 12 34 56',
        region: 'Bamako',
        cercle: 'Bamako',
        commune: 'Commune V',
        localite: 'Badalabougou',
        latitude: 12.6280,
        longitude: -7.9950,
        noteMoyenne: 4.5,
        nombreAvis: 100,
      ),
    ];
  }
}

class FakePlanteService extends PlanteService {
  FakePlanteService() : super(apiClient: ApiClient());

  @override
  Future<List<PopulationPlanteDetailModel>> getPlantes(
      {int page = 0, int size = 10, String? query}) async {
    return const [
      PopulationPlanteDetailModel(
        id: 1,
        nomScientifique: 'Combretum micranthum',
        description: 'Arbuste sahélien réputé.',
        nomsVernaculaires: [
          PopulationNomVernaculaireModel(nom: 'Kinkéliba', langue: 'Bambara'),
        ],
      ),
    ];
  }
}

final baseOverrides = [
  maladiesSuggestionsProvider.overrideWith((ref) => Future.value(
        const [
          'Diabète',
          'Hypertension',
          'Fatigue',
          'Digestion',
          'Anémie',
          'Toux',
          'Paludisme',
        ],
      )),
  pharmacopeeServiceProvider.overrideWithValue(FakePharmacopeeService()),
  planteServiceProvider.overrideWithValue(FakePlanteService()),
];

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'recent_searches': ['Moringa', 'Pharmacopée dagaba', 'Diabète', 'Kinkeliba', 'Bissap'],
    });
    final prefs = await SharedPreferences.getInstance();
    StorageService.init(prefs);
  });

  group('CitizenSearchScreen Tests', () {
    testWidgets('Renders search bar and category chips with Pharmacopée priority',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides,
          child: const MaterialApp(
            home: CitizenSearchScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify input
      expect(
        find.text('Rechercher par une maladie, produit...'),
        findsOneWidget,
      );

      // Verify Category Chips: Tous, Pharmacopée, Plante
      expect(find.text('Tous'), findsWidgets);
      expect(find.text('Pharmacopée'), findsWidgets);
      expect(find.text('Plante'), findsWidgets);

      // Verify Recent Searches and Maladies in idle state
      expect(find.text('Vos recherches récentes'), findsOneWidget);
      expect(find.text('Moringa'), findsOneWidget);
      expect(find.text('Maladies les plus recherchées'), findsOneWidget);
      expect(find.text('Paludisme'), findsOneWidget);
    });

    testWidgets('Displays Pharmacopées before Plantes in search results',
        (tester) async {
      const sampleResponse = GlobalSearchResponse(
        query: 'kink',
        totalResultats: 4,
        pharmacopees: [
          PharmacopeeSearchItem(
            id: 1,
            nom: 'Pharmacie Mandé Santé',
            commune: 'Siby',
            region: 'Koulikoro',
            noteMoyenne: 4.8,
          ),
        ],
        plantes: [
          PlanteSearchItem(
            id: 1,
            nomScientifique: 'Combretum micranthum',
            nomsVernaculaires: ['Kinkéliba (Bambara)'],
          ),
        ],
        maladies: [
          MaladieSearchItem(
            id: 1,
            nom: 'Hypertension artérielle',
            nombrePlantesAssociees: 3,
          ),
        ],
        produits: [
          ProduitSearchItem(
            id: 1,
            nom: 'Tisane Kinkéliba Bio',
            prix: 1500,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...baseOverrides,
            rechercheProvider.overrideWith((ref) {
              final notifier = RechercheNotifier(ref);
              notifier.state = RechercheState.success('kink', sampleResponse);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: CitizenSearchScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify top section titles are present
      expect(find.text('Pharmacopées traditionnelles'), findsOneWidget);
      expect(find.text('Plantes Médicinales'), findsOneWidget);

      // Verify Pharmacopée item appears before Plante item in widget hierarchy (Top to bottom)
      final pharmacopeeFinder = find.text('Pharmacie Mandé Santé');
      final planteFinder = find.text('Combretum micranthum');

      expect(pharmacopeeFinder, findsOneWidget);
      expect(planteFinder, findsOneWidget);

      final pharmaY = tester.getTopLeft(pharmacopeeFinder).dy;
      final planteY = tester.getTopLeft(planteFinder).dy;

      // Pharmacopée MUST be rendered higher (smaller Y) than Plante
      expect(pharmaY, lessThan(planteY),
          reason: 'Pharmacopées must be prioritized and displayed above Plantes');
    });

    testWidgets('Dynamically removes a recent search chip on close tap',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides,
          child: const MaterialApp(
            home: CitizenSearchScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify 'Moringa' is present initially
      expect(find.text('Moringa'), findsOneWidget);

      // Tap on the close button for 'Moringa'
      final removeMoringa = find.byKey(const ValueKey('remove_Moringa'));
      expect(removeMoringa, findsOneWidget);

      await tester.tap(removeMoringa);
      await tester.pump();

      // Verify 'Moringa' is now dynamically removed
      expect(find.text('Moringa'), findsNothing);
    });

    testWidgets('Dynamically adds a search query to recent searches',
        (tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const CitizenSearchScreen();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Artemisia'), findsNothing);

      // Add 'Artemisia' to recent searches via provider
      await capturedRef
          .read(recentSearchesProvider.notifier)
          .addSearch('Artemisia');
      await tester.pump();

      // Check that Artemisia is now dynamically rendered in recent searches
      expect(find.text('Artemisia'), findsOneWidget);
    });

    testWidgets('Single character typing maintains focus and text without blocking',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides,
          child: const MaterialApp(
            home: CitizenSearchScreen(),
          ),
        ),
      );
      await tester.pump();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Saisie d'un seul caractère
      await tester.enterText(textField, 'M');
      await tester.pump();

      expect(find.text('M'), findsOneWidget);

      // Saisie continue d'un second caractère sans blocage
      await tester.enterText(textField, 'Mo');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Mo'), findsOneWidget);
    });

    testWidgets(
        'Tapping "Pharmacopée" category card displays nearest pharmacopées',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides,
          child: const MaterialApp(
            home: CitizenSearchScreen(),
          ),
        ),
      );
      await tester.pump();

      // Find the Pharmacopée category card (the one with the chevron)
      final pharmaCardFinder = find.widgetWithText(InkWell, 'Pharmacopée');
      expect(pharmaCardFinder, findsWidgets);

      // Tap on the Pharmacopée card
      await tester.tap(pharmaCardFinder.first);
      await tester.pumpAndSettle();

      // Verify Pharmacopées section is displayed
      expect(find.text('Pharmacopées traditionnelles'), findsOneWidget);
      expect(find.text('Pharmacie Jnane Awrad'), findsOneWidget);
    });

    testWidgets(
        'Tapping "Tous" category card displays both pharmacopées and plantes simultaneously',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides,
          child: const MaterialApp(
            home: CitizenSearchScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap on the "Tous" card
      final tousCardFinder = find.widgetWithText(InkWell, 'Tous');
      expect(tousCardFinder, findsWidgets);

      await tester.tap(tousCardFinder.first);
      await tester.pumpAndSettle();

      // Verify Pharmacopées section is displayed at top
      expect(find.text('Pharmacopées traditionnelles'), findsOneWidget);
      expect(find.text('Pharmacie Jnane Awrad'), findsOneWidget);

      // Scroll down to reveal Plantes section in the vertical ListView
      final verticalListView = find.byWidgetPredicate(
        (w) => w is ListView && w.scrollDirection == Axis.vertical,
      );
      await tester.dragUntilVisible(
        find.text('Plantes Médicinales'),
        verticalListView,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Plantes Médicinales'), findsOneWidget);
      expect(find.text('Combretum micranthum'), findsOneWidget);
    });
  });
}

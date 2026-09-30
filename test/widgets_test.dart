import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/shared/enums/statut_collecte.dart';
import 'package:ladafura_frontend_flutter/shared/models/plante_sommaire_model.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/widgets.dart';

void main() {
  group('Shared Widgets - Buttons', () {
    testWidgets(
        'PrimaryButton displays label, responds to tap, and handles loading state',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Valider',
              onPressed: () => tapped = true,
              icon: Icons.check,
            ),
          ),
        ),
      );

      expect(find.text('Valider'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Valider'));
      expect(tapped, isTrue);

      // Test loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Valider',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Valider'), findsNothing);
    });

    testWidgets('SecondaryButton renders with border and responds to tap',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              label: 'Annuler',
              onPressed: () => tapped = true,
              icon: Icons.close,
            ),
          ),
        ),
      );

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.text('Annuler'));
      expect(tapped, isTrue);
    });
  });

  group('Shared Widgets - Inputs', () {
    testWidgets(
        'CustomTextField handles text, label, and password obscuring toggle',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Mot de passe',
              hintText: 'Entrez votre mot de passe',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Entrez votre mot de passe'), findsOneWidget);

      // Enters text
      await tester.enterText(find.byType(TextFormField), 'Secret123');
      expect(controller.text, 'Secret123');

      // Check toggle password visibility
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets(
        'SearchBarWidget invokes onChanged, onSubmitted, and onFilterTap',
        (tester) async {
      String changedText = '';
      bool searchSubmitted = false;
      bool filterTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              hintText: 'Rechercher une plante...',
              showFilterButton: true,
              onChanged: (val) => changedText = val,
              onSubmitted: (val) => searchSubmitted = true,
              onFilterTap: () => filterTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Rechercher une plante...'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Type text
      await tester.enterText(find.byType(TextField), 'Kinkeliba');
      expect(changedText, 'Kinkeliba');

      // Submit search
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(searchSubmitted, isTrue);

      // Tap filter icon
      await tester.tap(find.byIcon(Icons.tune));
      expect(filterTapped, isTrue);

      // Clear button tap
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.text('Kinkeliba'), findsNothing);
    });
  });

  group('Shared Widgets - Cards & Badges', () {
    testWidgets(
        'StatusBadge renders for Collecte and ENF11 cert levels',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.collecte(StatutCollecte.validee),
                const StatusBadge.traditionnel(),
                const StatusBadge.scientifique(),
                const StatusBadge.institutionnel(),
                const StatusBadge.enVerification(),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Validée'), findsWidgets);
      expect(find.text('Usage traditionnel rapporté'), findsOneWidget);
      expect(find.text('Étude scientifique disponible'), findsOneWidget);
      expect(find.text('Information institutionnelle'), findsOneWidget);
      expect(find.text('En cours de vérification'), findsOneWidget);
    });

    testWidgets('PlanteCard renders details and reacts to tap', (tester) async {
      bool tapped = false;
      const plante = PlanteSommaireModel(
        id: 1,
        nomScientifique: 'Combretum micranthum',
        nomsVernaculaires: ['Kinkeliba'],
        nombreEtudesScientifiques: 1,
        nombreConnaissances: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlanteCard(
              plante: plante,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Kinkeliba'), findsOneWidget);
      expect(find.text('Combretum micranthum'), findsOneWidget);
      expect(find.text('1 savoirs'), findsOneWidget);
      expect(find.text('1 études'), findsOneWidget);

      await tester.tap(find.text('Kinkeliba'));
      expect(tapped, isTrue);
    });
  });

  group('Shared Widgets - Feedback & Media', () {
    testWidgets('MedicalDisclaimerBanner displays mandatory ENF11 legal notice',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MedicalDisclaimerBanner(),
                MedicalDisclaimerBanner(compact: true),
              ],
            ),
          ),
        ),
      );

      expect(
        find.textContaining('Avertissement Médical Officiel'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Usage informatif'),
        findsWidgets,
      );
      expect(find.byIcon(Icons.health_and_safety_outlined), findsWidgets);
    });

    testWidgets('AppLoadingIndicator renders spinner and informative message',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingIndicator(
              message: 'Chargement des remèdes...',
            ),
          ),
        ),
      );

      expect(find.text('Chargement des remèdes...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppEmptyState displays empty icon and action button',
        (tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Aucune plante trouvée',
              message: 'Essayez avec un autre nom vernaculaire.',
              actionLabel: 'Réinitialiser',
              onAction: () => actionClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Aucune plante trouvée'), findsOneWidget);
      expect(
          find.text('Essayez avec un autre nom vernaculaire.'), findsOneWidget);
      expect(find.text('Réinitialiser'), findsOneWidget);

      await tester.tap(find.text('Réinitialiser'));
      expect(actionClicked, isTrue);
    });

    testWidgets('AppErrorWidget renders error message and retry button',
        (tester) async {
      bool retryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Connexion réseau instable à Bamako',
              onRetry: () => retryClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Connexion réseau instable à Bamako'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);

      await tester.tap(find.text('Réessayer'));
      expect(retryClicked, isTrue);
    });

    testWidgets(
        'AudioPlayerWidget renders playback controls and toggles playing state',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioPlayerWidget(
              title: 'Récit du guérisseur de Sikasso',
              totalDuration: Duration(minutes: 2, seconds: 30),
            ),
          ),
        ),
      );

      expect(find.text('Récit du guérisseur de Sikasso'), findsOneWidget);
      expect(find.textContaining('02:30'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Tap Play
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Tap Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });
}

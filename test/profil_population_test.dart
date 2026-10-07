import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/features/profil/models/profil_model.dart';
import 'package:ladafura_frontend_flutter/features/profil/presentation/widgets/modifier_profil_form.dart';
import 'package:ladafura_frontend_flutter/features/profil/presentation/widgets/profil_activite_section.dart';
import 'package:ladafura_frontend_flutter/features/profil/presentation/widgets/profil_header.dart';
import 'package:ladafura_frontend_flutter/features/profil/presentation/widgets/profil_info_section.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';

void main() {
  const mockProfil = ProfilModel(
    id: 1,
    nom: 'Diarra',
    prenom: 'Fatoumata',
    email: 'fatoumata.diarra@gmail.com',
    telephone: '+223 70 12 34 56',
    role: UserRole.population,
    statut: 'ACTIF',
    nombreTotalCommandes: 4,
    nombreTotalFavoris: 7,
  );

  group('ProfilModel Tests', () {
    test('JSON serialization & getters', () {
      expect(mockProfil.nomComplet, 'Fatoumata Diarra');
      expect(mockProfil.initiales, 'FD');
      expect(mockProfil.nombreTotalCommandes, 4);
      expect(mockProfil.nombreTotalFavoris, 7);

      final json = mockProfil.toJson();
      final fromJson = ProfilModel.fromJson(json);
      expect(fromJson.nom, 'Diarra');
      expect(fromJson.prenom, 'Fatoumata');
      expect(fromJson.email, 'fatoumata.diarra@gmail.com');
      expect(fromJson.telephone, '+223 70 12 34 56');
      expect(fromJson.nombreTotalCommandes, 4);
      expect(fromJson.nombreTotalFavoris, 7);
    });
  });

  group('Profil Widgets Tests', () {
    testWidgets('ProfilHeader displays generic icon and user identity',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfilHeader(profil: mockProfil),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.text('Fatoumata Diarra'), findsOneWidget);
      expect(find.text('fatoumata.diarra@gmail.com'), findsOneWidget);
      expect(find.text('Population'), findsOneWidget);
      expect(find.text('Actif'), findsOneWidget);
    });

    testWidgets('ProfilInfoSection displays complete coordinates and edit action',
        (tester) async {
      bool editTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfilInfoSection(
                profil: mockProfil,
                onModifier: () => editTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mes informations'), findsOneWidget);
      expect(find.text('Diarra'), findsOneWidget);
      expect(find.text('Fatoumata'), findsOneWidget);
      expect(find.text('+223 70 12 34 56'), findsOneWidget);
      expect(find.text('fatoumata.diarra@gmail.com'), findsOneWidget);

      await tester.tap(find.text('Modifier mon profil'));
      expect(editTapped, isTrue);
    });

    testWidgets('ProfilActiviteSection displays activity counters for orders and favorites',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfilActiviteSection(
                totalCommandes: 4,
                totalFavoris: 7,
                unreadNotifications: 2,
                onTapCommandes: () {},
                onTapFavoris: () {},
                onTapNotifications: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mes commandes'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Mes favoris'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('ModifierProfilForm pre-fills and validates fields',
        (tester) async {
      String? submittedNom;
      String? submittedPrenom;
      String? submittedPhone;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ModifierProfilForm(
                profil: mockProfil,
                isSubmitting: false,
                onSubmit: ({required nom, required prenom, telephone}) async {
                  submittedNom = nom;
                  submittedPrenom = prenom;
                  submittedPhone = telephone;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.widgetWithText(TextFormField, 'Diarra'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Fatoumata'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '+223 70 12 34 56'), findsOneWidget);

      // Modifier le nom
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Diarra'), 'Traoré');
      await tester.tap(find.text('Enregistrer les modifications'));
      await tester.pump();

      expect(submittedNom, 'Traoré');
      expect(submittedPrenom, 'Fatoumata');
      expect(submittedPhone, '+223 70 12 34 56');
    });
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/features/commandes/presentation/widgets/commande_livraison_form.dart';

void main() {
  testWidgets('CommandeLivraisonForm displays auto/manual buttons and validates phone',
      (WidgetTester tester) async {
    final adresseCtrl = TextEditingController();
    final telephoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CommandeLivraisonForm(
                adresseController: adresseCtrl,
                telephoneController: telephoneCtrl,
                notesController: notesCtrl,
              ),
            ),
          ),
        ),
      ),
    );

    // Vérifier la présence des boutons Automatique et Manuel
    expect(find.text('Prendre auto (GPS)'), findsOneWidget);
    expect(find.text('Saisie manuelle'), findsOneWidget);

    // Vérifier la présence du libellé pour le téléphone obligatoire
    expect(find.text('Numéro de téléphone de contact *'), findsOneWidget);
    expect(find.text('Obligatoire'), findsOneWidget);

    // Tester la saisie dans le téléphone
    await tester.enterText(
        find.widgetWithText(TextField, 'Téléphone du destinataire *'),
        '+223 70 12 34 56');
    expect(telephoneCtrl.text, '+223 70 12 34 56');

    // Tester le bouton Saisie manuelle
    await tester.tap(find.text('Saisie manuelle'));
    await tester.pumpAndSettle();

    // Tester la saisie de l'adresse manuelle
    await tester.enterText(
        find.widgetWithText(TextField, 'Adresse complète de livraison *'),
        'Badalabougou Rue 12 Porte 4');
    expect(adresseCtrl.text, 'Badalabougou Rue 12 Porte 4');
  });
}


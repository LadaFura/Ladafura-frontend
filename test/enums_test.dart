import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/shared/enums/enums.dart';

void main() {
  group('Shared Enums Tests - LADAFURA', () {
    // =========================================================================
    // 1. USER ROLE TESTS
    // =========================================================================
    test('UserRole matches backend Spring Boot roles and handles mobile actors',
        () {
      expect(UserRole.population.value, 'POPULATION');
      expect(UserRole.agentCollecte.value, 'AGENT_COLLECTE');
      expect(UserRole.pharmacopee.value, 'PHARMACOPEE');
      expect(UserRole.administrateur.value, 'ADMINISTRATEUR');

      expect(UserRole.population.isMobileActor, isTrue);
      expect(UserRole.agentCollecte.isMobileActor, isTrue);
      expect(UserRole.pharmacopee.isMobileActor, isTrue);
      expect(UserRole.administrateur.isMobileActor, isFalse);

      expect(UserRole.fromString('population'), UserRole.population);
      expect(UserRole.fromString('AGENT_COLLECTE'), UserRole.agentCollecte);
      expect(UserRole.fromString('pharmacopee'), UserRole.pharmacopee);
      expect(UserRole.fromString('invalide'), isNull);
    });

    // =========================================================================
    // 2. STATUT COLLECTE TESTS
    // =========================================================================
    test(
        'StatutCollecte matches backend values, badge colors, and canEdit flags',
        () {
      expect(StatutCollecte.brouillon.value, 'BROUILLON');
      expect(StatutCollecte.soumise.value, 'SOUMISE');
      expect(StatutCollecte.enExamen.value, 'EN_EXAMEN');
      expect(StatutCollecte.validee.value, 'VALIDEE');
      expect(StatutCollecte.rejetee.value, 'REJETEE');
      expect(StatutCollecte.correctionDemandee.value, 'CORRECTION_DEMANDEE');

      // Badges
      expect(StatutCollecte.validee.badgeColor, AppColors.success);
      expect(StatutCollecte.rejetee.badgeColor, AppColors.danger);
      expect(StatutCollecte.correctionDemandee.badgeColor, AppColors.warning);

      // Éditabilité
      expect(StatutCollecte.brouillon.canEdit, isTrue);
      expect(StatutCollecte.correctionDemandee.canEdit, isTrue);
      expect(StatutCollecte.validee.canEdit, isFalse);
      expect(StatutCollecte.soumise.canEdit, isFalse);

      // Parsers & alias
      expect(StatutCollecte.fromString('SOUMISE'), StatutCollecte.soumise);
      expect(StatutCollecte.fromString('A_CORRIGER'),
          StatutCollecte.correctionDemandee);
      expect(StatutCollecte.fromString('CORRECTION_DEMANDEE'),
          StatutCollecte.correctionDemandee);
    });

    // =========================================================================
    // 3. STATUT COMMANDE TESTS
    // =========================================================================
    test('StatutCommande handles progress, completion and aliases', () {
      expect(StatutCommande.enAttente.value, 'EN_ATTENTE');
      expect(StatutCommande.confirmee.value, 'CONFIRMEE');
      expect(StatutCommande.preparee.value, 'PREPAREE');
      expect(StatutCommande.enLivraison.value, 'EN_LIVRAISON');
      expect(StatutCommande.disponiblePickup.value, 'DISPONIBLE_PICKUP');
      expect(StatutCommande.livree.value, 'LIVREE');
      expect(StatutCommande.retiree.value, 'RETIREE');
      expect(StatutCommande.annulee.value, 'ANNULEE');

      // Progression vs Complété
      expect(StatutCommande.enAttente.isInProgress, isTrue);
      expect(StatutCommande.enLivraison.isInProgress, isTrue);
      expect(StatutCommande.livree.isCompleted, isTrue);
      expect(StatutCommande.retiree.isCompleted, isTrue);
      expect(StatutCommande.annulee.isCompleted, isTrue);

      // Aliases
      expect(StatutCommande.fromString('VALIDEE'), StatutCommande.confirmee);
      expect(StatutCommande.fromString('EXPEDIEE'), StatutCommande.enLivraison);
      expect(StatutCommande.fromString('DISPONIBLE_PICKUP'),
          StatutCommande.disponiblePickup);
    });

    // =========================================================================
    // 4. METHODE PAIEMENT TESTS
    // =========================================================================
    test('MethodePaiement handles Mali mobile money and cash', () {
      expect(MethodePaiement.mobileMoney.value, 'MOBILE_MONEY');
      expect(MethodePaiement.cash.value, 'CASH');
      expect(MethodePaiement.carteBancaire.value, 'CARTE_BANCAIRE');

      expect(MethodePaiement.mobileMoney.isDigital, isTrue);
      expect(MethodePaiement.cash.isDigital, isFalse);

      expect(MethodePaiement.fromString('MOBILE_MONEY'),
          MethodePaiement.mobileMoney);
      expect(MethodePaiement.fromString('ESPECES'), MethodePaiement.cash);
      expect(MethodePaiement.fromString('CASH'), MethodePaiement.cash);
    });

    // =========================================================================
    // 5. MODE RETRAIT TYPE TESTS
    // =========================================================================
    test('ModeRetraitType handles Pickup and Livraison with delivery fee flag',
        () {
      expect(ModeRetraitType.pickup.value, 'PICKUP');
      expect(ModeRetraitType.livraison.value, 'LIVRAISON');

      expect(ModeRetraitType.pickup.hasDeliveryFee, isFalse);
      expect(ModeRetraitType.livraison.hasDeliveryFee, isTrue);

      expect(ModeRetraitType.fromString('PICKUP'), ModeRetraitType.pickup);
      expect(ModeRetraitType.fromString('RETRAIT_OFFICINE'),
          ModeRetraitType.pickup);
      expect(ModeRetraitType.fromString('RETRAIT'), ModeRetraitType.pickup);
      expect(ModeRetraitType.fromString('LIVRAISON_DOMICILE'),
          ModeRetraitType.livraison);
      expect(
          ModeRetraitType.fromString('LIVRAISON'), ModeRetraitType.livraison);
    });
  });
}

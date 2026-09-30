import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/shared/enums/enums.dart';

void main() {
  group('Shared Enums Tests - LADAFURA (Périmètre 2 Rôles)', () {
    // =========================================================================
    // 1. USER ROLE TESTS (POPULATION & AGENT DE COLLECTE)
    // =========================================================================
    test('UserRole matches the 2 mobile roles: POPULATION and AGENT_COLLECTE',
        () {
      expect(UserRole.values.length, 2);
      expect(UserRole.population.value, 'POPULATION');
      expect(UserRole.agentCollecte.value, 'AGENT_COLLECTE');

      expect(UserRole.population.isMobileActor, isTrue);
      expect(UserRole.agentCollecte.isMobileActor, isTrue);

      expect(UserRole.fromString('population'), UserRole.population);
      expect(UserRole.fromString('AGENT_COLLECTE'), UserRole.agentCollecte);
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
  });
}

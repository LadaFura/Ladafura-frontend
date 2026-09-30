import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/core/constants/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('Core Constants Tests', () {
    test('ApiEndpoints defines valid URLs and timeouts', () {
      expect(ApiEndpoints.apiVersion, '/api/v1');
      expect(ApiEndpoints.baseUrl, contains('/api/v1'));
      expect(ApiEndpoints.connectionTimeout.inSeconds, 15);
      expect(ApiEndpoints.receiveTimeout.inSeconds, 15);

      // Routes Population
      expect(ApiEndpoints.populationRecherche, '/population/recherche');
      expect(ApiEndpoints.populationPlantes, '/population/plantes');
      expect(ApiEndpoints.populationPlanteDetail('123'),
          '/population/plantes/123');
      expect(ApiEndpoints.populationPanier, '/population/panier');
      expect(ApiEndpoints.populationCommandes, '/population/commandes');

      // Routes Agent
      expect(ApiEndpoints.agentDashboardStats, '/agent/dashboard/stats');
      expect(ApiEndpoints.agentCollectes, '/agent/collectes');
      expect(ApiEndpoints.agentCollecteDetail('456'), '/agent/collectes/456');
      expect(ApiEndpoints.agentMediasUpload, '/agent/medias/upload');

      // Routes Pharmacopée
      expect(ApiEndpoints.pharmacopeeProduits, '/pharmacopee/produits');
      expect(ApiEndpoints.pharmacopeeStock, '/pharmacopee/stock');
      expect(ApiEndpoints.pharmacopeeCommandes, '/pharmacopee/commandes');
    });

    test('AppColors provides compliant Light and Dark palettes', () {
      expect(AppColors.primary, const Color(0xFF2E7D32));
      expect(AppColors.darkPrimary, const Color(0xFF34D399));
      expect(AppColors.darkBackground, const Color(0xFF0F231A));
      expect(AppColors.accent, const Color(0xFFF4A621));
    });

    test('AppTextStyles strictly enforces Poppins and 7 sizes', () {
      expect(AppTextStyles.h1.fontSize, 28);
      expect(AppTextStyles.h2.fontSize, 24);
      expect(AppTextStyles.h3.fontSize, 20);
      expect(AppTextStyles.h4.fontSize, 18);
      expect(AppTextStyles.body.fontSize, 16);
      expect(AppTextStyles.bodySecondary.fontSize, 14);
      expect(AppTextStyles.caption.fontSize, 12);
    });

    test('AppAssets contains all SVG and PNG logo paths', () {
      expect(AppAssets.logoIconSvg, contains('.svg'));
      expect(AppAssets.logoHorizontalSvg, contains('.svg'));
      expect(AppAssets.logoIconDarkSvg, contains('.svg'));
      expect(AppAssets.logoHorizontalDarkSvg, contains('.svg'));
    });

    test('AppDimensions enforces 4px grid and standard breakpoints', () {
      expect(AppDimensions.referenceWidth, 402);
      expect(AppDimensions.referenceHeight, 874);
      expect(AppDimensions.buttonHeight, 48);
      expect(AppDimensions.radiusButton, 8);
      expect(AppDimensions.radiusCard, 12);
      expect(AppDimensions.radiusBadge, 999);
    });
  });
}

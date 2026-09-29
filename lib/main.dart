import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_dimensions.dart';
import 'core/constants/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'shared/widgets/buttons/primary_button.dart';
import 'shared/widgets/buttons/secondary_button.dart';
import 'shared/widgets/cards/status_badge.dart';
import 'shared/widgets/feedback/medical_disclaimer_banner.dart';
import 'shared/widgets/inputs/custom_text_field.dart';
import 'shared/widgets/media/app_logo.dart';
import 'shared/widgets/navigation/ladafura_bottom_nav_bar.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LadafuraApp(),
    ),
  );
}

/// Application racine LADAFURA avec support complet Thème Clair & Sombre
class LadafuraApp extends ConsumerWidget {
  const LadafuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'LADAFURA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const LadafuraHomeScreen(),
    );
  }
}

/// Écran d'accueil et vitrine du Design System LADAFURA
class LadafuraHomeScreen extends ConsumerStatefulWidget {
  const LadafuraHomeScreen({super.key});

  @override
  ConsumerState<LadafuraHomeScreen> createState() => _LadafuraHomeScreenState();
}

class _LadafuraHomeScreenState extends ConsumerState<LadafuraHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 0;
  final int _cartCount = 2; // Exemple avec 2 remèdes dans le panier

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: LadafuraBottomNavBar(
        currentIndex: _currentNavIndex,
        cartBadgeCount: _cartCount,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
      appBar: AppBar(
        title: const AppLogo.horizontal(height: 32),
        centerTitle: false,
        actions: [
          // Bouton bascule Thème Clair / Sombre
          IconButton(
            tooltip: isDark ? 'Passer en mode clair' : 'Passer en mode sombre',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: isDark ? AppColors.darkAccent : AppColors.primary,
            ),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .toggleTheme(currentIsDark: isDark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.paddingScreenWithNavBar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bannière de conformité légale ENF11
              const MedicalDisclaimerBanner(),
              const SizedBox(height: AppDimensions.space20),

              // Carte de bienvenue avec logo SVG icône
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            AppColors.darkSurfaceVariant,
                            AppColors.darkPrimaryContainer,
                          ]
                        : const [
                            AppColors.primaryDark,
                            AppColors.primary,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: isDark
                      ? Border.all(color: AppColors.darkBorder, width: 1.0)
                      : null,
                ),
                child: Row(
                  children: [
                    const AppLogo.icon(size: 64),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LADAFURA',
                            style: (isDark
                                    ? AppTextStyles.h2Dark
                                    : AppTextStyles.h2)
                                .copyWith(
                              color:
                                  isDark ? AppColors.darkPrimary : Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space4),
                          Text(
                            'Pharmacopée & Médecine Traditionnelle du Mali (INRMPT)',
                            style: (isDark
                                    ? AppTextStyles.captionDark
                                    : AppTextStyles.caption)
                                .copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Champ de recherche rapide
              Text(
                'Rechercher une plante ou un remède',
                style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
              ),
              const SizedBox(height: AppDimensions.space8),
              CustomTextField(
                controller: _searchController,
                hintText: 'Ex: Kinkeliba, N\'Golo, Paludisme...',
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Badges de certification (Règle ENF11)
              Text(
                'Niveaux de certification',
                style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
              ),
              const SizedBox(height: AppDimensions.space12),
              const Wrap(
                spacing: AppDimensions.space8,
                runSpacing: AppDimensions.space8,
                children: [
                  StatusBadge.traditionnel(),
                  StatusBadge.scientifique(),
                  StatusBadge.institutionnel(),
                  StatusBadge.enVerification(),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),

              // Actions & Rôles mobiles (Population, Agent, Pharmacopée)
              Text(
                'Espaces mobiles dédiés',
                style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
              ),
              const SizedBox(height: AppDimensions.space12),
              PrimaryButton(
                label: 'Explorer le Catalogue (Citoyen)',
                icon: Icon(
                  Icons.eco_outlined,
                  color: isDark ? AppColors.darkBackground : Colors.white,
                ),
                onPressed: () {},
                backgroundColor: AppColors.danger,
                textColor: Colors.white,
              ),
              const SizedBox(height: AppDimensions.space12),
              PrimaryButton(
                label: 'Explorer le Catalogue (Citoyen)',
                icon: Icon(
                  Icons.eco_outlined,
                  color: isDark ? AppColors.darkBackground : Colors.white,
                ),
                onPressed: () {},
              ),
              const SizedBox(height: AppDimensions.space12),
              SecondaryButton(
                label: 'Collecte Terrain (Agent)',
                icon: const Icon(Icons.edit_location_alt_outlined),
                onPressed: () {},
              ),
              const SizedBox(height: AppDimensions.space12),
              SecondaryButton(
                label: 'Gestion Officine (Pharmacopée)',
                icon: const Icon(Icons.storefront_outlined),
                onPressed: () {},
                borderColor: AppColors.danger,
                backgroundColor: const Color.fromARGB(255, 238, 225, 225),
                textColor: AppColors.danger,
              ),
              const SizedBox(height: AppDimensions.space24),

              // Mention de standard typographique & thème actif
              Center(
                child: Text(
                  'Typographie 100% Poppins • Rendu vectoriel SVG • Thème : ${isDark ? "Sombre (Nuit)" : "Clair (Jour)"}',
                  style: (isDark
                          ? AppTextStyles.captionDark
                          : AppTextStyles.caption)
                      .copyWith(
                    color:
                        isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

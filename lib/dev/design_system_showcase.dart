import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/buttons/primary_button.dart';
import '../../shared/widgets/buttons/secondary_button.dart';
import '../../shared/widgets/cards/status_badge.dart';
import '../../shared/widgets/feedback/medical_disclaimer_banner.dart';
import '../../shared/widgets/inputs/custom_text_field.dart';
import '../../shared/widgets/media/app_logo.dart';
import '../../shared/widgets/navigation/ladafura_bottom_nav_bar.dart';

/// Vitrine du Design System LADAFURA pour le développement et la validation des composants visuels.
class DesignSystemShowcaseScreen extends ConsumerStatefulWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  ConsumerState<DesignSystemShowcaseScreen> createState() =>
      _DesignSystemShowcaseScreenState();
}

class _DesignSystemShowcaseScreenState
    extends ConsumerState<DesignSystemShowcaseScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Accueil';
      case 1:
        return 'Recherche';
      case 2:
        return 'Carte';
      case 3:
        return 'Panier';
      case 4:
        return 'Profil';
      default:
        return 'Accueil';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentNavIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const LadafuraBottomNavBar(),
      appBar: AppBar(
        title: const AppLogo.horizontal(height: 32),
        centerTitle: false,
        actions: [
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.paddingScreenWithNavBar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MedicalDisclaimerBanner(),
              const SizedBox(height: AppDimensions.space20),
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
                            'Pharmacopée & Médecine Traditionnelle du Mali',
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
              Text(
                'Espaces mobiles dédiés',
                style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
              ),
              const SizedBox(height: AppDimensions.space12),
              PrimaryButton(
                label: 'Explorer la Flore Médicinale (Citoyen)',
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
              const SizedBox(height: AppDimensions.space24),
              Center(
                child: Text(
                  'Typographie 100% Poppins • Thème : ${isDark ? "Sombre" : "Clair"} • Onglet actif : ${_getTabName(currentNavIndex)}',
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

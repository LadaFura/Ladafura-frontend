import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/core/theme/theme_provider.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/secondary_button.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/media/app_logo.dart';

/// Page d'accueil publique officielle de LADAFURA (Mode Visiteur & Découverte).
class AccueilScreen extends ConsumerStatefulWidget {
  const AccueilScreen({super.key});

  @override
  ConsumerState<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends ConsumerState<AccueilScreen> {
  final PageController _carouselController = PageController();
  int _currentCarouselIndex = 0;

  final List<_CarouselSlideData> _slides = const [
    _CarouselSlideData(
      tag: 'Patrimoine Médicinal',
      title: 'Découvrez les connaissances de la pharmacopée malienne',
      description:
          'Consultez les informations disponibles sur les plantes, les maladies et les produits de la pharmacopée malienne.',
      gradientColors: [AppColors.primaryDark, AppColors.primary],
      icon: Icons.eco_rounded,
    ),
    _CarouselSlideData(
      tag: 'Savoirs Ancestraux',
      title: 'Plantes Médicinales & Traitements',
      description:
          'Explorez les remèdes traditionnels transmis de génération en génération au Mali pour préserver notre patrimoine médical.',
      gradientColors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      icon: Icons.spa_rounded,
    ),
    _CarouselSlideData(
      tag: 'Documentation Terrain',
      title: 'Collecte Botanique & Préservation',
      description:
          'Centralisation et sauvegarde des recettes et pratiques de nos tradithérapeutes à travers toutes les régions du Mali.',
      gradientColors: [Color(0xFF0D5C3A), Color(0xFF198754)],
      icon: Icons.menu_book_rounded,
    ),
  ];

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const AppLogo.horizontal(height: 32),
        centerTitle: false,
        actions: [
          // Bascule de thème Clair / Sombre
          IconButton(
            tooltip: isDark ? 'Mode clair' : 'Mode sombre',
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
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.paddingScreenWithNavBar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Carrousel de découverte (remplace la carte statique, sans logo)
              _buildCarouselSection(isDark),
              const SizedBox(height: AppDimensions.space24),

              // 2. Section Accès Rapides (Plantes, Maladies, Produits, Recherche)
              _buildQuickAccessSection(isDark),
              const SizedBox(height: AppDimensions.space24),

              // 3. Section Agent de Collecte Terrain
              _buildAgentSection(isDark),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  /// Carrousel interactif avec diapositives thématiques et indicateurs de pagination
  Widget _buildCarouselSection(bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _carouselController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            AppColors.darkSurfaceVariant,
                            AppColors.darkPrimaryContainer,
                          ]
                        : slide.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: isDark
                      ? Border.all(color: AppColors.darkBorder, width: 1.0)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark ? Colors.black : slide.gradientColors.first)
                              .withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge du thème de la slide
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space12,
                            vertical: AppDimensions.space4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusBadge),
                          ),
                          child: Text(
                            slide.tag.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color:
                                  isDark ? AppColors.darkPrimary : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Icon(
                          slide.icon,
                          color: Colors.white.withValues(alpha: 0.35),
                          size: 26,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    // Titre
                    Text(
                      slide.title,
                      style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3)
                          .copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    // Description
                    Text(
                      slide.description,
                      style:
                          (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                              .copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.space12),

        // Indicateurs de pagination (dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentCarouselIndex == index ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentCarouselIndex == index
                    ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                    : (isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Accès rapides vers les sections principales
  Widget _buildQuickAccessSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explorer par catégorie',
          style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
        ),
        const SizedBox(height: AppDimensions.space12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppDimensions.space12,
          crossAxisSpacing: AppDimensions.space12,
          childAspectRatio: 1.45,
          children: [
            _buildAccessCard(
              title: 'Plantes',
              description: 'Flore médicinale malienne',
              icon: Icons.eco_rounded,
              iconColor: AppColors.primary,
              isDark: isDark,
              onTap: () => context.go(RouteNames.visitorRecherchePath),
            ),
            _buildAccessCard(
              title: 'Maladies',
              description: 'Traitements traditionnels',
              icon: Icons.healing_rounded,
              iconColor: AppColors.accent,
              isDark: isDark,
              onTap: () => context.go(RouteNames.visitorRecherchePath),
            ),
            _buildAccessCard(
              title: 'Produits',
              description: 'Remèdes & formulations',
              icon: Icons.medication_liquid_rounded,
              iconColor: AppColors.primaryDark,
              isDark: isDark,
              onTap: () => context.go(RouteNames.visitorRecherchePath),
            ),
            _buildAccessCard(
              title: 'Recherche',
              description: 'Recherche avancée',
              icon: Icons.manage_search_rounded,
              iconColor: AppColors.darkAccent,
              isDark: isDark,
              onTap: () => context.go(RouteNames.visitorRecherchePath),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Ink(
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                title,
                style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                    .copyWith(fontSize: 15),
              ),
              Text(
                description,
                style:
                    (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                        .copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section dédiée à l'Agent de Collecte
  Widget _buildAgentSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.badgeInstitutionnelBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.badgeInstitutionnelText.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_ind_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Text(
                  'Vous êtes agent de collecte ?',
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            'Accédez à votre espace pour documenter les informations recueillies sur le terrain (géolocalisation GPS, enregistrements oraux, spécimens botaniques).',
            style:
                (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          SecondaryButton(
            label: 'Se connecter à l\'espace Agent',
            icon: const Icon(Icons.login_rounded),
            onPressed: () => context.go(RouteNames.loginPath),
          ),
        ],
      ),
    );
  }
}

class _CarouselSlideData {
  final String tag;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final IconData icon;

  const _CarouselSlideData({
    required this.tag,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.icon,
  });
}

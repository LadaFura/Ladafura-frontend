import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/primary_button.dart';

/// Écran d'accueil et d'introduction aux missions de LADAFURA et de l'INRMPT.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      icon: Icons.eco_outlined,
      title: 'Patrimoine Médicinal Malien',
      description:
          'Explorez le répertoire officiel des plantes médicinales du Mali validées scientifiquement par l\'INRMPT (Kinkéliba, N\'Golo, Zaban...).',
      accentColor: AppColors.primary,
    ),
    _OnboardingSlideData(
      icon: Icons.mic_none_outlined,
      title: 'Préservation des Savoirs Ancestraux',
      description:
          'Écoutez les récits oraux authentiques de nos tradithérapeutes et découvrez les usages traditionnels transmis de génération en génération.',
      accentColor: AppColors.accent,
    ),
    _OnboardingSlideData(
      icon: Icons.storefront_outlined,
      title: 'Officines Agréées & Commandes',
      description:
          'Localisez les pharmacies et pharmacopées traditionnelles certifiées, commandez vos remèdes et payez facilement via Orange Money ou Wave.',
      accentColor: AppColors.info,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go(RouteNames.roleSelectionPath);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Passer',
                style: AppTextStyles.button.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: slide.accentColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: slide.accentColor,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space32),
                        Text(
                          slide.title,
                          style:
                              isDark ? AppTextStyles.h2Dark : AppTextStyles.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Text(
                          slide.description,
                          style: (isDark
                                  ? AppTextStyles.bodyDark
                                  : AppTextStyles.body)
                              .copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indicateurs de page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space32),

              // Bouton Suivant / Commencer
              PrimaryButton(
                label: isLastPage ? 'Découvrir LADAFURA' : 'Suivant',
                icon: isLastPage ? Icons.arrow_forward : null,
                onPressed: () {
                  if (isLastPage) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}

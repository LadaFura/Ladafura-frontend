import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/media/app_logo.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/feedback/app_loading_indicator.dart';
import '../../providers/auth_state_provider.dart';

/// Écran de démarrage (Splash Screen) contrôlant la session et orientant l'utilisateur.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    // Petit délai d'affichage pour la fluidité visuelle
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final storage = ref.read(storageServiceProvider);
    final authState = ref.read(authStateProvider);

    if (authState.isAuthenticated) {
      // Déjà connecté, GoRouter gère la redirection automatique selon le rôle
      return;
    }

    final hasCompletedOnboarding = storage.hasCompletedOnboarding();
    if (!hasCompletedOnboarding) {
      context.go(RouteNames.onboardingPath);
    } else {
      context.go(RouteNames.visitorHomePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'ladafura-logo',
                child: AppLogo.icon(
                  size: 96,
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Text(
                'LADAFURA',
                style:
                    (isDark ? AppTextStyles.h1Dark : AppTextStyles.h1).copyWith(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Pharmacopée Traditionnelle & Valorisation Scientifique',
                style: (isDark
                        ? AppTextStyles.bodySecondaryDark
                        : AppTextStyles.bodySecondary)
                    .copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space32),
              const AppLoadingIndicator(
                  message: 'Initialisation de l\'application...'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/utils/validators.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/primary_button.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/inputs/custom_text_field.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/navigation_provider.dart';
import '../../providers/auth_state_provider.dart';
import '../widgets/auth_header_widget.dart';

/// Écran de connexion unifié et neutre.
/// L'utilisateur ne choisit pas son rôle : le rôle est automatiquement résolu
/// par le backend via le jeton d'authentification et redirigé de façon transparente.
class LoginScreen extends ConsumerStatefulWidget {
  final UserRole? initialRole;

  const LoginScreen({
    super.key,
    this.initialRole,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authStateProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      final userRole = ref.read(authStateProvider).role;
      // Redirection automatique et transparente selon le rôle résolu par le backend
      switch (userRole) {
        case UserRole.agentCollecte:
          context.go(RouteNames.agentDashboardPath);
          break;
        case UserRole.population:
        default:
          context.go(RouteNames.citizenHomePath);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () {
            ref.read(navigationIndexProvider.notifier).setIndex(0);
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.visitorHomePath);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space8,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeaderWidget(
                  title: 'Connexion',
                  subtitle:
                      'Entrez vos identifiants pour accéder à votre espace sécurisé',
                ),
                const SizedBox(height: AppDimensions.space24),

                // Bannière d'erreur si échec
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusInput),
                      border: Border.all(color: AppColors.danger, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.danger, size: 20),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                ],

                // Saisie Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Adresse email',
                  hintText: 'ex: fatoumata.diarra@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Saisie Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hintText: 'Votre mot de passe',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: AppValidators.password,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: AppDimensions.space24),

                // Bouton d'action principal
                PrimaryButton(
                  label: 'Se connecter',
                  icon: Icons.login,
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppDimensions.space20),

                // Lien d'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style: (isDark
                              ? AppTextStyles.bodySecondaryDark
                              : AppTextStyles.bodySecondary)
                          .copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(RouteNames.registerPath);
                      },
                      child: Text(
                        'S\'inscrire',
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Accès Visiteur libre
                Center(
                  child: TextButton(
                    onPressed: () => context.go(RouteNames.visitorHomePath),
                    child: Text(
                      'Continuer en mode visiteur (Sans connexion)',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.darkAccent : AppColors.accent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

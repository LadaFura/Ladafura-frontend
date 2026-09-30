import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/utils/validators.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/google_sign_in_button.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/primary_button.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/feedback/medical_disclaimer_banner.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/inputs/custom_text_field.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/navigation_provider.dart';
import '../../data/models/register_request_model.dart';
import '../../providers/auth_state_provider.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/phone_input_field.dart';

/// Écran d'inscription conforme au cahier des charges LADAFURA (US-01 / EF01).
class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const RegisterScreen({
    super.key,
    this.initialRole = UserRole.population,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez accepter les conditions d\'utilisation et l\'avertissement légal.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final request = RegisterRequestModel(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      motDePasse: _passwordController.text,
      telephone: _phoneController.text.trim().isNotEmpty
          ? '+223 ${_phoneController.text.trim()}'
          : null,
      role: UserRole.population,
    );

    final success =
        await ref.read(authStateProvider.notifier).register(request);

    if (success && mounted) {
      context.go(RouteNames.citizenHomePath);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final success = await ref
          .read(authStateProvider.notifier)
          .signInWithGoogle(role: UserRole.population);

      if (success && mounted) {
        context.go(RouteNames.citizenHomePath);
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
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
                  title: 'Créer un compte',
                  subtitle:
                      'Rejoignez la communauté de valorisation de la pharmacopée malienne',
                ),
                const SizedBox(height: AppDimensions.space20),

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

                // Prénom et Nom côte à côte
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _prenomController,
                        label: 'Prénom',
                        hintText: 'Fatoumata',
                        validator: (val) =>
                            AppValidators.required(val, 'Le prénom'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: CustomTextField(
                        controller: _nomController,
                        label: 'Nom',
                        hintText: 'Diarra',
                        validator: (val) =>
                            AppValidators.required(val, 'Le nom'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Adresse email',
                  hintText: 'fatoumata.diarra@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Téléphone malien
                PhoneInputField(
                  controller: _phoneController,
                  isRequired: false,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe (Min. 6 caractères)',
                  hintText: '••••••••',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: AppValidators.password,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Confirmation mot de passe
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hintText: '••••••••',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) => AppValidators.confirmPassword(
                      val, _passwordController.text),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Avertissement médical légal compact
                const MedicalDisclaimerBanner(compact: true),
                const SizedBox(height: AppDimensions.space12),

                // Case à cocher des conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      activeColor:
                          isDark ? AppColors.darkPrimary : AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _acceptTerms = val ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'J\'accepte les conditions d\'utilisation et l\'avertissement médical de LADAFURA.',
                        style: (isDark
                                ? AppTextStyles.captionDark
                                : AppTextStyles.caption)
                            .copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space20),

                // Bouton d'inscription
                PrimaryButton(
                  label: 'Créer mon compte',
                  icon: Icons.person_add,
                  isLoading: authState.isLoading && !_isGoogleLoading,
                  onPressed: _isGoogleLoading ? null : _handleRegister,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Séparateur Visuel
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space12,
                      ),
                      child: Text(
                        'OU',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Inscription rapide via Google Sign-In
                GoogleSignInButton(
                  label: 'S\'inscrire avec Google',
                  isLoading: _isGoogleLoading,
                  onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                ),
                const SizedBox(height: AppDimensions.space20),

                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous avez déjà un compte ? ',
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
                        context.push(RouteNames.loginPath);
                      },
                      child: Text(
                        'Se connecter',
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
                const SizedBox(height: AppDimensions.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/primary_button.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/buttons/secondary_button.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/role_card_selector.dart';

/// Écran d'orientation et de sélection du profil utilisateur.
class RoleSelectionScreen extends StatefulWidget {
  final UserRole initialRole;

  const RoleSelectionScreen({
    super.key,
    this.initialRole = UserRole.population,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.space12),
              const AuthHeaderWidget(
                title: 'Bienvenue sur LADAFURA',
                subtitle:
                    'Sélectionnez votre profil d\'accès pour personnaliser votre expérience.',
              ),
              const SizedBox(height: AppDimensions.space24),

              // Sélecteur de rôle interactif
              RoleCardSelector(
                selectedRole: _selectedRole,
                onRoleSelected: (role) {
                  setState(() {
                    _selectedRole = role;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.space32),

              // Actions principales
              PrimaryButton(
                label: 'Se connecter (${_selectedRole.label})',
                icon: Icons.login,
                onPressed: () {
                  context.push(
                    '${RouteNames.loginPath}?role=${_selectedRole.backendValue}',
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space12),

              // Bouton Inscription (particulièrement adapté aux citoyens)
              SecondaryButton(
                label: 'Créer un compte',
                icon: Icons.person_add_outlined,
                onPressed: () {
                  context.push(RouteNames.registerPath);
                },
              ),
              const SizedBox(height: AppDimensions.space24),

              // Accès libre sans compte (Espace Visiteur)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.explore_outlined, size: 18),
                  label: const Text('Consulter en mode visiteur (Sans compte)'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? AppColors.darkAccent : AppColors.accent,
                    textStyle: AppTextStyles.button
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  onPressed: () {
                    context.go(RouteNames.visitorHomePath);
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.space12),
            ],
          ),
        ),
      ),
    );
  }
}

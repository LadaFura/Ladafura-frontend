import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';

/// Boîte de dialogue / BottomSheet moderne invitant l'utilisateur non connecté
/// à se connecter avant d'ajouter un produit ou un remède à son panier.
class ConnexionRequiseDialog extends StatelessWidget {
  final String actionTitle;
  final String actionDescription;

  const ConnexionRequiseDialog({
    super.key,
    this.actionTitle = 'Connexion requise',
    this.actionDescription =
        'Vous devez être connecté à votre compte citoyen pour ajouter des produits à votre panier et passer commande.',
  });

  /// Affiche la modal de demande de connexion
  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? description,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConnexionRequiseDialog(
        actionTitle: title ?? 'Connexion requise',
        actionDescription: description ??
            'Vous devez être connecté à votre compte citoyen pour ajouter des produits à votre panier et passer commande.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space24,
        AppDimensions.space16,
        AppDimensions.space24,
        AppDimensions.space32,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusModal),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée supérieure
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppDimensions.space20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Icône d'authentification élégante
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                  .withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_person_rounded,
              size: 32,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          // Titre
          Text(
            actionTitle,
            style: (isDark ? AppTextStyles.h2Dark : AppTextStyles.h2).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.space8),

          // Description informative
          Text(
            actionDescription,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.space24),

          // Bouton Se connecter
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(true);
                context.push(RouteNames.loginPath);
              },
              icon: const Icon(Icons.login_rounded, size: 20),
              label: const Text(
                'Se connecter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space12),

          // Bouton Créer un compte ou Continuer en visiteur
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    context.push(RouteNames.registerPath);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                  ),
                  child: Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Plus tard',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

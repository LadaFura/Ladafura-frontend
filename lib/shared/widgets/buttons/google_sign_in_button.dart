import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Bouton d'authentification Google officiel adapté aux chartes graphiques de LADAFURA.
///
/// Utilisable à la fois pour la connexion et pour l'inscription.
class GoogleSignInButton extends StatelessWidget {
  /// Texte du bouton (ex: 'Continuer avec Google', 'S'inscrire avec Google')
  final String label;

  /// Callback déclenché au clic sur le bouton
  final VoidCallback? onPressed;

  /// État de chargement affichant un spinner discret
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    this.label = 'Continuer avec Google',
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFDADCE0);
    final textColor =
        isDark ? AppColors.darkTextPrimary : const Color(0xFF3C4043);

    return SizedBox(
      height: AppDimensions.buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          side: BorderSide(
            color: borderColor,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          ),
          elevation: isDark ? 0 : 0.5,
          shadowColor: Colors.black12,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.googleLogoSvg,
                    height: 22,
                    width: 22,
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.button.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

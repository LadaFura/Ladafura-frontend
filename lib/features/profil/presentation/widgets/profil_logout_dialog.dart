import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Boîte de dialogue de confirmation avant déconnexion.
class ProfilLogoutDialog extends StatelessWidget {
  const ProfilLogoutDialog({super.key});

  /// Méthode d'ouverture pratique de la boîte de dialogue.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => const ProfilLogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: AppColors.danger, size: 24),
          SizedBox(width: 8),
          Text('Déconnexion'),
        ],
      ),
      content: const Text(
        'Voulez-vous vraiment vous déconnecter de votre compte LADAFURA ?',
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}
